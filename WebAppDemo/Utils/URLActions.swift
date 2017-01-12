//
//  urlActions.swift
//
//
//  Created by Yilei He on 14/04/2016.
//  Copyright © 2016 lionhylra.com. All rights reserved.
//

import UIKit
import MessageUI
import SafariServices
import WebKit
import AVKit
import AVFoundation
import ObjectiveC
import EventKitUI

// MARK: - String -
public typealias MailControllerDelegate = MFMailComposeViewControllerDelegate

public struct StringURLActionProxy {
    fileprivate let base: String
    init(base: String) {
        self.base = base
    }
}



extension String {
    public var urlActions: StringURLActionProxy {
        return StringURLActionProxy(base: self)
    }
}



extension String {
    /**
     Check if the receiver is a valid url string
     */
    public var isValidURL:Bool {
        guard let url = URL(string: self) else {return false}
        return UIApplication.shared.canOpenURL(url)
    }
    
    
    
    /**
     Get a NSURL instance created from the receiver
     */
    public var url:URL? {
        return URL(string: self)
    }
    
    
    public var validURL: URL? {
        guard let url = URL(string: self) else {return nil}
        if UIApplication.shared.canOpenURL(url) {
            return url
        }
        return nil
    }
    
    
    
    public var fileURL:URL {
        return URL(fileURLWithPath: self)
    }
}



extension StringURLActionProxy {
    
    // MARK: url Action
    
    
    
    /**
     Open the url string in the Safari.app, this function will make user leave current application
     
     - parameter failureClosure: The closure is called if it fails to open the url string
     */
    public func openInSafari(failureClosure:(()->Void)? = nil){
        
        let address:String
        if self.base.hasPrefix("http://") || self.base.hasPrefix("https://") {
            address = self.base
        }else{
            address = "http://"+self.base
        }
        
        guard let url = address.url else {
            failureClosure?()
            return
        }
        
        url.urlActions.openInSafari(failureClosure: failureClosure)
    }
    
    
    
    
    /**
     Open the url string in a SFSafariViewController
     
     - parameter presentingViewController: The view controller used to present SFSafariViewController
     - parameter failureClosure:           If the receiver can not be converted to a NSURL, the failure closure will be called
     */
    @available(iOS 9, *)
    public func openInSafariViewController(presentingViewController:UIViewController, failureClosure:(()->Void)? = nil){
        
        let address:String
        if self.base.hasPrefix("http://") || self.base.hasPrefix("https://") {
            address = self.base
        }else{
            address = "http://"+self.base
        }
        
        guard let url = address.url else {
            failureClosure?()
            return
        }
        
        url.urlActions.openInSafariViewController(presentingViewController: presentingViewController)
        
    }
    
    
    
    
    /**
     Open the url string in a web view(WKWebView), and push the view controller to a navigation controller
     
     - parameter navigationController: The navigation controller that used to push the view controller that holds web view
     - parameter failureClosure:       If the receiver can not be converted to a NSURL, the failure closure will be called
     */
    @available(iOS 8, *)
    public func openInWebView(pushIntoNavigationController navigationController:UINavigationController,title:String? = nil, failureClosure:(()->Void)? = nil){
        
        let address:String
        if self.base.hasPrefix("http://") || self.base.hasPrefix("https://") {
            address = self.base
        }else{
            address = "http://"+self.base
        }
        
        guard let url = address.url else {
            failureClosure?()
            return
        }
        url.urlActions.openInWebView(pushIntoNavigationController: navigationController, title: title)
    }
    
    
    
