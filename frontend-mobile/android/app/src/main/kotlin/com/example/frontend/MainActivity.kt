package com.example.frontend

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity : FlutterActivity() {
  private val CHANNEL = "chromabloom/usage_access"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
      .setMethodCallHandler { call, result ->
        when (call.method) {

          "openSettings" -> {
            startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
            result.success(true)
          }

          "isGranted" -> result.success(hasUsageStatsPermission())

          "readTodayStats" -> {
            if (!hasUsageStatsPermission()) {
              result.error("NO_PERMISSION", "Usage access not granted", null)
              return@setMethodCallHandler
            }

            val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

            val now = System.currentTimeMillis()
            val todayStart = todayStartMillis()

            val (nightStart, nightEndRaw) = nightWindowMillis()
            val nightEnd = minOf(nightEndRaw, now)

            // ✅ Ignore list applied to BOTH minutes + opens
            val ignore = IGNORE_PACKAGES + packageName

            // ✅ 1) Accurate minutes computed from UsageEvents (resumed/paused)
            val perPkgTodayMs = computeForegroundMsFromEvents(usm, todayStart, now, ignore)
            val totalTodayMs = perPkgTodayMs.values.sum()

            val perPkgNightMs = if (nightEnd > nightStart) {
              computeForegroundMsFromEvents(usm, nightStart, nightEnd, ignore)
            } else emptyMap()
            val totalNightMs = perPkgNightMs.values.sum()

            val totalScreenTimeMin = (totalTodayMs / 60000L).toInt()
            val nightUsageMin = (totalNightMs / 60000L).toInt()

            // category mins from the same accurate event-based totals
            val socialMin = (sumForPackages(perPkgTodayMs, SOCIAL_PACKAGES) / 60000L).toInt()
            val videoMin  = (sumForPackages(perPkgTodayMs, VIDEO_PACKAGES) / 60000L).toInt()

            // ✅ 2) Opens + unlocks (improved opens signal)
            val appOpenedCount = countAppOpensFromResumed(usm, todayStart, now, ignore)
            val unlockCount = countUnlocks(usm, todayStart, now)

            val lateNightFlag = nightUsageMin > 0

            // Optional debug: top packages to tune SOCIAL/VIDEO lists
            val top = perPkgTodayMs.entries
              .sortedByDescending { it.value }
              .take(10)
              .joinToString { "${it.key}=${it.value / 60000}m" }

            Log.i(
              "USAGE_DEBUG",
              "opens=$appOpenedCount unlocks=$unlockCount totalMin=$totalScreenTimeMin nightMin=$nightUsageMin socialMin=$socialMin videoMin=$videoMin"
            )
            Log.i("USAGE_DEBUG", "TOP_PACKAGES: $top")

            result.success(
              hashMapOf(
                "total_screen_time_min" to totalScreenTimeMin,
                "night_usage_min" to nightUsageMin,
                "unlock_count" to unlockCount,
                "app_opened_times_count" to appOpenedCount,
                "social_media_min" to socialMin,
                "video_apps_min" to videoMin,
                "late_night_usage_flag" to lateNightFlag
              )
            )
          }

          else -> result.notImplemented()
        }
      }
  }

  // ---------- Permission check ----------
  private fun hasUsageStatsPermission(): Boolean {
    val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
    val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      appOps.unsafeCheckOpNoThrow(
        AppOpsManager.OPSTR_GET_USAGE_STATS,
        android.os.Process.myUid(),
        packageName
      )
    } else {
      appOps.checkOpNoThrow(
        AppOpsManager.OPSTR_GET_USAGE_STATS,
        android.os.Process.myUid(),
        packageName
      )
    }
    return mode == AppOpsManager.MODE_ALLOWED
  }

  // ---------- Time windows ----------
  private fun todayStartMillis(): Long {
    return Calendar.getInstance().apply {
      set(Calendar.HOUR_OF_DAY, 0)
      set(Calendar.MINUTE, 0)
      set(Calendar.SECOND, 0)
      set(Calendar.MILLISECOND, 0)
    }.timeInMillis
  }

  private fun nightWindowMillis(): Pair<Long, Long> {
    val start = Calendar.getInstance().apply {
      set(Calendar.HOUR_OF_DAY, 0)
      set(Calendar.MINUTE, 0)
      set(Calendar.SECOND, 0)
      set(Calendar.MILLISECOND, 0)
    }.timeInMillis

    val end = Calendar.getInstance().apply {
      set(Calendar.HOUR_OF_DAY, 5)
      set(Calendar.MINUTE, 0)
      set(Calendar.SECOND, 0)
      set(Calendar.MILLISECOND, 0)
    }.timeInMillis

    return Pair(start, end)
  }

  // ---------- Accurate per-package foreground time from UsageEvents ----------
  private fun computeForegroundMsFromEvents(
    usm: UsageStatsManager,
    start: Long,
    end: Long,
    ignore: Set<String>
  ): Map<String, Long> {
    if (end <= start) return emptyMap()

    val result = HashMap<String, Long>()
    val events = usm.queryEvents(start, end)
    val e = UsageEvents.Event()

    var currentPkg: String? = null
    var currentStart = 0L

    while (events.hasNextEvent()) {
      events.getNextEvent(e)

      val pkg = e.packageName ?: continue
      val t = e.timeStamp

      when (e.eventType) {
        UsageEvents.Event.ACTIVITY_RESUMED -> {
          if (!ignore.contains(pkg)) {
            currentPkg = pkg
            currentStart = t
          } else {
            currentPkg = null
            currentStart = 0L
          }
        }

        UsageEvents.Event.ACTIVITY_PAUSED -> {
          if (currentPkg == pkg && currentStart > 0L) {
            val dur = (t - currentStart).coerceAtLeast(0L)
            // safety cap: ignore crazy long durations (e.g., missing pause events)
            if (dur <= 6 * 60 * 60 * 1000L) {
              result[pkg] = (result[pkg] ?: 0L) + dur
            }
          }
          currentPkg = null
          currentStart = 0L
        }
      }
    }

    return result
  }

  private fun sumForPackages(perPkg: Map<String, Long>, allowed: Set<String>): Long {
    var sum = 0L
    for ((pkg, ms) in perPkg) {
      if (allowed.contains(pkg)) sum += ms
    }
    return sum
  }

  // ---------- Opens: based on ACTIVITY_RESUMED, deduped ----------
  private fun countAppOpensFromResumed(
    usm: UsageStatsManager,
    start: Long,
    end: Long,
    ignore: Set<String>
  ): Int {
    val events = usm.queryEvents(start, end)
    val e = UsageEvents.Event()

    var count = 0
    var lastPkg: String? = null

    while (events.hasNextEvent()) {
      events.getNextEvent(e)

      if (e.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
        val pkg = e.packageName ?: continue
        if (ignore.contains(pkg)) continue

        if (pkg != lastPkg) {
          count++
          lastPkg = pkg
        }
      }
    }
    return count
  }

  // ---------- Unlocks ----------
  private fun countUnlocks(usm: UsageStatsManager, start: Long, end: Long): Int {
    val events = usm.queryEvents(start, end)
    val e = UsageEvents.Event()
    var count = 0

    while (events.hasNextEvent()) {
      events.getNextEvent(e)

      // Android 10+ best signal for unlock
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
        e.eventType == UsageEvents.Event.KEYGUARD_HIDDEN
      ) {
        count++
      }
    }
    return count
  }

  // ---------- Package lists ----------
  // System/background packages you generally should NOT count as "user screen time"
  private val IGNORE_PACKAGES = setOf(
    "com.android.systemui",
    "com.google.android.apps.nexuslauncher",
    "com.android.launcher3",
    "com.google.android.launcher",
    "com.google.android.gms",
    "com.google.android.gsf",
    "com.google.android.googlequicksearchbox",
    "com.android.phone"
  )

  private val SOCIAL_PACKAGES = setOf(
    "com.facebook.katana",
    "com.facebook.lite",
    "com.instagram.android",
    "com.twitter.android",
    "com.snapchat.android",
    "com.whatsapp",
    "com.facebook.orca",
    "com.zhiliaoapp.musically", // TikTok
    "com.linkedin.android",
    "org.telegram.messenger"
  )

  private val VIDEO_PACKAGES = setOf(
    "com.google.android.youtube",
    "com.google.android.youtube.tv",
    "com.google.android.apps.youtube.music",
    "com.netflix.mediaclient",
    "com.amazon.avod.thirdpartyclient",
    "com.disney.disneyplus",
    "com.hulu.plus",
    "com.mxtech.videoplayer.ad"
  )
}
