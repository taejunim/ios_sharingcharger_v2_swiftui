//
//  UserViewModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/09.
//

import Foundation

class UserViewModel: ObservableObject {
    @Published var viewPath: String = ""
    @Published var viewTitle: String = ""
    
    @Published var showFindAccountPopup: Bool = false
    @Published var isFindAccount: Bool = false
    
    @Published var isSigned: Bool = false
    @Published var isNewPassword: Bool = false
    
    @Published var name: String = ""    //이름
    @Published var email: String = ""   //이메일 - 아이디
    @Published var phoneNumber: String = "" //전화번호
    @Published var authNumber: String = ""  //인증번호
    
    @Published var isAuthRequest: Bool = false  //인증 요청 여부
    @Published var isReRequest: Bool = false    //인증 재요청 여부
    @Published var receivedAuthNumber: String = ""  //API 호출 인증번호
    @Published var isAuthComplete: Bool = false //인증 완료 여부
    
    @Published var isStartTimer: Bool = false   //타이머 시작 여부
    @Published var minutesRemaining: Int = 3    //타이머 분 시간 설정(기본값: 3)
    @Published var secondsRemaining: Int = 0    //타이머 초 시간 설정(기본값: 0)
    
    @Published var currentPassword: String = "" //현재 비밀번호
    @Published var newPassword: String = ""    //비밀번호
    @Published var confirmNewPassword: String = "" //비밀번호 확인
    
    func test() {
        newPassword = ""
    }
}