    @available(iOS 8, *)
    public func openInWebView(presentingViewController:UIViewController,title:String? = nil, failureClosure:(()->Void)? = nil){
        
        let address:String
        if self.base.hasPrefix("http://") || self.base.hasPrefix("https://") {
            address = self.base
        }else{
            address = "http://"+self.base
        }
        
        guard let url = address.url else {
            failureClosure?()
            return
        }
        url.urlActions.openInWebView(presentingViewController: presentingViewController, title: title)
    }
    
    
    
    
    /**
     If the receiver is a string of phone number, this function will make user leave the application and go to Phone.app and makes a call
     
     - parameter presentingViewController: The presentingViewController is used to show a alert control to comfirm calling. If the presentingViewController is nil, then call the number without confirmation
     - parameter failureClosure:           If the Phone.app is unable to call the number, call the closure
     */
    public func call(presentingViewController:UIViewController?, failureClosure:(()->Void)? = nil){
        var phoneNumber:String
        if self.base.hasPrefix("tel://") {
            phoneNumber = self.base
        }else{
            phoneNumber = "tel://" + self.base
        }
        phoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
        
        guard let url = phoneNumber.url else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            if let presentingViewController = presentingViewController {
                let alertControl = UIAlertController(title: nil, message: "Call \(self.base)", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let callAction = UIAlertAction(title: "Call", style: .default, handler: { (action) in
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                })
                alertControl.addAction(cancelAction)
                alertControl.addAction(callAction)
                presentingViewController.present(alertControl, animated: true, completion: nil)
            } else {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }else{
            failureClosure?()
        }
    }
    
    
    
    /**
     Present a email compose view controller(MFMailComposeViewController), with receiver in the recipients field.
     
     - parameter presentingViewController: The view controller used to present the MFMailComposeViewController
     - parameter failureClosure:           If the device can not send an email, the failure closure will be called
     */
    public func sendEmail(presentingViewController:UIViewController, failureClosure:(()->Void)? = nil){
        guard MFMailComposeViewController.canSendMail() else {
            failureClosure?()
            return
        }
        
        
        let mc = MFMailComposeViewController()
        mc.setToRecipients([self.base])
        presentingViewController._sendEmailActionDelegate = {
            class MailDelegate:NSObject,MFMailComposeViewControllerDelegate{
                var failureClosure:(()->Void)?
                @objc func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
                    if let _ = error {
                        failureClosure?()
                    }
                    controller.dismiss(animated: true, completion: nil)
                    controller.presentingViewController?._sendEmailActionDelegate = nil
                }
            }
            let delegate = MailDelegate()
            delegate.failureClosure = failureClosure
            return delegate
            }()
        mc.mailComposeDelegate = presentingViewController._sendEmailActionDelegate
        
        presentingViewController.present(mc, animated: true, completion: nil)
    }

    
    
    
    /**
     Present a email compose view controller(MFMailComposeViewController), with receiver in the recipients field. The calling function must pass a retained parameter of MailControllerDelegate type to the method.
     
     Note: you do not need to instantiate the delegate reference.
     
     Example:
     ```swift
     class MyClass:UIViewController {
     var mailDelegate:MailControllerDelegate = nil
     ...
     func sendMail(){
     "example@example.com".sendNewEmail(strongDelegate:&mailDelegate, self)
     }
     }
     ```
     - parameter strongDelegate:           A reference of MailControllerDelegate type
     - parameter presentingViewController: The view controller used to present the MFMailComposeViewController
     - parameter failureClosure:           If the device can not send an email, the failure closure will be called
     */
    @available(*, deprecated, message: "Please use method \"func sendEmail(presentingViewController presentingViewController:UIViewController, failureClosure:(()->Void)? = nil)\" instead")
    public func sendNewEmail(strongDelegate:inout MailControllerDelegate?,presentingViewController:UIViewController, failureClosure:(()->Void)? = nil){
        guard MFMailComposeViewController.canSendMail() else {
            failureClosure?()
            return
        }
        
        
        let mc = MFMailComposeViewController()
        mc.setToRecipients([self.base])
        strongDelegate = {
            class MailDelegate:NSObject,MFMailComposeViewControllerDelegate{
                @objc func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
                    controller.dismiss(animated: true, completion: nil)
                }
            }
            return MailDelegate()
            }()
        mc.mailComposeDelegate = strongDelegate
        
