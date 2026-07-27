import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Explicitly install the AppDelegate as the UNUserNotificationCenter
    // delegate. Reason: with `FirebaseAppDelegateProxyEnabled = NO` in
    // Info.plist, Firebase no longer swizzles this delegate — and both
    // `firebase_messaging` and `flutter_local_notifications` try to
    // register themselves. Whichever runs last wins, which was making
    // our local notifications get routed to a delegate that dropped
    // them. Setting the delegate to `self` here (AFTER plugin
    // registration) is definitive: `FlutterAppDelegate` implements the
    // required UNUserNotificationCenterDelegate methods in an internal
    // Objective-C extension and forwards to all registered plugins,
    // so both remote and local paths work. `as?` cast is required
    // because that conformance isn't declared in FlutterAppDelegate's
    // public header — Swift can't see it at compile time.
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
