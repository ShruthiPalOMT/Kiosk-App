//
//  KeyboardAvoidingView.swift
//  WebAppDemo
//
//  Created by Yilei He on 6/12/16.
//  Copyright © 2016 Yilei He. All rights reserved.
//

import UIKit

open class YHKeyboardAvoidingView: UIView {
    @IBOutlet open var focusedView: UIView?
    open var offset: CGFloat = 8
    private var _originY: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(KAKeyboardWillShow(noticiation:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KAKeyboardWillDismiss(noticiation:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    open override func didMoveToSuperview() {
        _originY = frame.origin.y
    }
    
    
    
    func KAKeyboardWillShow(noticiation: NSNotification) {
        guard let userInfo = noticiation.userInfo,
            let keyboardHeight:CGFloat = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height,
            let animationDuration: TimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else {return}
        
        if let focusedView = focusedView {
            if focusedView.frame.maxY < bounds.height - keyboardHeight {
                return
            } else {
                UIView.animate(withDuration: animationDuration) {
                    self.frame.origin.y = self._originY - (focusedView.frame.maxY - (self.bounds.height - keyboardHeight) + self.offset)
                }
            }
        }else{
            UIView.animate(withDuration: animationDuration) {
                self.frame.origin.y = self._originY - keyboardHeight
            }
        }
        
    }
    
    
    func KAKeyboardWillDismiss(noticiation: NSNotification) {
        guard let userInfo = noticiation.userInfo,
            let animationDuration: TimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else {return}
        
        
        UIView.animate(withDuration: animationDuration) {
            self.frame.origin.y = self._originY
        }
    }
}