        presentingViewController.present(mc, animated: true, completion: nil)
    }
    
    
    
    /**
     Present a email compose view controller(MFMailComposeViewController), with receiver in the recipients field. The instance of MFMailComposeViewController must be configured in the configure closure to ensure it has a delegate.
     
     - parameter configure:                The closure is passed in a MFMailComposeViewController instance to configure. The caller is responsible to set the delegate of the view controller.
     - parameter presentingViewController: The view controller that used to present the MFMailComposeViewController
     - parameter failureClosure:           If the device can not send an email, the failure closure will be called
     */
    public func sendNewEmail(configuration configure:((MFMailComposeViewController)->Void),presentingViewController:UIViewController,failureClosure:(()->Void)? = nil){
        guard MFMailComposeViewController.canSendMail() else {
            failureClosure?()
            return
        }
        let mc = MFMailComposeViewController()
        mc.setToRecipients([self.base])
        configure(mc)
        presentingViewController.present(mc, animated: true, completion: nil)
    }
    
    
    
    
    /**
     If the receiver is a youtube video url, this function initializes a view controller containing the youtube video and pushes it to the navigation controller
     
     - parameter navigationController: The navigation controller used to push the view controller that holds the video
     - parameter fullscreen:           If true, the video view will be presented full screen(Aspect Fill), else it will be presented in Aspect Fit Mode
     - parameter failureClosure:       If the receiver is not a valid youtybe url string, the failure closure will be called
     */
    @available(iOS 8, *)
    public func openAsYoutubeVideoLinkInWebView(pushIntoNavigationController navigationController:UINavigationController, fullscreen:Bool = false, failureClosure:(()->Void)? = nil){
        guard let url = self.base.url, let host = url.host, let query = url.query ,host.contains("youtube") else {
            failureClosure?()
            return
        }
        let pathComponents = url.pathComponents
        var videoId:String?
        if let idIndex = query.range(of: "v=")  {
            videoId = query.substring(from: idIndex.upperBound)
        }else if let indexOfV = pathComponents.index(of: "v"){
            videoId = pathComponents[indexOfV + 1]
        }else if let indexOfEmbed = pathComponents.index(of: "embed"){
            videoId = pathComponents[indexOfEmbed + 1]
        }
        guard let _videoId = videoId else { return }
        let embedURL = "https://www.youtube.com/embed/" + _videoId
        if fullscreen {
            embedURL.urlActions.openInWebView(pushIntoNavigationController: navigationController)
        }else{
            let vc:UIViewController = {
                class WebViewController: UIViewController,WKNavigationDelegate{
                    var url:URL?
                    lazy var loadingIndicatior = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
                    lazy var webView = WKWebView()
                    
                    convenience init(url: URL){
                        self.init()
                        self.url = url
                    }
                    
                    override func viewDidLoad() {
                        super.viewDidLoad()
                        view.backgroundColor = UIColor.white
                        automaticallyAdjustsScrollViewInsets = false
                        view.addSubview(webView)
                        view.addSubview(loadingIndicatior)
                        loadingIndicatior.startAnimating()
                        webView.navigationDelegate = self
                        if let url = self.url {
                            webView.load(URLRequest(url: url))
                        }
                    }
                    
                    override func viewDidLayoutSubviews() {
                        super.viewDidLayoutSubviews()
                        webView.frame.size.width = view.bounds.width
                        webView.frame.size.height = view.bounds.height / 3
                        webView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
                        loadingIndicatior.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
                    }
                    
                    override func didReceiveMemoryWarning() {
                        super.didReceiveMemoryWarning()
                    }
                    
                    @objc func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                        loadingIndicatior.stopAnimating()
                    }
                    @objc func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
                        loadingIndicatior.stopAnimating()
                    }
                    
                }
                
                return WebViewController(url: embedURL.url!)
            }()
            
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    
    
    @available(iOS 8, *)
    public func openAsYoutubeVideoLinkInWebView(presentingViewController:UIViewController, fullscreen:Bool = false, failureClosure:(()->Void)? = nil){
        guard let url = self.base.url, let host = url.host, let query = url.query , host.contains("youtube") else {
            failureClosure?()
            return
        }
        let pathComponents = url.pathComponents
        var videoId:String?
        if let idIndex = query.range(of: "v=")  {
            videoId = query.substring(from: idIndex.upperBound)
        }else if let indexOfV = pathComponents.index(of: "v"){
            videoId = pathComponents[indexOfV + 1]
        }else if let indexOfEmbed = pathComponents.index(of: "embed"){
            videoId = pathComponents[indexOfEmbed + 1]
        }
        guard let _videoId = videoId else { return }
        let embedURL = "https://www.youtube.com/embed/" + _videoId
        if fullscreen {
            embedURL.urlActions.openInWebView(presentingViewController: presentingViewController)
        }else{
            let vc:UIViewController = {
                class WebViewController: UIViewController,WKNavigationDelegate{
                    var url: URL?
                    lazy var loadingIndicatior = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
                    lazy var webView = WKWebView()
                    
                    convenience init(url: URL){
                        self.init()
                        self.url = url
                    }
                    
                    override func viewDidLoad() {
                        super.viewDidLoad()
                        view.backgroundColor = UIColor.white
                        automaticallyAdjustsScrollViewInsets = false
                        view.addSubview(webView)
                        view.addSubview(loadingIndicatior)
                        loadingIndicatior.startAnimating()
                        webView.navigationDelegate = self
                        if let url = self.url {
                            webView.load(URLRequest(url: url))
                        }
                        
                        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
                    }
                    
                    override func viewDidLayoutSubviews() {
                        super.viewDidLayoutSubviews()
                        webView.frame.size.width = view.bounds.width
                        webView.frame.size.height = view.bounds.height / 3
                        webView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
                        loadingIndicatior.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
                    }
                    
                    override func didReceiveMemoryWarning() {
                        super.didReceiveMemoryWarning()
                    }
                    
                    @objc func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                        loadingIndicatior.stopAnimating()
                    }
                    @objc func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
                        loadingIndicatior.stopAnimating()
                    }
                    
                    @objc func doneTapped(){
                        navigationController?.dismiss(animated: true, completion: nil)
                    }
                }
                
                return WebViewController(url: embedURL.url!)
            }()
            let navigationControler = UINavigationController(rootViewController: vc)
            presentingViewController.present(navigationControler, animated: true, completion: nil)
        }
    }

    
    
    /**
     If the receiver is a url for a video, then present a AVPlayerViewController to play it
     
     - parameter presentingViewController: The view controller used to present the AVPlayerViewController
     */
    public func playVideo(presentingViewController:UIViewController) {
        guard let url = self.base.url else {return}
        url.urlActions.playVideo(presentingViewController: presentingViewController)
    }
}



