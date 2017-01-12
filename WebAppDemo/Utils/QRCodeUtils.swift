//
//  QRCodeUtils.swift
//  Swift3Project
//
//  Created by Yilei He on 25/11/16.
//  Copyright © 2016 lionhylra.com. All rights reserved.
//

import UIKit
import CoreImage
import AVFoundation



public struct BarCodeUtils {
    private init() {}
    
    
    /// Generate QRCode from data
    ///
    /// - Parameters:
    ///   - inputData: input data
    ///   - size: image size
    /// - Returns: A CoreImage CIImage instance
    public static func qrCodeImage(inputData: Data, size: CGSize) -> CIImage? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {return nil}
        filter.setValue(inputData, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")
        
        guard let qrcodeImage = filter.outputImage else {return nil}
        let scaleX = size.width / qrcodeImage.extent.width
        let scaleY = size.height / qrcodeImage.extent.height
        let resultImage = qrcodeImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
        return resultImage
    }
    
    
    
    /// Read QRCode from an image
    ///
    /// - Parameter image: input image
    /// - Returns: QRCode message
    public static func scanQRCode(in image: CIImage) -> String? {
        guard let detecor = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) else {return nil}
        
        let features = detecor.features(in: image)
        guard let qrfeature = features.first as? CIQRCodeFeature else {return nil}
        return qrfeature.messageString
    }
    
    
    
    
    public static func scanQRCode(presentingViewController: UIViewController, message: String = "Please place the QR code into the frame above", cameraPosition: CameraPosition = .back, completionHandler: ((String)->Void)?) {
        scanBarCode(presentingViewController: presentingViewController, targetMetadataObjectTypes: [AVMetadataObjectTypeQRCode], message: message, cameraPosition: cameraPosition, completionHandler: completionHandler)
    }
    
    
    
    public static func scanBarCode(presentingViewController: UIViewController,targetMetadataObjectTypes:[String]? = nil,  message: String = "Please place the bar code into the frame above", cameraPosition: CameraPosition = .back, completionHandler: ((String)->Void)?) {
        let vc = BarCodeScannerViewController()
        vc.message = message
        vc.completionHandler = completionHandler
        vc.targetMetadataObjectTypes = targetMetadataObjectTypes
        vc.cameraPosition = cameraPosition
        presentingViewController.present(vc, animated: true, completion: nil)
    }
    
}

public typealias CameraPosition = AVCaptureDevicePosition

