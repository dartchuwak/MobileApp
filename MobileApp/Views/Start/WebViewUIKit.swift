//
//  WebViewUIKit.swift
//  MobileApp
//
//  Created by Evgenii Mikhailov on 20.04.2023.
//

import Foundation
import UIKit
import WebKit
import Combine


class WebViewUIKit: UIViewController, WKNavigationDelegate {
    
    
    var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    let tokenSubject = PassthroughSubject<String, Never>()
    
  
    deinit {
        print("dead")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([   
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        var url = URLComponents()
        
        url.scheme = "https"
        url.host = "oauth.vk.com"
        url.path = "/authorize"
        
        url.queryItems = [
            URLQueryItem(name: "client_id", value: "51604643"),
            URLQueryItem(name: "redirect_uri", value: "http://oauth.vk.com/blank.html"),
            URLQueryItem(name: "display", value: "mobile"),
            URLQueryItem(name: "response_type", value: "token")
        ]
        
        let request = URLRequest(url: url.url!)
        webView.load(request)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        guard let url = navigationResponse.response.url, url.path == "/blank.html", let fragment = url.fragment else { decisionHandler(.allow); return }
        let params = fragment.components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) { res, param in
                var dict = res
                let key = param[0]
                let value = param[1]
                dict[key] = value
                return dict
            }
        
        if let accessToken = params["access_token"] {
            tokenSubject.send(accessToken)
        }
        decisionHandler(.cancel)
    }
}
