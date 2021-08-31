//
//  ContentView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/07/30.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewUtil = ViewUtil()
    private var signInViewModel = SignInViewModel()
    
    let userId: String = UserDefaults.standard.string(forKey: "userId") ?? ""   //저장된 아이디(이메일)
    let password: String = UserDefaults.standard.string(forKey: "password") ?? ""   //저장된 비밀번호
    
    var body: some View {
        if !viewUtil.isNextView {
            //시작 화면
            LaunchScreen()
                .onAppear {
                    viewUtil.nextView() //시작 화면 호출 후 다음 화면 이동
                    
                    //아이디(이메일), 비밀번호가 저장된 경우 자동 로그인 실행
                    if userId != "" && password != "" {
                        //자동 로그인
                        signInViewModel.autoSignIn(userId: userId, password: password) { (result) in
                            signInViewModel.signInStatus = result   //로그인 상태
                            if result == "success" {
                                UserDefaults.standard.set(true, forKey: "autoSignIn")
                            }
                            //로그인 실패 또는 서버 에러에 따른 메시지 출력
                            else if result == "fail" {
                                UserDefaults.standard.set(false, forKey: "autoSignIn")
                                viewUtil.showToast(isShow: true, message: "fail.signin.auto".message())
                            }
                            else if result == "error" {
                                viewUtil.showToast(isShow: true, message: "server.error".message())
                            }
                        }
                    }
                }
        }
        else {
            if userId == "" && password == "" {
                SignInView()    //로그인 화면
            }
            else {
                //로그인 성공 시
                if signInViewModel.signInStatus == "success" {
                    ChargerMapView()    //충전기 메인 화면
                }
                //로그인 실패하거나 서버 에러인 경우
                else {
                    SignInView()    //로그인 화면
                        .popup(
                            isPresented: $viewUtil.isShowToast,   //팝업 노출 여부
                            type: .floater(verticalPadding: 80),
                            position: .bottom,
                            animation: .easeInOut(duration: 0.0),   //애니메이션 효과
                            autohideIn: 2,  //팝업 노출 시간
                            closeOnTap: false,
                            closeOnTapOutside: false,
                            view: {
                                viewUtil.toast()
                            }
                        )
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
