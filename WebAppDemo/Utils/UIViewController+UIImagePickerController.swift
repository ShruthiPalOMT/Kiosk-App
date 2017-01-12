//
//  UIViewController+UIImagePickerController.swift
//  Swift3Project
//
//  Created by Yilei He on 8/12/16.
//  Copyright © 2016 lionhylra.com. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

private var delegateObject_associationKey = 0

public enum PickImageExtensionError: Error {
    case sourceTypeNotSupported(UIImagePickerControllerSourceType)
    case mediaTypeNotSupported(String)
    
    public var localizedDescription: String {
        switch self {
        case .sourceTypeNotSupported(let sourceType):
            return "Source type \(sourceType) not supported by device."
        case .mediaTypeNotSupported(let mediaType):
            return "Media type \(mediaType) not supported by device."
        }
    }
}


extension UIViewController {
    private var _imagePickerDelegateObject: UIImagePickerControllerDelegate & UINavigationControllerDelegate! {
        get {
            return objc_getAssociatedObject(self, &delegateObject_associationKey) as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        }
        set {
            objc_setAssociatedObject(self, &delegateObject_associationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    public func pickImage(from source: UIImagePickerControllerSourceType,
                          cameraDevice: UIImagePickerControllerCameraDevice = .rear,
                          allowEditing:Bool = false,
                          completion: @escaping (_ originalImage: UIImage?, _ editedImage: UIImage?, _ livePhoto: PHLivePhoto?, _ metadata: [String: Any]?)->Void) throws {
        
        if source != .camera && UIDevice.current.userInterfaceIdiom == .pad {
            preconditionFailure("This method only support .camera source type on ipad.")
        }
        
        if self._imagePickerDelegateObject == nil {
            _imagePickerDelegateObject = {
                class _InnerImagePickerDelegate:NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
                    
                    var completionHandler: ((_ originalImage: UIImage?, _ editedImage: UIImage?, _ livePhoto: PHLivePhoto?, _ metadata: [String: Any]?)->Void)!
                    
                    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
                        let original = info[UIImagePickerControllerOriginalImage] as? UIImage
                        let edited = info[UIImagePickerControllerEditedImage] as? UIImage
                        let livePhoto = info[UIImagePickerControllerLivePhoto] as? PHLivePhoto
                        let metadata = info[UIImagePickerControllerMediaMetadata] as? [String: Any]
                        picker.dismiss(animated: true, completion: {
                            self.completionHandler(original, edited, livePhoto, metadata)
                        })
                    }
                    
                    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                        picker.dismiss(animated: true, completion: nil)
                    }
                }
                let delegate = _InnerImagePickerDelegate()
                delegate.completionHandler = completion
                return delegate
            }()
        }
        
        let vc = UIImagePickerController()
        guard UIImagePickerController.isSourceTypeAvailable(source) else {
            throw PickImageExtensionError.sourceTypeNotSupported(source)
        }
        vc.sourceType = source
        guard let availableTypes = UIImagePickerController.availableMediaTypes(for: source) else {return}
        guard availableTypes.contains(kUTTypeImage as String) else {
            throw PickImageExtensionError.mediaTypeNotSupported(kUTTypeImage as String)
        }
        vc.mediaTypes = [kUTTypeImage as String, kUTTypeLivePhoto as String]
        vc.allowsEditing = allowEditing
        vc.cameraDevice = cameraDevice
        vc.delegate = self._imagePickerDelegateObject
        vc.showsCameraControls = false
        let label = UILabel()
        label.textColor = UIColor.white
        label.frame.size = CGSize(width: 100, height: 50)
        label.frame.origin.y = UIScreen.main.bounds.height - 55
        label.frame.centerX = UIScreen.main.bounds.centerX
        label.font = UIFont.systemFont(ofSize: 50, weight: UIFontWeightMedium)
//        label.layer.shadowColor = UIColor.black
        label.layer.shadowRadius = 3
        label.layer.shadowOpacity = 0.5
        vc.cameraOverlayView = label
        present(vc, animated: true) {
            if #available(iOS 10.1, *) {
//                vc.cameraViewTransform = CGAffineTransform(translationX: 0, y: 50)
            }
            YHCountDownTimer(initialTime: 3, interval: 1, fireImmediately: true, readDidChange: { (timeInterval) in
                label.text = String(Int(timeInterval))
                if timeInterval == 0 {
                    vc.takePicture()
                }
            })
        }
    }
}
