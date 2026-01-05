import 'package:flutter/services.dart';

class UsageAccess {
  static const _ch = MethodChannel('chromabloom/usage_access');

  static Future<void> openSettings() async {
    await _ch.invokeMethod('openSettings');
  }

  static Future<bool> isGranted() async {
    final v = await _ch.invokeMethod<bool>('isGranted');
    return v == true;
  }

  static Future<Map<dynamic, dynamic>> readTodayStats() async {
    final v = await _ch.invokeMethod('readTodayStats');
    return v as Map<dynamic, dynamic>;
  }
}
