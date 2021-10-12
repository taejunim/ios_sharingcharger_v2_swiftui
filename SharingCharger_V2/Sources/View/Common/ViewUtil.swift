//
//  ViewUtil.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/02.
//

import SwiftUI
import Foundation
import Combine
import ExytePopupView

class ViewUtil: ObservableObject {
    @Environment(\.presentationMode) var presentationMode
    
    private let userAPI = UserAPIService()  //사용자 API Service
    
    @Published var isNextView = false   //다음 화면 이동 여부
    @Published var isLoading: Bool = false    //로딩 화면 노출 여부
    @Published var isShowToast: Bool = false    //Toast 팝업 노출 여부
    @Published var toastMessage: String = ""    //Toast 팝업 메시지
    
    //MARK: - 키보드 닫기
    /// Dismiss Keyboard
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    //MARK: - 내비게이션 화면 닫기
    func dismissNavigationView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    //MARK: - 다음 화면 이동
    func nextView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            self.isNextView = true
        }
    }
    
    //MARK: - 로딩 화면
    /// Loading  View Function
    /// - Returns: Loading View
    func loadingView() -> some View {
        ZStack {
            //로딩 화면 색상
            Color(.gray).opacity(0.5)
                .ignoresSafeArea()  //범위 지정
            
            //로딩 Progress View
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(.darkGray)))
                .scaleEffect(2) //로딩 크기
        }
    }
    
    //MARK: - Toast 팝업
    /// Toast Popup View
    /// - Returns: Toast Popup View
    func toast() -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(toastMessage)
                .foregroundColor(Color.white)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
        }
        .padding(15)
        .background(Color.black.opacity(0.5))   //배경 색상 및 투명도
        .cornerRadius(10)   //모서리 둥글게 처리
    }
    
    func toastPopup(message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(message)
                .foregroundColor(Color.white)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
        }
        .padding(15)
        .background(Color.black.opacity(0.5))   //배경 색상 및 투명도
        .cornerRadius(10)   //모서리 둥글게 처리
        .padding(.horizontal)
    }
    
    //MARK: - Toast 팝업 호출
    /// Toast Popup 호출
    /// - Parameters:
    ///   - isShow: 팝업 호출 여부
    ///   - message: 팝업 메시지
    func showToast(isShow: Bool, message: String) {
        self.isShowToast = isShow
        self.toastMessage = message
    }
    
    //MARK: - 팝업
    /// Popup VIew
    /// - Returns: Popup View
    func popup() -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(toastMessage)
                .foregroundColor(Color.white)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
        }
        .padding(15)
        .background(Color.black.opacity(0.5))   //배경 색상 및 투명도
        .cornerRadius(10)   //모서리 둥글게 처리
    }
}
