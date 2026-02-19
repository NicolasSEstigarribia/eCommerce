import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let commentsChannel = FlutterMethodChannel(name: "com.example.ecommerce/comments",
                                              binaryMessenger: controller.binaryMessenger)
    
    commentsChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getComments" {
        guard let args = call.arguments as? [String: Any],
              let postId = (args["postId"] as? NSNumber)?.intValue else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Post ID is missing", details: nil))
          return
        }
        self.fetchComments(postId: postId, result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func fetchComments(postId: Int, result: @escaping FlutterResult) {
    let urlString = "https://jsonplaceholder.typicode.com/comments?postId=\(postId)"
    guard let url = URL(string: urlString) else {
      result(FlutterError(code: "INVALID_URL", message: "Invalid URL", details: nil))
      return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      if let error = error {
        DispatchQueue.main.async {
          result(FlutterError(code: "FETCH_ERROR", message: error.localizedDescription, details: nil))
        }
        return
      }

      guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
        DispatchQueue.main.async {
          result(FlutterError(code: "EMPTY_RESPONSE", message: "Received empty response", details: nil))
        }
        return
      }

      DispatchQueue.main.async {
        result(responseString)
      }
    }
    task.resume()
  }
}
