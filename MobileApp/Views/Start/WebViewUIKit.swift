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


final class WebViewUIKit: UIViewController, WKNavigationDelegate {
    
   private var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private var exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Выход", for: .normal)
        button.tintColor = UIColor.label
        return button
    }()
    
    let tokenSubject = PassthroughSubject<String, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        exitButton.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        webView.navigationDelegate = self
        view.addSubview(webView)
        view.addSubview(exitButton)
        self.title = "T"
        
        NSLayoutConstraint.activate([
            exitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            webView.topAnchor.constraint(equalTo: exitButton.bottomAnchor, constant: 16),
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
    
    func clearCache() {
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache, WKWebsiteDataTypeCookies])
        let date = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date, completionHandler: {})
    }
    
   @objc private func tapped() {
       self.dismiss(animated: true)
        
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        guard let url = navigationResponse.response.url, url.path == "/blank.html", let fragment = url.fragment else { decisionHandler(.allow); return }
        print(url)
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
        decisionHandler(.allow)
    }
}
