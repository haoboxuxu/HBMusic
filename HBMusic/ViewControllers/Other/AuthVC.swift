//
//  AuthVC.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/17.
//

import UIKit
import WebKit

class AuthVC: UIViewController {
    
    private let webView: WKWebView = {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = preferences
        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }()
    
    public var completionHandler: ((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign In"
        view.backgroundColor = .systemBackground
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        guard let signInURL = AuthManger.shared.signInURL else {
            return
        }
        webView.load(URLRequest(url: signInURL))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }
}

extension AuthVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else {
            return
        }
        
        let components = URLComponents(string: url.absoluteString)
        
        guard let code = components?.queryItems?.first(where: { item in
            item.name == "code"
        })?.value else {
            return
        }
        
        webView.isHidden = true
        
        AuthManger.shared.exchangeToken(with: code) { [weak self] success in
            DispatchQueue.main.async {
                self?.navigationController?.popToRootViewController(animated: true)
                self?.completionHandler?(success)
            }
        }
    }
}