public struct URL_URLActionsProxy {
    fileprivate var base: URL
    init(base: URL) {
        self.base = base
    }
}



extension URL {
    public var urlActions: URL_URLActionsProxy {
        return URL_URLActionsProxy(base: self)
    }
}



// MARK: - NSURL -
extension URL_URLActionsProxy {
    /**
     Open the receiver in the Safari.app. This will make user leave the current application.
     
     - parameter failureClosure: If Safari.app can not open the NSURL, call the failure closure
     */
    func openInSafari(failureClosure:(()->Void)? = nil){
        
        if UIApplication.shared.canOpenURL(self.base) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(self.base)
            } else {
                UIApplication.shared.openURL(self.base)
            }
        }else{
            failureClosure?()
        }
    }
    
    
    
    
    /**
     Open the receiver in the instance of SFSafariViewController.
     
     - parameter presentingViewController: The view controller used to present the SFSafariViewController
     */
    @available(iOS 9, *)
    func openInSafariViewController(presentingViewController:UIViewController){
        
        let safariViewController = SFSafariViewController(url: self.base)
        presentingViewController.present(safariViewController, animated: true, completion: nil)
        
    }
    
    
    
    
    /**
     Open the receiver in a WKWebView.
     
     - parameter navigationController: The navigation controller used to push the view controller that holds the web view.
     - parameter isLocalFile:          If true, the file url should be a NSURL for local file
     */
    @available(iOS 8, *)
    func openInWebView(pushIntoNavigationController navigationController:UINavigationController, title:String? = nil, isLocalFile:Bool = false){
        
        let vc:UIViewController = {
            class WebViewController: UIViewController, WKNavigationDelegate {
                var url:URL?
                var webView:WKWebView?
                var isLocalFile:Bool = false
                var activityIndicator:UIActivityIndicatorView!
                
                convenience init(url:URL, loadLocalFile:Bool){
                    self.init()
                    self.url = url
                    self.isLocalFile = loadLocalFile
                }
                
                override func loadView() {
                    super.loadView()
                    webView = WKWebView()
                    view = webView
                    activityIndicator = UIActivityIndicatorView()
                    activityIndicator.activityIndicatorViewStyle = .gray
                    activityIndicator.hidesWhenStopped = true
                    activityIndicator.startAnimating()
                }
                
                override func viewDidLoad() {
                    super.viewDidLoad()
                    webView?.navigationDelegate = self
                    view.addSubview(activityIndicator)
                    if let url = self.url, let webView = webView {
                        if isLocalFile{
                            webView.loadFileURL(url, allowingReadAccessTo: url)
                        }else{
                            webView.load(URLRequest(url: url))
                        }
                    }
                }
                
                override func didReceiveMemoryWarning() {
                    super.didReceiveMemoryWarning()
                }
                
                
                override func viewDidLayoutSubviews() {
                    super.viewDidLayoutSubviews()
                    activityIndicator.center = view.center
                }
                
                
                @objc fileprivate func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                    activityIndicator.stopAnimating()
                }
                
                
                @objc fileprivate func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
                    activityIndicator.stopAnimating()
                }
                
            }
            
            let vc = WebViewController(url: self.base, loadLocalFile: isLocalFile)
            vc.title = title
            return vc
        }()
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    
    
    @available(iOS 8, *)
    func openInWebView(presentingViewController:UIViewController,title:String? = nil, isLocalFile:Bool = false){
        
        let vc:UIViewController = {
            class WebViewController: UIViewController, WKNavigationDelegate {
                var url:URL?
                var webView:WKWebView?
                var isLocalFile:Bool = false
                var activityIndicator:UIActivityIndicatorView!
                
                convenience init(url:URL, loadLocalFile:Bool){
                    self.init()
                    self.url = url
                    self.isLocalFile = loadLocalFile
                }
                
                override func loadView() {
                    super.loadView()
                    webView = WKWebView()
                    view = webView
                    activityIndicator = UIActivityIndicatorView()
                    activityIndicator.activityIndicatorViewStyle = .gray
                    activityIndicator.hidesWhenStopped = true
                    activityIndicator.startAnimating()
                    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
                }
                
                override func viewDidLoad() {
                    super.viewDidLoad()
                    webView?.navigationDelegate = self
                    view.addSubview(activityIndicator)
                    if let url = self.url, let webView = webView {
                        if isLocalFile{
                            webView.loadFileURL(url, allowingReadAccessTo: url)
                        }else{
                            webView.load(URLRequest(url: url))
                        }
                    }
                }
                
                override func didReceiveMemoryWarning() {
                    super.didReceiveMemoryWarning()
                }
                
                
                override func viewDidLayoutSubviews() {
                    super.viewDidLayoutSubviews()
                    activityIndicator.center = view.center
                }
                
                
                @objc fileprivate func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                    activityIndicator.stopAnimating()
                }
                
                
                @objc fileprivate func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
                    activityIndicator.stopAnimating()
                }
                
                
                @objc func doneTapped(){
                    navigationController?.dismiss(animated: true, completion: nil)
                }
                
            }
            
            return WebViewController(url: self.base, loadLocalFile: isLocalFile)
        }()
        let navigationController = UINavigationController(rootViewController: vc)
        vc.title = title
        presentingViewController.present(navigationController, animated: true, completion: nil)
    }

    
    
    
    /**
     If the receiver is a url for a video, then present a AVPlayerViewController to play it
     
     - parameter presentingViewController: The view controller used to present the AVPlayerViewController
     */
    func playVideo(presentingViewController: UIViewController){
        let playerViewController = AVPlayerViewController()
        let player = AVPlayer(url: self.base)
        playerViewController.player = player
        presentingViewController.present(playerViewController, animated: true, completion: nil)
        player.play()
    }
    
    
    
    /**
     Preview a document
     */
    func previewDocument(presentingViewController:UIViewController){
        let vc = UIDocumentInteractionController(url: self.base)
        presentingViewController._previewDocumentInteractionController = vc
        presentingViewController._previewDocumentDelegate = {
            class PreviewDelegate:NSObject, UIDocumentInteractionControllerDelegate{
                unowned var presentingViewController:UIViewController
                init(presentingViewController:UIViewController){
                    self.presentingViewController = presentingViewController
                }
                @objc func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
                    return presentingViewController
                }
                @objc func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
                    presentingViewController._previewDocumentDelegate = nil
                    presentingViewController._previewDocumentInteractionController = nil
                }
            }
            return PreviewDelegate(presentingViewController:presentingViewController)
        }()
        vc.delegate = presentingViewController._previewDocumentDelegate
        vc.presentPreview(animated: true)
    }
    
    
    
    /**
     show document options
     */
    func showDocumentOptionsFromRect(_ rect:CGRect, inView view:UIView, presentingViewController:UIViewController){
        let vc = UIDocumentInteractionController(url: self.base)
        presentingViewController._previewDocumentInteractionController = vc
        presentingViewController._previewDocumentDelegate = {
            class PreviewDelegate:NSObject, UIDocumentInteractionControllerDelegate{
                unowned var presentingViewController:UIViewController
                init(presentingViewController:UIViewController){
                    self.presentingViewController = presentingViewController
                }
                @objc func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
                    return presentingViewController
                }
                @objc func documentInteractionControllerDidDismissOptionsMenu(_ controller: UIDocumentInteractionController) {
                    presentingViewController._previewDocumentDelegate = nil
                    presentingViewController._previewDocumentInteractionController = nil
                }
                @objc func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
                    return presentingViewController.view
                }
            }
            return PreviewDelegate(presentingViewController:presentingViewController)
            }()
        vc.delegate = presentingViewController._previewDocumentDelegate
        vc.presentOptionsMenu(from: rect, in: view, animated: true)
    }
    
    
    /**
     show document options
     */
    func showDocumentOptionsFromBarButtonItem(_ item:UIBarButtonItem, presentingViewController:UIViewController){
        let vc = UIDocumentInteractionController(url: self.base)
        presentingViewController._previewDocumentInteractionController = vc
        presentingViewController._previewDocumentDelegate = {
            class PreviewDelegate:NSObject, UIDocumentInteractionControllerDelegate{
                unowned var presentingViewController:UIViewController
                init(presentingViewController:UIViewController){
                    self.presentingViewController = presentingViewController
                }
                @objc func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
                    return presentingViewController
                }
                @objc func documentInteractionControllerDidDismissOptionsMenu(_ controller: UIDocumentInteractionController) {
                    presentingViewController._previewDocumentDelegate = nil
                    presentingViewController._previewDocumentInteractionController = nil
                }
            }
            return PreviewDelegate(presentingViewController:presentingViewController)
            }()
        vc.delegate = presentingViewController._previewDocumentDelegate
        vc.presentOptionsMenu(from: item, animated: true)
    }
    
    
    /**
     show open in menu
     */
    func showDocumentOpenInMenuFromRect(_ rect:CGRect, inView view:UIView, presentingViewController:UIViewController){
        let vc = UIDocumentInteractionController(url: self.base)
        presentingViewController._previewDocumentInteractionController = vc
        presentingViewController._previewDocumentDelegate = {
            class PreviewDelegate:NSObject, UIDocumentInteractionControllerDelegate{
                unowned var presentingViewController:UIViewController
                init(presentingViewController:UIViewController){
                    self.presentingViewController = presentingViewController
                }
                @objc func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
                    return presentingViewController
                }
                @objc func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
                    presentingViewController._previewDocumentDelegate = nil
                    presentingViewController._previewDocumentInteractionController = nil
                }
                @objc func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
                    return presentingViewController.view
                }


            }
            return PreviewDelegate(presentingViewController:presentingViewController)
            }()
        vc.delegate = presentingViewController._previewDocumentDelegate
        vc.presentOpenInMenu(from: rect, in: view, animated: true)
    }
    
    
    /**
     show open in menu
     */
    func showDocumentOpenInMenuFromBarButtonItem(_ item:UIBarButtonItem, presentingViewController:UIViewController){
        let vc = UIDocumentInteractionController(url: self.base)
        presentingViewController._previewDocumentInteractionController = vc
        presentingViewController._previewDocumentDelegate = {
            class PreviewDelegate:NSObject, UIDocumentInteractionControllerDelegate{
                unowned var presentingViewController:UIViewController
                init(presentingViewController:UIViewController){
                    self.presentingViewController = presentingViewController
                }
                @objc func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
                    return presentingViewController
                }
                @objc func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
                    presentingViewController._previewDocumentDelegate = nil
                    presentingViewController._previewDocumentInteractionController = nil
                }
            }
            return PreviewDelegate(presentingViewController:presentingViewController)
            }()
        vc.delegate = presentingViewController._previewDocumentDelegate
        vc.presentOpenInMenu(from: item, animated: true)
    }
}



