import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ggomdol_pedometer/pedometer.dart';
import 'dart:async';

import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  List<DailySteps> _dailySteps = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionAndStartReadPedometer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        /// If it is in resumed status, monitoring begins.
        _checkPermissionAndStartReadPedometer();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        /// If it is in paused status, monitoring stops for battery.
        Pedometer.stopReadStepCount();
        break;
    }
  }

  /// Check permission
  Future<bool> _checkActivityRecognitionPermission() async {
    bool granted = await Permission.activityRecognition.isGranted;

    if (!granted) {
      granted = await Permission.activityRecognition.request() ==
          PermissionStatus.granted;
    }

    return granted;
  }

  /// Check permission and start Pedometer service
  Future<void> _checkPermissionAndStartReadPedometer() async {
    if(defaultTargetPlatform == TargetPlatform.android) {
      bool granted = await _checkActivityRecognitionPermission();

      if (!granted) {
        // tell user, the app will not work
        return;
      }
    }

    /// Run Pedometer service
    Pedometer.startService();
    /// Run Pedometer query for gain step counts
    Pedometer.startReadStepCount(const Duration(seconds: 1), _onStepCount);
  }

  /// Start steps monitoring : maximum 7days
  void _onStepCount(List<DailySteps> dailySteps) {
    setState(() {
      if (listEquals(dailySteps, _dailySteps) == false) {
        _dailySteps = dailySteps..sort((a,b) => b.day.compareTo(a.day));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('GGomdol Pedometer Example'),
      ),
      body: Center(
          child: _dailySteps.isNotEmpty == true
              ? ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(50.0),
                  scrollDirection: Axis.vertical,
                  itemCount: _dailySteps.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Text(
                          '${_dailySteps[index].year}-${_dailySteps[index].month}-${_dailySteps[index].day} :',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          '${_dailySteps[index].steps} steps',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    );
                  })
              : const Text('Empty')),
    ));
  }
}
