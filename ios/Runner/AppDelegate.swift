import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    var mapsApiKey = ""
    if let path = Bundle.main.path(forResource: "flutter_assets/.env", ofType: nil) {
      if let content = try? String(contentsOfFile: path, encoding: .utf8) {
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
          let parts = line.components(separatedBy: "=")
          if parts.count >= 2 && parts[0].trimmingCharacters(in: .whitespaces) == "GOOGLE_MAPS_API_KEY" {
            mapsApiKey = parts[1].trimmingCharacters(in: .whitespaces)
            break
          }
        }
      }
    }

    if !mapsApiKey.isEmpty {
      GMSServices.provideAPIKey(mapsApiKey)
    } else {
      GMSServices.provideAPIKey("AIzaSyA4WsA4xg")
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