// MARK: - UIViewController
extension UIViewController {
    
    /**
     Load a local html file in the bundle
     
     - parameter filePath: The path string for the html file
     */
    func loadHTMLFile(filePath:String){
        if let navigationController = self.navigationController {
            URL(fileURLWithPath: filePath).urlActions.openInWebView(pushIntoNavigationController: navigationController, isLocalFile: true)
        }else{
            URL(fileURLWithPath: filePath).urlActions.openInWebView(presentingViewController: self, isLocalFile: true)
        }
    }
    
    
    
    /**
     Share items such as Text, Image, url, File, UIActivityItemSource or UIActivityItemProvider
     
     - parameter sharedItems: array of items
     */
    func share(items:Any...) {
        share(items: items)
    }
    
    
    
    func share(items:[Any]) {
        if items.count == 0 { return }
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    
    /**
     Add Event to calendar
     
     - parameter configuration:       configure the event here
     - parameter authorizationDenied: The closure is called when authorization is denied
     */
    func addNewEventToCalendar(configuration:@escaping ((EKEvent)->Void), authorizationDenied:(()->Void)?, didDisplayViewController:(()->Void)? = nil){
        let eventStore = EKEventStore()
        let addEventToCalendar = {
            /* Create EventEditViewController */
            let vc = EKEventEditViewController()
            vc.eventStore = eventStore
            self._eventEditViewDelegate = {
                class CalendarEventDelegate:NSObject, EKEventEditViewDelegate {
                    weak var vc:EKEventEditViewController!
                    init(eventEditViewController:EKEventEditViewController) {
                        self.vc = eventEditViewController
                        super.init()
                    }
                    @objc func eventEditViewControllerDefaultCalendar(forNewEvents controller: EKEventEditViewController) -> EKCalendar {
                        return vc.eventStore.defaultCalendarForNewEvents
                    }
                    @objc func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
                        vc.dismiss(animated: true, completion: nil)
                        vc.presentingViewController?._eventEditViewDelegate = nil
                    }
                }
                return CalendarEventDelegate(eventEditViewController:vc)
                
            }()
            vc.editViewDelegate = self._eventEditViewDelegate
            /* add event */
            let event = EKEvent(eventStore: vc.eventStore)
//            event.startDate = NSDate()//Setting default date, otherwise it breaks the app
//            event.endDate = event.startDate.dateByAddingTimeInterval(3600)
            configuration(event)
            vc.event = event
            
            /* Present ViewController */
            self.present(vc, animated: true, completion: didDisplayViewController)
        }
        
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            eventStore.requestAccess(to: .event, completion: { (granted, error) -> Void in
                if granted {
                    addEventToCalendar()
                }
            })
        case .denied:
            authorizationDenied?()
        default:
            addEventToCalendar()
        }
    }
}



