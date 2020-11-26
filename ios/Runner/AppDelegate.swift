import UIKit
import Flutter
import Foundation
import CoreLocation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
     var locationmgr : CLLocationManager!
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    //get location permission
//   locationmgr = CLLocationManager()
 // locationmgr.requestWhenInUseAuthorization()
  //  locationmgr.requestAlwaysAuthorization()

    
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
           self.getMacAddress(result:result)
    })
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    // get mac address function
    private func getMacAddress(result:FlutterResult){
           
       var modifiedMacAddress = ""
               if let vendorIdentifier = UIDevice.current.identifierForVendor {
                   var uuid = vendorIdentifier.uuid
                   let data = withUnsafePointer(to:uuid) {
                       Data(bytes: $0, count: MemoryLayout.size(ofValue: uuid))
                   }
                   
                   let macAddress = String(vendorIdentifier.uuidString.replacingOccurrences(of: "-", with: "").suffix(3*4))
                   for (index, char) in macAddress.enumerated() {
                       if index%2==0 && index != 0{
                           modifiedMacAddress = modifiedMacAddress + ":"
                       }
                       modifiedMacAddress = modifiedMacAddress + String(char)
                   }
               }
             
             result(String(modifiedMacAddress))
    
       }
}
