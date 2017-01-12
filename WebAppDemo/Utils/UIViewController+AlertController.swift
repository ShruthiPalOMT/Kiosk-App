//
//  UIViewController+AlertController.swift
//
//
//  Created by HeYilei on 23/09/2015.
//  Copyright © 2015 HeYilei. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /**
     Shows an alert view displaying title and message
     */
    func showAlert(title:String?, message:String?, actionTitle:String? = "OK", actionHandler:((UIAlertAction)->Void)? = nil){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.cancel, handler: actionHandler)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    /**
     Shows an alert view displaying the loaclized description of a NSError object
     
     - parameter title: title used for alert view
     - parameter error: NSError object
     */
    func showAlert(title:String?, error:NSError?){
        showAlert(title: title, message: error?.localizedDescription)
    }
    
    
    
    func showConfirmAlert(title:String?, message:String?, cancelButtonTitle:String? = "Cancel", confirmButtonTitle:String? = "OK",reverseButtonOrder:Bool = false, cancelActionHandler:((UIAlertAction)->Void)?, confirmActionHandler:((UIAlertAction)->Void)?){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: UIAlertActionStyle.cancel, handler: cancelActionHandler)
        let confirmAction = UIAlertAction(title: confirmButtonTitle, style: UIAlertActionStyle.default, handler: confirmActionHandler)
        if reverseButtonOrder {
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
        }else{
            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)
        }
        self.present(alertController, animated: true, completion: nil)
    }
}



// MARK: - Another Design -
extension UIViewController {
    func showConfirmAlert(title:String?, message:String?) -> ConfirmAlertControllerSetter {
        return ConfirmAlertControllerSetter(viewController:self, title: title, message: message)
    }
}


class ConfirmAlertControllerSetter:NSObject {
    enum ActionType {
        case confirm
        case cancel
    }
    private let viewController: UIViewController
    private var title:String?
    private var message:String?
    private var cancelButtonTitle:String? = "Cancel"
    private var confirmButtonTitle:String? = "OK"
    private var cancelActionHandler:((UIAlertAction)->Void)?
    private var confirmActionHandler:((UIAlertAction)->Void)?
    private var preferredAction:ActionType = .cancel
    
    fileprivate init(viewController:UIViewController, title: String?, message: String?){
        self.viewController = viewController
        self.title = title
        self.message = message
    }
    
    func setButtonTitle(cancelButtonTitle:String?, confirmButtonTitle:String?) -> ConfirmAlertControllerSetter {
        self.cancelButtonTitle = cancelButtonTitle
        self.confirmButtonTitle = confirmButtonTitle
        return self
    }
    
    func setCancelActionHandler(_ cancelActionHandler:((UIAlertAction)->Void)?) -> ConfirmAlertControllerSetter {
        self.cancelActionHandler = cancelActionHandler
        return self
    }
    
    func setConfirmActionHandler(_ confirmActionHandler:((UIAlertAction)->Void)?) -> ConfirmAlertControllerSetter {
        self.confirmActionHandler = confirmActionHandler
        return self
    }
    
    func setPreferredAction(_ action:ActionType) -> ConfirmAlertControllerSetter {
        self.preferredAction = action
        return self
    }
    
    deinit{
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: UIAlertActionStyle.cancel, handler: cancelActionHandler)
        let confirmAction = UIAlertAction(title: confirmButtonTitle, style: UIAlertActionStyle.default, handler: confirmActionHandler)
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        switch preferredAction {
        case .cancel:
            alertController.preferredAction = cancelAction
        case .confirm:
            alertController.preferredAction = confirmAction
        }
        viewController.present(alertController, animated: true, completion: nil)
    }
}
