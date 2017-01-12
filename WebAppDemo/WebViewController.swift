//
//  ViewController.swift
//  WebAppDemo
//
//  Created by Yilei He on 1/12/16.
//  Copyright © 2016 Yilei He. All rights reserved.
//

import UIKit
import WebKit



class WebViewController: UIViewController {
    var urlString: String?
    var webView: WKWebView!
    var halEngine: HALEngine!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        webView = WKWebView()
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        var constraints: [NSLayoutConstraint] = []
        constraints.append(NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: webView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0))
        NSLayoutConstraint.activate(constraints)
        
        webView.uiDelegate = self
        webView.configuration.userContentController.add(self, name: "swiftJSHandler")
        halEngine = HALEngine(viewController: self, webView: webView)
        
//        if let url = urlString?.validURL {
//            webView.load(URLRequest(url: url))
//        }
        
        if let fileURL = Bundle.main.url(forResource: "scanButton", withExtension: "html") {
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(timeout), name: didDetectIdleStatusNotification, object: nil)
    }
    
    
    
    func timeout() {
        if presentedViewController != nil {
            dismiss(animated: true, completion: nil)
        }
        self.webView.evaluateJavaScript("rc_hal.triggerEvent(\"Timeout\");") { (result, error) in
            print(result as Any, error?.localizedDescription as Any)
        }
    }


}

extension WebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        
        print(message.body)
        guard let json = message.body as? [String: Any] else {return}
        halEngine.handle(task: json)
    }

}


extension WebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        if presentedViewController != nil {
            completionHandler()
            return
        }
        showAlert(title: nil, message: message, actionTitle: "OK")
        completionHandler()
    }
}

