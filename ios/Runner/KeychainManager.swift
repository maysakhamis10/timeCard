//
//  KeychainManager.swift
//  Runner
//
//  Created by Yasmine on 12/7/20.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import UIKit
import JNKeychain

class KeychainManager: NSObject {
    
    static let sharedInstance = KeychainManager()

    func getDeviceIdentifierFromKeychain(Res:FlutterResult){
        

        // try to get value from keychain
         var deviceUDID = self.keychain_valueForKey("keychainDeviceUDID") as? String
        if deviceUDID == nil {
            deviceUDID = GenerateMacAddress()
            // save new value in keychain
            self.keychain_setObject(deviceUDID! as AnyObject, forKey: "keychainDeviceUDID")
        }
        print("the Res value will be  ")
        print(deviceUDID)
        return Res(String(deviceUDID ?? "Unkown"))
    }

    // MARK: - Keychain

    func keychain_setObject(_ object: AnyObject, forKey: String) {
        let result = JNKeychain.saveValue(object, forKey: forKey)
     
        if !result {
            print("keychain saving: smth went wrong")
        }
        else {
               print("result saved in keychain ")
        }
    }

    func keychain_deleteObjectForKey(_ key: String) -> Bool {
        let result = JNKeychain.deleteValue(forKey: key)
        return result
    }

    func keychain_valueForKey(_ key: String) -> AnyObject? {
        let value = JNKeychain.loadValue(forKey: key)
         print("result come from keychain saved value ")
        return value as AnyObject?
    }
    
     // MARK: - GenerateMacAddress
      func GenerateMacAddress()->String{
            
        var modifiedMacAddress = ""
                if let vendorIdentifier = UIDevice.current.identifierForVendor {
//                    var uuid = vendorIdentifier.uuid
//                    let data = withUnsafePointer(to:uuid) {
//                        Data(bytes: $0, count: MemoryLayout.size(ofValue: uuid))
//                    }
//
                    let macAddress = String(vendorIdentifier.uuidString.replacingOccurrences(of: "-", with: "").suffix(3*4))
                    for (index, char) in macAddress.enumerated() {
                        if index%2==0 && index != 0{
                            modifiedMacAddress = modifiedMacAddress + ":"
                        }
                        modifiedMacAddress = modifiedMacAddress + String(char)
                    }
                }
              
           return modifiedMacAddress
            //  result(String(modifiedMacAddress))
     
        }
    
    
}
