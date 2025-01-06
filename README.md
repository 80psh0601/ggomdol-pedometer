# Pedometer

[![pub package](https://img.shields.io/pub/v/pedometer.svg)](https://pub.dartlang.org/packages/pedometer)

This plugin allows for continuous step counting and pedestrian status using the built-in pedometer sensor API of iOS and Android devices.

![](https://raw.githubusercontent.com/cph-cachet/flutter-plugins/master/packages/pedometer/imgs/screenshots.png)

## Permissions

For Android 10 and above add the following permission to the Android manifest:

```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
```

For iOS, add the following entries to your Info.plist file in the Runner xcode project:

```xml
<key>NSMotionUsageDescription</key>
<string>This application tracks your steps</string>
<key>UIBackgroundModes</key>
<array>
    <string>processing</string>
</array>
```

## Step Count

The step count represents the number of steps taken since the last system boot.
On Android, any steps taken before installing the application will not be counted.

## Pedestrian Status

The Pedestrian status is either `walking` or `stopped`. In the case that of an error,
the status will be `unknown`.

## Availability of Sensors

Both Step Count and Pedestrian Status may not be available on some phones:

* It was found that some Samsung phones do not support Step Count or Pedestrian Status
* Older iPhones do not support Pedestrian Status in particular

In the case that the step sensor is not available, an error will be thrown. The application needs to handle this error.

## Example Usage

See the [example app](https://github.com/cph-cachet/flutter-plugins/blob/master/packages/pedometer/example/lib/main.dart) for a fully-fledged example.

Below is shown a more generalized example. Remember to set the required permissions, as described above. This may require you to manually allow the permission in the "Settings" on the phone.

``` dart
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
```
