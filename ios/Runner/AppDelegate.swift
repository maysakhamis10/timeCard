import UIKit
import Flutter
import Foundation



@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
      
    let InstanceKeychainManger = KeychainManager()
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // get mac address using channel
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
       let addressChannel = FlutterMethodChannel(name: "macAddress",
                                                    binaryMessenger: controller.binaryMessenger)
          addressChannel.setMethodCallHandler({
           (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            // Note: this method is invoked on the UI thread.
            // Handle battery messages.
           guard call.method == "getMacAddress" else {
               result(FlutterMethodNotImplemented)
               return
           }
        //    self.GenerateMacAddress(result: result)
            self.InstanceKeychainManger.getDeviceIdentifierFromKeychain(Res:result)
    })
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
   // MARK: - GetMacAddress
//     func GenerateMacAddress(result:FlutterResult){
//
//       var modifiedMacAddress = ""
//               if let vendorIdentifier = UIDevice.current.identifierForVendor {
//                   var uuid = vendorIdentifier.uuid
//                   let data = withUnsafePointer(to:uuid) {
//                       Data(bytes: $0, count: MemoryLayout.size(ofValue: uuid))
//                   }
//
//                   let macAddress = String(vendorIdentifier.uuidString.replacingOccurrences(of: "-", with: "").suffix(3*4))
//                   for (index, char) in macAddress.enumerated() {
//                       if index%2==0 && index != 0{
//                           modifiedMacAddress = modifiedMacAddress + ":"
//                       }
//                       modifiedMacAddress = modifiedMacAddress + String(char)
//                   }
//               }
//
//             result(String(modifiedMacAddress))
//
//       }

    
    // MARK: - Keychain
    

}
