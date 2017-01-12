//
//  HALEngine.swift
//  WebAppDemo
//
//  Created by Yilei He on 6/12/16.
//  Copyright © 2016 Yilei He. All rights reserved.
//

import UIKit
import WebKit

class HALEngine: NSObject {
    private(set) weak var viewController: UIViewController!
    private(set) weak var webView: WKWebView!
    
    /* **************************************** */
    /* ☟☟☟☟☟ ONLY MODIFY CODE BELOW ☟☟☟☟☟ */
    /* **************************************** */
    
    /**
     - This is the dictionary you could edit to extend HALEngine's capabilities. It consists of eventName-codeBlock pairs. Don't modify other part of the code if you don't know what it does.
     - In the closure, the first parameter "payload" is an optional<Any> onject, it could be a json object, a String or a number depending on what is passed in when rc_hal.sendMessage() is called in javascript.
     - The second parameter "callback" is a javascript function in string format
     - You can also get current view controller and web view by self.viewController and self.webView
     */
    lazy var messageHandlers: [String: (_ payload: Any?, _ callback: String?)->Void] = [
        "ScanBarcode": //This is the message(aka. task) that web app sends in
            { payload, callbackString in // below is the code to execute for the task
                var position: CameraPosition = .back
                
                /* configure the camera to use */
                if let positionString = payload as? String {
                    if positionString == "front" {
                        position = .front
                    } else if positionString == "back" {
                        position = .back
                    }
                }
                
                /* perform "scan qr code" task */
                BarCodeUtils.scanBarCode(presentingViewController: self.viewController, completionHandler: { (result) in
                    //in the callback
                    //trigger a event called "ScanSuccess", send the scaned result in with event
                    self.webView.evaluateJavaScript("rc_hal.triggerEvent(\"ScanSuccess\", \"\(result.base64Encoded()!)\");") { (result, error) in
                        print(result as Any, error?.localizedDescription as Any)
                    }
                    
                    //call the javascript callback function with scaned code as parameter
                    if let callback = callbackString {
                        self.executeJavascriptFunction(callback, parameters: "\"" + result.base64Encoded()! /*.replacingOccurrences(of:"\\", with: "\\\\")*/ + "\"")
                    }
                })
//                self.viewController.scanQRCode(cameraPosition: position, completionHandler: { (result) in
//                    //in the callback
//                    //trigger a event called "ScanSuccess", send the scaned result in with event
//                    self.webView.evaluateJavaScript("rc_hal.triggerEvent(\"ScanSuccess\", \"\(result)\");") { (result, error) in
//                        print(result as Any, error?.localizedDescription as Any)
//                    }
//                    
//                    //call the javascript callback function with scaned code as parameter
//                    if let callback = callbackString {
//                        self.executeJavascriptFunction(callback, parameters: "\"" + result + "\"")
//                    }
//                })
                
            },
        "TakePhoto":
            {payload, callbackString in
                try? self.viewController.pickImage(from: .camera, cameraDevice: .front, allowEditing: false) {image, _, _, metadata in
                    guard let image = image else {return}
                    if let callback = callbackString, let data = UIImagePNGRepresentation(image.normalized()) {
                        self.executeJavascriptFunction(callback, parameters: "\"" + data.base64EncodedString() + "\"")
                    }
                }
            },
        "Initialization":
            { payload, callbackString in
                if let callback = callbackString, let arguments = UserDefaults.standard.value(forKey: argumentsUserDefaultsKey) as? [String: String] {
                    let data = try? JSONSerialization.data(withJSONObject: arguments, options: [])
                    var json = String(data: data!, encoding: .utf8)!
                    self.executeJavascriptFunction(callback, parameters: json)
                }
            }
    ]
    
    /* **************************************** */
    /* ☝︎☝︎☝︎☝︎☝︎ ONLY MODIFY CODE ABOVE ☝︎☝︎☝︎☝︎☝︎ */
    /* **************************************** */
    
    init(viewController: UIViewController, webView: WKWebView) {
        self.viewController = viewController
        self.webView = webView
    }
    
    func handle(task json: [String: Any]) {
        guard let message = json["message"] as? String else { return }
        messageHandlers[message]?(json["payload"], json["callback"] as? String)
    }
    
    
    func makeJavascript(using functionString: String, parameters:[String]) -> String? {
        let paramString = parameters.map{/*"\"" + */$0.trimmed()/* + "\""*/}.joined(separator: ", ")
        var js = try! functionString.replacing(regularExpression: "(function) ?\\w*(\\(\\w*\\))", withTemplate: "$1$2")
        js = "(" + js + ").call(null, \(paramString));"
        return js
    }
    
    
    
    func executeJavascriptFunction(_ function: String, parameters:String...) {
        guard let js = self.makeJavascript(using: function, parameters: parameters) else { return }
        self.webView.evaluateJavaScript(js) { (result, error) in
            print(result as Any, error?.localizedDescription as Any)
        }
    }
}
