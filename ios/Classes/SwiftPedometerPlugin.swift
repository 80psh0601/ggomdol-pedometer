import Flutter
import UIKit
import CoreMotion

public class SwiftPedometerPlugin: NSObject, FlutterPlugin {
    private var stepCounter: CMPedometer?
    private var channel: FlutterMethodChannel?

    private let method_channel_pedometer_step_count = "pedometer_step_count"
    private let method_channel_pedometer_on = "pedometer_on"
    private let method_channel_pedometer_off = "pedometer_off"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let stepCountChannel = FlutterMethodChannel(name: "ggomdol.pedometer/PedometerPlugin", binaryMessenger: registrar.messenger())
        let instance = SwiftPedometerPlugin()
        instance.channel = stepCountChannel
        registrar.addMethodCallDelegate(instance, channel: stepCountChannel)
    }

      public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case method_channel_pedometer_on:
              subscribe()
              result(nil)
            case method_channel_pedometer_off:
              unSubscribe()
              result(nil)
            case method_channel_pedometer_step_count:
              readStepCount()
              result(nil)
            default:
              result(FlutterMethodNotImplemented)
        }
      }

      private func readStepCount() {
        if stepCounter == nil {
          return
        }
        
        let calendar = Calendar.current
        let today = Date()

        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: today) else {
            return
        }

        let startDate = calendar.startOfDay(for: sevenDaysAgo)
        
        var weeklySteps: [String: Int] = [:]
        
        for offset in 0...6 {
            let date = calendar.date(byAdding: .day, value: offset, to: startDate)!
          
            stepCounter?.queryPedometerData(from: date, to: date.addingTimeInterval(86400)) { (data, error) in
                if let error = error {
                    print("Error: \(error)")
                } else {
                  if let data = data {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let dateString = dateFormatter.string(from: date)
                    let steps = Int(truncating: data.numberOfSteps)
                    weeklySteps[dateString] = steps

                    if weeklySteps.count == 7 {
                      self.channel?.invokeMethod(self.method_channel_pedometer_step_count, arguments: weeklySteps)
                    }
                  }
                }
            }
        }
      }

      private func subscribe() {
        stepCounter = CMPedometer()
      }

      private func unSubscribe() {
        stepCounter = nil
      }
}
