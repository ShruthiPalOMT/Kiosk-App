//
//  UIApplication_MethodSwizzling.swift
//  WebAppDemo
//
//  Created by Yilei He on 13/12/16.
//  Copyright © 2016 Yilei He. All rights reserved.
//

import UIKit


private var timer: Timer?
let didDetectIdleStatusNotification = NSNotification.Name("com.rightcrowd.idleNotification")
var idlePeriodSeconds: TimeInterval = 30

/* Method Swizzling */
/* Configuration */
private let MethodMapping:Dictionary<String,String> = [
    "sendEvent:":"swizzled_sendEvent:"
]


private let swizzlingClass = UIApplication.self

extension UIApplication {
    
    override open class func initialize() {
        
        /* Filter classes */
        guard self === swizzlingClass else { return }
        swizzling
    }
    
    
    
    func swizzled_sendEvent(_ event: UIEvent) {
        self.swizzled_sendEvent(event)
        
        timer?.invalidate()
        
        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: idlePeriodSeconds, repeats: false) { timer in
                NotificationCenter.default.post(name: didDetectIdleStatusNotification, object: nil)
            }
        } else {
            timer = Timer.scheduledTimer(timeInterval: idlePeriodSeconds, target: self, selector: #selector(timeout), userInfo: nil, repeats: false)
        }
    }
    
    
    @objc private func timeout() {
        NotificationCenter.default.post(name: didDetectIdleStatusNotification, object: nil)
    }
}


private let swizzling: () = {
    for (originalSelector,swizzledSelector) in MethodMapping {
        let originalSelector = Selector(originalSelector)
        let swizzledSelector = Selector(swizzledSelector)
        
        let originalMethod = class_getInstanceMethod(swizzlingClass, originalSelector)
        let swizzledMethod = class_getInstanceMethod(swizzlingClass, swizzledSelector)
        
        let didAddMethod = class_addMethod(swizzlingClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(swizzlingClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}()

