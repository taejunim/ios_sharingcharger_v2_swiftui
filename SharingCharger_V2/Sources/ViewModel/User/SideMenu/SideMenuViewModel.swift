//
//  SideMenuViewModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/20.
//

import SwiftUI
import Foundation

///사이드 메뉴 View Model
class SideMenuViewModel: ObservableObject {
    private let userAPI = UserAPIService()  //사용자 API Service
    
    @Published var isShowToast: Bool = false    //Toast 호출 여부
    @Published var showMessage: String = "" //Toast 메시지
    
    @Published var isShowMenu: Bool = false //사이드 메뉴 노출 여부
    @Published var isShowSwitchOwnerAlert: Bool = false //소유주 전환 알림창 호출 여부
    @Published var isShowSignOutAlert: Bool = false //로그아웃 알림창 호출 여부
    
    @Published var userIdNo: String = ""    //사용자 ID 번호
    @Published var isSwitch: Bool = false   //소유주 전환 여부
    @Published var isSignOut: Bool = false  //로그아웃 여부
    
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
    
    //MARK: - 소유주 전환 실행
    func switchOwner() {
        userIdNo = UserDefaults.standard.string(forKey: "userIdNo")!    //사용자 정보에 저장된 사용자 ID 번호
        
        //소유주 전환 API 호출
        let request = userAPI.requestSwitchOwner(userIdNo: userIdNo)
        request.execute(
            //API 호출 성공
            onSuccess: { (user) in
                if user.userType == "Personal" {
                    self.isSwitch = true
                    UserDefaults.standard.set(user.userType, forKey: "userType")
                    
                    self.isShowToast = true
                    self.showMessage = "소유주 전환이 완료되었습니다."
                }
            },
            //API 호출 실패
            onFailure: { (error) in
                self.isShowToast = true
                
                switch error {
                case .responseSerializationFailed:
                    self.showMessage = "소유주 전환에 실패하였습니다.\n다시 시도바랍니다.\n문제가 지속될 시, 고객 센터에 문의 바랍니다."
                //일시적인 서버 오류 및 네트워크 오류
                default:
                    self.showMessage = "server.error".message()
                    break
                }
            }
        )
    }
    
    //MARK: - 로그아웃 실행
    func signOut() {
        isSignOut = true
//        for key in UserDefaults.standard.dictionaryRepresentation().keys {
//            UserDefaults.standard.removeObject(forKey: key.description)
//        }
        UserDefaults.standard.removeObject(forKey: "password")
        UserDefaults.standard.set(false, forKey: "autoSignIn")
    }
}