open class BarCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    private lazy var captureSession:AVCaptureSession = AVCaptureSession()
    private lazy var videoPreviewLayer:AVCaptureVideoPreviewLayer = {
        return AVCaptureVideoPreviewLayer(session: self.captureSession)
    }()
    public var completionHandler: ((String)->Void)?
    public var message: String?
    public var targetMetadataObjectTypes: [String]! = nil
    public var cameraPosition: CameraPosition = .back
    
    private var hasError = false
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        /* Setup device */
        let captureDevice: AVCaptureDevice?
        if #available(iOS 10.0, *) {
            if let device = AVCaptureDevice.defaultDevice(withDeviceType: AVCaptureDeviceType.builtInDuoCamera, mediaType: AVMediaTypeVideo, position: cameraPosition) {
                captureDevice = device
            } else if let device = AVCaptureDevice.defaultDevice(withDeviceType: AVCaptureDeviceType.builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: cameraPosition) {
                captureDevice = device
            } else {
                captureDevice = nil
            }
        } else {
            captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        }
        guard let _ = captureDevice else {
            print("Failed to get AVCaptureDevice", #file, #line)
            hasError = true
            return
        }
        
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("Failed to get AVCaptureDeviceInput", #file, #line)
            hasError = true
            return
        }
        captureSession.addInput(input)
        
        /* setup output metadata */
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        if targetMetadataObjectTypes == nil {
            targetMetadataObjectTypes = captureMetadataOutput.availableMetadataObjectTypes as! [String]
        }
        captureMetadataOutput.metadataObjectTypes = targetMetadataObjectTypes!.filter({ (typeString) -> Bool in
            return captureMetadataOutput.availableMetadataObjectTypes.contains(where: { (type) -> Bool in
                if let str = type as? String {
                    return str == typeString
                }else{
                    return false
                }
            })
        })
        
        
        //        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeUPCECode]
        
        
        /* setup camera */
        videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer.frame = view.layer.frame
        view.layer.addSublayer(videoPreviewLayer)
        
        defer{captureSession.startRunning()}
        
        
        /* Constraints */
        var constraints: [NSLayoutConstraint] = []
        defer {NSLayoutConstraint.activate(constraints)}
        
        /* setup ouverlay */
        let overlay:UIView = /*UIView(frame: view.frame)*/ {
            class Inner_OverlayView: UIView {
                override func layoutSubviews() {
                    super.layoutSubviews()
                    let size = min(bounds.height, bounds.width) - 16
                    var maskRect = CGRect(origin: CGPoint.zero, size: CGSize(width: size, height: size))
                    maskRect.origin.x = bounds.midX - maskRect.width / 2
                    maskRect.origin.y = bounds.midY - maskRect.height / 2
                    let maskPath = UIBezierPath(rect: bounds)
                    let removeMaskPath = UIBezierPath(rect: maskRect).reversing()
                    maskPath.append(removeMaskPath)
                    
                    let maskLayer = CAShapeLayer()
                    maskLayer.path = maskPath.cgPath
                    layer.mask = maskLayer
                }
            }
            return Inner_OverlayView(frame: view.frame)
        }()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.addSubview(overlay)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(NSLayoutConstraint(item: overlay, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: overlay, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: overlay, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: overlay, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
        
        
        
        /* cancel button */
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(NSLayoutConstraint(item: cancelButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leadingMargin, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: cancelButton, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 8))
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        
        /* instruction label */
        let label = UILabel()
        label.text = message
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.layer.shadowOpacity = 0.5
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: -8))
        constraints.append(NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: -16))
        
        
        if videoPreviewLayer.connection.isVideoOrientationSupported {
            switch UIDevice.current.orientation {
            case .landscapeLeft:
                videoPreviewLayer.connection.videoOrientation = .landscapeRight
            case .landscapeRight:
                videoPreviewLayer.connection.videoOrientation = .landscapeLeft
            case .portrait:
                videoPreviewLayer.connection.videoOrientation = .portrait
            case .portraitUpsideDown:
                videoPreviewLayer.connection.videoOrientation = .portraitUpsideDown
            default:
                break
            }
        }

        
    }
    
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if hasError {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer.frame = view.layer.frame
    }
    
    
    
//    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.willTransition(to: newCollection, with: coordinator)
//        if videoPreviewLayer.connection.isVideoOrientationSupported {
//            switch UIDevice.current.orientation {
//            case .landscapeLeft:
//                videoPreviewLayer.connection.videoOrientation = .landscapeRight
//            case .landscapeRight:
//                videoPreviewLayer.connection.videoOrientation = .landscapeLeft
//            case .portrait:
//                videoPreviewLayer.connection.videoOrientation = .portrait
//            case .portraitUpsideDown:
//                videoPreviewLayer.connection.videoOrientation = .portraitUpsideDown
//            default:
//                break
//            }
//        }
//    }
    
    
    
    open override var shouldAutorotate: Bool {
        return false
    }
    
    
    
    func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        //        let targetTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeUPCECode]
        
        if let metaObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject, targetMetadataObjectTypes.contains(metaObject.type) && metaObject.stringValue != nil {
            dismiss(animated: true, completion: {
                self.completionHandler?(metaObject.stringValue)
            })
        }
    }
}



// MARK: - Interfaces(Extensions) -

extension String {
    public func qrCodeImage(size: CGSize) -> UIImage? {
        guard let data = self.data(using: .isoLatin1, allowLossyConversion: false),
            let ciimage = BarCodeUtils.qrCodeImage(inputData: data, size: size) else {return nil}
        //return UIImage(ciImage: ciimage)//the generated UIImage cannot be converted to NSData, which means the image can't be saved to album or be shared
        let context = CIContext()
        guard let cgimage = context.createCGImage(ciimage, from: ciimage.extent) else {return nil}
        return UIImage(cgImage: cgimage)
    }
}



extension URL {
    public func qrCodeImage(size: CGSize) -> UIImage? {
        return absoluteString.qrCodeImage(size: size)
    }
}



extension UIViewController {
    public func scanQRCode(message: String = "Please place the QR code into the frame above", cameraPosition: CameraPosition = .back, completionHandler: ((String)->Void)?) {
        BarCodeUtils.scanQRCode(presentingViewController: self, message: message, cameraPosition: cameraPosition, completionHandler: completionHandler)
    }
}



extension UIImage {
    public var qrCodeMessage: String? {
        guard let ciimage = CIImage(image: self) else {return nil}
        return BarCodeUtils.scanQRCode(in: ciimage)
    }
}

