import Flutter
import UIKit

public class PausedSecretPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let mc =  FlutterMethodChannel(name: "paused_secret.MethodChannel", binaryMessenger: registrar.messenger())
    let instance = PausedSecretPlugin()
    registrar.addMethodCallDelegate(instance, channel: mc)
    let ec = FlutterEventChannel(name: "paused_secret.EventChannel", binaryMessenger: registrar.messenger())
    ec.setStreamHandler(instance)
    registrar.addApplicationDelegate(instance)
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "pausedSecret":
        let args = call.arguments as! Dictionary<String,Bool>
        _pausedSecret = args["secret"] ?? false
        result("")
      default:
        result(FlutterMethodNotImplemented)
    }
  }
  
  var _pausedSecret: Bool = false
  
  public func applicationWillResignActive(_ application: UIApplication) {
    if(_pausedSecret) {
      application.ignoreSnapshotOnNextApplicationLaunch()
      if let window = UIApplication.shared.windows.filter({(w) -> Bool in
        return w.isHidden == false
      }).first {
        if let blurEffectView = window.viewWithTag(996120) {
          window.bringSubviewToFront(blurEffectView)
          return
        } else {
          let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
          let blurEffectView = UIVisualEffectView(effect: blurEffect)
          blurEffectView.frame = window.bounds
          blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
          blurEffectView.tag = 996120
          
          window.addSubview(blurEffectView)
          window.bringSubviewToFront(blurEffectView)
          window.snapshotView(afterScreenUpdates: true)
          RunLoop.current.run(until: Date(timeIntervalSinceNow:0.5))
        }
      }
    }
  }
  
  public func applicationDidBecomeActive(_ application: UIApplication) {
    if(_pausedSecret) {
      application.ignoreSnapshotOnNextApplicationLaunch()
      if let window = UIApplication.shared.windows.filter({(w) -> Bool in
        return w.isHidden == false
      }).first {
        if let blurEffectView = window.viewWithTag(996120) {
          blurEffectView.removeFromSuperview()
        }
      }
    }
  }
  
  var eventSink: FlutterEventSink?
  
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
     if(arguments as! String == "onScreenshot") {
         NotificationCenter.default.addObserver(
             self,
             selector: #selector(onScreenshot),
             name: UIApplication.userDidTakeScreenshotNotification,
             object: nil
         )
     }
     return nil
  }
  
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    if(arguments as! String == "onScreenshot") {
        NotificationCenter.default.removeObserver(self)
    }
    eventSink = nil
    return nil
  }
  
  @objc func onScreenshot() {
      eventSink?(["key":"onScreenshot"])
  }
}
