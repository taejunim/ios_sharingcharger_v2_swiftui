//
//  PaymentWebView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/20.
//

import SwiftUI
import WebKit
import UIKit

struct PaymentWebView: UIViewRepresentable, WebViewHandlerDelegate {
    
    var loadUrl: String //호출 URL
    var message: ( _ type: String, _ code: String, _ content: String) -> () //JavaScript 메시지 - type: 메시지 타입, code: 메시지 코드, content: 메시지 내용
    
    //MARK: - 웹 뷰 생성
    func makeUIView(context: Context) -> WKWebView {
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        
        let webView = WKWebView(frame: .zero)
        let configuration = webView.configuration
    
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.bounces = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.scrollsToTop = true
        
        configuration.userContentController.add(self.makeCoordinator(), name: "myInterface")
        
        if let url = URL(string: loadUrl) {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }
    
    //MARK: - 웹 뷰 업데이트
    func updateUIView(_ webView: WKWebView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(uiWebView: self)
    }
    
    func receivedJsonValueFromWebView(value: [String : Any?]) {
        print("JSON Data: \(value)")
    }
    
    func receivedStringValueFromWebView(value: String) {
        print("String Data: \(value)")
    }
    
    class Coordinator : NSObject, WKNavigationDelegate {
        var webView: PaymentWebView
        var delegate: WebViewHandlerDelegate?
        
        init(uiWebView: PaymentWebView) {
            self.webView = uiWebView
            self.delegate = webView
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            let request = navigationAction.request
            let optUrl = request.url
            let optUrlScheme = optUrl?.scheme
            
            guard let url = optUrl, let scheme = optUrlScheme else {
                return decisionHandler(WKNavigationActionPolicy.cancel)
            }

            debugPrint("url : \(url)")
            if(scheme != "http" && scheme != "https") {
                if(scheme == "ispmobile" && !UIApplication.shared.canOpenURL(url)) {
                    //ISP 미설치 시
                    UIApplication.shared.open(URL(string: "http://itunes.apple.com/kr/app/id369125087?mt=8")!, options: [:], completionHandler: nil)
                }
                else if(scheme == "kftc-bankpay" && !UIApplication.shared.canOpenURL(url)) {
                    //BANKPAY 미설치 시
                    UIApplication.shared.open(URL(string: "http://itunes.apple.com/us/app/id398456030?mt=8")!, options: [:], completionHandler: nil)
                }
                else if scheme == "tel" {
                    UIApplication.shared.open(url)
                    return decisionHandler(WKNavigationActionPolicy.cancel)
                }
                else {
                    if(UIApplication.shared.canOpenURL(url)) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
            
            decisionHandler(WKNavigationActionPolicy.allow)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            decisionHandler(.allow)
        }
    }
}

protocol WebViewHandlerDelegate {
    func receivedJsonValueFromWebView(value: [String: Any?])
    func receivedStringValueFromWebView(value: String)
}

extension PaymentWebView.Coordinator: WKUIDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let encodedMessage = message.removingPercentEncoding!.replacingOccurrences(of: "+", with: " ")
        
        if message.contains(":") {
            let getCode = encodedMessage[..<encodedMessage.firstIndex(of: ":")!].trimmingCharacters(in: .whitespaces)
            let getContent = encodedMessage[encodedMessage.firstIndex(of: ":")!...].trimmingCharacters(in: [":"]).trimmingCharacters(in: .whitespaces)

            print("JavaScript Alert Encoding Message : \(encodedMessage)")
            print("JavaScript Alert Code : \(getCode)")
            print("JavaScript Alert Content : \(getContent)")
            
            self.webView.message("alert", getCode, getContent)
        }
        else {
            self.webView.message("alert", "notCode", encodedMessage)
        }
        
        completionHandler()
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        print("JavaScript Confirm : \(message)")
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        print("JavaScript Text Input : \(prompt)")
    }
}

extension PaymentWebView.Coordinator: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "myInterface", let values = message.body as? Dictionary<String, Any> {
            guard let funcName = values["func"] as? String else {
                debugPrint("FuncName Not Nil")
                return
            }
            
            debugPrint("Inteerface : \(funcName)")
            debugPrint("Body : \(values)")
            
            if funcName == "payOrder" {
                var result = "" // 성공 여부(1 : 성공, 이외 : 실패)
                var result_msg = "" // 결과 메시지
                var cal_point = ""  // 총합 포인트
                
                if let validResult = values["result"] as? String {
                    result = validResult
                }
                
                if let validResultMsg = values["result_msg"] as? String {
                    result_msg = validResultMsg
                }
                
                if let validCalPoint = values["cal_point"] as? String {
                    cal_point = validCalPoint
                }
                
                //결제 성공
                if result == "1" {
                    delegate?.receivedStringValueFromWebView(value: cal_point)
                    
                    self.webView.message("result", "success", cal_point)
                }
                //결제 실패
                else {
                    delegate?.receivedStringValueFromWebView(value: result_msg)
                    
                    self.webView.message("result", "fail", result_msg)
                }
            }
            else {
                delegate?.receivedStringValueFromWebView(value: funcName)
            }
        }
    }
}
