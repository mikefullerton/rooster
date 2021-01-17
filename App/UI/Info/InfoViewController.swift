//
//  InfoViewController.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/16/21.
//

import Foundation
import UIKit
import WebKit

class InfoViewController : UIViewController, WKNavigationDelegate {
    
    private lazy var webViewConfig = WKWebViewConfiguration()
    private lazy var webView = WKWebView(frame: CGRect.zero, configuration: self.webViewConfig)
    private lazy var topBar = TopBar(frame: CGRect.zero)
    private lazy var bottomBar = BottomBar(frame: CGRect.zero)
        
//    init() {
//        super.init(frame: CGRect.zero)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addWebview()
        self.topBar.addToView(self.view)
        self.bottomBar.addToView(self.view)
        self.topBar.addTitleView(withText: "About")
        self.bottomBar.doneButton.addTarget(self, action: #selector(doneButtonPressed(_:)), for: .touchUpInside)
    
        self.webView.scrollView.contentInset = UIEdgeInsets(top: self.topBar.intrinsicContentSize.height,
                                              left: 0,
                                              bottom: self.bottomBar.intrinsicContentSize.height,
                                              right: 0)

        self.webView.scrollView.contentOffset = CGPoint(x: 0, y: -self.topBar.intrinsicContentSize.height)

    }
    
    @objc func doneButtonPressed(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    func addWebview() {
        
        
        let webview = self.webView
        webview.navigationDelegate = self
        
        self.view.addSubview(webview)
        
        webview.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            webview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            webview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            webview.topAnchor.constraint(equalTo: self.view.topAnchor),
            webview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        if let url = self.infoUrl {
            webview.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }
    
    private lazy var infoUrl: URL? = {
        if  let resourcePath = Bundle.main.resourceURL {
            return resourcePath.appendingPathComponent("About/about.html")
        }
        
        return nil
    }()
 
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        
        
        if let url = navigationAction.request.url,
           let infoUrl = self.infoUrl,
           url.lastPathComponent != infoUrl.lastPathComponent {
            UIApplication.shared.open(url, options: [:]) { success in
                
            }
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
