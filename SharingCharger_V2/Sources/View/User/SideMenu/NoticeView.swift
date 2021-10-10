//
//  NoticeView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/27.
//

import SwiftUI
import WebKit

//MARK: - 공지사항
struct NoticeView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            NoticeWebView(loadUrl: "http://211.253.37.97:52340/information/app/notice")
            //NoticeWebView(loadUrl: "https://monttak.co.kr/information/app/notice")
        }
        .navigationBarTitle(Text("공지사항"), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
    }
}

//MARK: - 공지사항 웹 뷰
struct NoticeWebView: UIViewRepresentable {
    
    var loadUrl: String //호출 URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.bounces = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.scrollsToTop = true
        
        if let url = URL(string: loadUrl) {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(uiWebView: self)
    }
    
    class Coordinator : NSObject {
        var webView: NoticeWebView
        
        init(uiWebView: NoticeWebView) {
            self.webView = uiWebView
        }
    }
}

struct NoticeView_Previews: PreviewProvider {
    static var previews: some View {
        NoticeView()
    }
}
