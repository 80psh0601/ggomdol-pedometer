# Pedometer

[pub package](https://pub.dartlang.org/packages/ggomdol_pedometer)

This plugin allows for Query the number of steps count collected over 7 days on AOS and IOS.

![Image](https://github.com/user-attachments/assets/a3e65e1d-ca05-409f-8748-149600d3bd05)

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

It works regardless of power on/off on both AOS and IOS. 
Also, it does not require foreground or background service. Data for the past 7 days is managed by the OS.

## Example Usage

See the [example app](https://github.com/80psh0601/ggomdol-pedometer/tree/main/ggomdol_pedometer_example/lib/main.dart) for a fully-fledged example.

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