// MARK: Extension for Send Email Action
private var _sendEmailActionDelegateAssociationKey: Int = 0
extension UIViewController {
    fileprivate var _sendEmailActionDelegate:MFMailComposeViewControllerDelegate! {
        get{
            return objc_getAssociatedObject(self, &_sendEmailActionDelegateAssociationKey) as? MFMailComposeViewControllerDelegate
        }
        set{
            objc_setAssociatedObject(self, &_sendEmailActionDelegateAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}
// MARK: Extension for adding event to calendar
private var _eventEditViewDelegateAssociationKey: Int = 0
extension UIViewController {
    fileprivate var _eventEditViewDelegate:EKEventEditViewDelegate! {
        get{
            return objc_getAssociatedObject(self, &_eventEditViewDelegateAssociationKey) as? EKEventEditViewDelegate
        }
        set{
            objc_setAssociatedObject(self, &_eventEditViewDelegateAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

// MARK: Extension for preview a document
private var _previewDocumentDelegateAssociationKey: Int = 0
private var _previewDocumentInteractionControllerAssociationKey: Int = 0
extension UIViewController {
    fileprivate var _previewDocumentDelegate: UIDocumentInteractionControllerDelegate! {
        get {
            return objc_getAssociatedObject(self, &_previewDocumentDelegateAssociationKey) as? UIDocumentInteractionControllerDelegate
        }
        set{
            objc_setAssociatedObject(self, &_previewDocumentDelegateAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    fileprivate var _previewDocumentInteractionController: UIDocumentInteractionController! {
        get{
            return objc_getAssociatedObject(self, &_previewDocumentInteractionControllerAssociationKey) as? UIDocumentInteractionController
        }
        set{
            objc_setAssociatedObject(self, &_previewDocumentInteractionControllerAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}


