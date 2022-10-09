//
//  WebViewController.swift
//  IntroduceBodyBuilding
//
//  Created by 윤형석 on 2022/10/10.
//

import UIKit
import WebKit
import SnapKit

class WebViewController: UIViewController{
    private var webView: WKWebView!
    
    var routineTitle: String = "Brogains 10 Week Powerbuilding"
    var url: String = "https://docs.google.com/spreadsheets/u/0/d/1PevAvpjNVwz-hsbyxK81Ud7ApG7Yhk3xa09eMTshoE4/preview?usp=embed_googleplus"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = routineTitle
        self.navigationItem.largeTitleDisplayMode = .never

        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "bridge")
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController = contentController
        
        webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        
        guard let url = URL(string: url) else {return}
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view.addSubview(webView)
        setAutoLayout()
        webView.load(URLRequest(url: url))
        
        webView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            self.webView.alpha = 1
        }) { _ in
            
        }
    }
    public func setAutoLayout() {
        
        webView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    
}
extension WebViewController: WKUIDelegate{
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
    }
}
extension WebViewController: WKNavigationDelegate{
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("\(navigationAction.request.url?.absoluteString ?? "")" )
        
        decisionHandler(.allow)
    }
    
}
extension WebViewController: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        print(message.name)
    }
}

