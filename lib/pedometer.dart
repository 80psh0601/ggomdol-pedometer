import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DailySteps {
  DailySteps(this.year, this.month, this.day, this.steps);

  int year;
  int month;
  int day;
  int steps;
}

class Pedometer {
  static Timer? _timer;

  static void Function(List<DailySteps> dailySteps)? _dailyStepsCallback;

  static final _methodChannel = const MethodChannel('ggomdol.pedometer/PedometerPlugin');
  static final _method_channel_pedometer_step_count = "pedometer_step_count";
  static final _method_channel_pedometer_on = "pedometer_on";
  static final _method_channel_pedometer_off = "pedometer_off";

  static void startReadStepCount(Duration duration, void callback(List<DailySteps> dailySteps)) {
    _dailyStepsCallback = callback;
    _startMethodChannel();

    _timer = Timer.periodic(duration, (timer) async {
      _methodChannel.invokeMethod(_method_channel_pedometer_step_count, null);
    });
  }

  static void stopReadStepCount() {
    _methodChannel.setMethodCallHandler(null);
    _timer?.cancel();
    _timer = null;
    _dailyStepsCallback = null;
  }

  static void startService() {
    _methodChannel.invokeMethod(_method_channel_pedometer_on, null);
  }

  static void stopService() {
    stopReadStepCount();
    _methodChannel.invokeMethod(_method_channel_pedometer_off, null);
  }

  static void _startMethodChannel() {
    _methodChannel.setMethodCallHandler((call) async {
      try {
        if (call.method == _method_channel_pedometer_step_count) {
          final stepCountWithDate = call.arguments as Map;

          final List<DailySteps> dailySteps = [];
          stepCountWithDate.forEach((key, value) {
            final date = (key as String).split('-');
            dailySteps.add(
                DailySteps(
                  int.parse(date[0]),
                  int.parse(date[1]),
                  int.parse(date[2]),
                  value
                )
            );
          });
          _dailyStepsCallback?.call(dailySteps);
        }
      } catch (e) {
        debugPrint('PedometerPlugin : Error in MethodChannel: $e');
      }
    });
  }
}
