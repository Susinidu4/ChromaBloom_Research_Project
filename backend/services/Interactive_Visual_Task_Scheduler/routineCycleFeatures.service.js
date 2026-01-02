import RoutineRunModel from "../../models/Interactive_Visual_Task_Scheduler_Model/routineRunModel.js";

/**
 * Safely compute minutes between two timestamps
 */
function minutesBetween(startedAt, finishedAt) {
  if (!startedAt || !finishedAt) return null;
  const ms = new Date(finishedAt).getTime() - new Date(startedAt).getTime();
  if (!Number.isFinite(ms) || ms < 0) return null;
  return ms / 60000;
}

/**
 * Mean helper
 */
function mean(arr) {
  const clean = arr.filter((x) => Number.isFinite(x));
  if (clean.length === 0) return 0;
  return clean.reduce((a, b) => a + b, 0) / clean.length;
}

/**
 * Format Date -> YYYY-MM-DD (UTC safe)
 */
function toYMD(date) {
  const d = new Date(date);
  const y = d.getUTCFullYear();
  const m = String(d.getUTCMonth() + 1).padStart(2, "0");
  const day = String(d.getUTCDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

/**
 * Compute completion_rate for a run.
 * Supports multiple possible schemas:
 * - completion_rate
 * - completed_steps & total_steps
 * - steps_done & steps_total
 * - completedSteps & totalSteps
 */
function getCompletionRate(run) {
  if (Number.isFinite(run.completion_rate)) return run.completion_rate;

  const completed =
    run.completed_steps ??
    run.steps_done ??
    run.completedSteps ??
    run.done_steps ??
    null;

  const total =
    run.total_steps ??
    run.steps_total ??
    run.totalSteps ??
    run.all_steps ??
    null;

  if (Number.isFinite(completed) && Number.isFinite(total) && total > 0) {
    return completed / total;
  }

  // fallback: if you track task completion boolean
  if (run.is_completed === true) return 1;
  if (run.is_completed === false) return 0;

  return null;
}

/**
 * Get skipped steps count for a run (supports variants)
 */
function getSkippedSteps(run) {
  const skipped =
    run.skipped_steps_count ??
    run.skipped_steps ??
    run.skippedSteps ??
    run.skipped_count ??
    null;

  return Number.isFinite(skipped) ? skipped : 0;
}

/**
 * Compute 14-day features for one plan cycle.
 */
export async function computeCycleFeatures({
  caregiverId,
  childId,
  planId,
  cycleStart,
  cycleEnd,
  currentDifficultyLevel,
}) {
  // fetch all runs in cycle
  const runs = await RoutineRunModel.find({
    caregiverId,
    childId,
    planId,
    run_date: { $gte: cycleStart, $lte: cycleEnd },
  })
    .lean()
    .sort({ run_date: 1 });

  const runs_count = runs.length;

  // per-run lists
  const completionRates = [];
  const skippedSteps = [];
  const durations = [];

  // for trend: daily avg completion rate
  const dailyMap = new Map(); // ymd -> [rates...]

  for (const r of runs) {
    const cr = getCompletionRate(r);
    if (Number.isFinite(cr)) completionRates.push(cr);

    const ss = getSkippedSteps(r);
    skippedSteps.push(ss);

    const dur = minutesBetween(r.started_at, r.finished_at);
    if (Number.isFinite(dur)) durations.push(dur);

    // daily trend tracking
    const key = toYMD(r.run_date);
    if (!dailyMap.has(key)) dailyMap.set(key, []);
    if (Number.isFinite(cr)) dailyMap.get(key).push(cr);
  }

  const avg_completion_rate = mean(completionRates);
  const avg_skepped_steps = mean(skippedSteps); // keep your spelling
  const avg_duration_minutes = mean(durations);

  // build daily avg list ordered by day
  const dailyKeys = Array.from(dailyMap.keys()).sort();
  const dailyRates = dailyKeys.map((k) => mean(dailyMap.get(k)));

  // completion_rate_trend = avg(last half) - avg(first half)
  let completion_rate_trend = 0;
  if (dailyRates.length >= 2) {
    const mid = Math.floor(dailyRates.length / 2);
    const firstHalf = dailyRates.slice(0, mid);
    const secondHalf = dailyRates.slice(mid);
    completion_rate_trend = mean(secondHalf) - mean(firstHalf);
  }

  return {
    childId,
    avg_completion_rate,
    avg_skepped_steps,
    avg_duration_minutes,
    runs_count,
    completion_rate_trend,
    current_difficulty_level: currentDifficultyLevel,
    // optional debug info:
    // dailyRates,
  };
}
