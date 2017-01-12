//
//  UIView+hideKeyboard.swift
//  Swift3Project
//
//  Created by Yilei He on 6/12/16.
//  Copyright © 2016 lionhylra.com. All rights reserved.
//

import UIKit
import ObjectiveC

//private var focusedView_associationKey = 0

extension UIView {
    public func addTapToHideKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(private_viewDidTapped(tap:)))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }
    
    
    
    @objc private func private_viewDidTapped(tap: UITapGestureRecognizer) {
        endEditing(false)
    }
    
    
    
//    public var focusedView: UIView! {
//        get {
//            return objc_getAssociatedObject(self, &focusedView_associationKey) as! UIView
//        }
//        set {
//            objc_setAssociatedObject(self, &focusedView_associationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
    
    
    
//    public func setupKeyboardAvoiding(for subview: UIView) {
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noticiation:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDismiss(noticiation:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//    }
    
    
    
//    func keyboardWillShow(noticiation: NSNotification) {
//        guard let userInfo = noticiation.userInfo,
//            let keyboardHeight:CGFloat = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height,
//            let animationDuration: TimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else {return}
//        
//        
//        UIView.animate(withDuration: animationDuration) {
//            
//        }
//    }
//    
//    
//    func keyboardWillDismiss(noticiation: NSNotification) {
//        guard let userInfo = noticiation.userInfo,
//            let animationDuration: TimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else {return}
//        
//        
//        UIView.animate(withDuration: animationDuration) {
//            
//        }
//    }

}
