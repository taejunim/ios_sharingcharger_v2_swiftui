//
//  UserInfoEntryView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/23.
//

import SwiftUI

//MARK: - 사용자 인증 화면 (로그아웃 상태)
///로그아웃 상태인 경우 사용자 인증 후, 비밀번호 변경 가능
struct UserAuthView: View {
    @Environment(\.presentationMode) var presentationMode   //Back 버튼 기능 추가에 필요
    @ObservedObject var userInfo: UserInfoViewModel
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    UserInfoEntryField(userInfo: userInfo)    //사용자 정보 입력 화면
                }
                .padding()
            }
            
            //화면 경로에 따라 버튼 변경
            if userInfo.viewPath == "findAccount" {
                FindAccountButton(userInfo: userInfo)   //아이디 찾기 버튼
            }
            else if userInfo.viewPath == "changePassword" {
                ChangeNextStepButton(userInfo: userInfo)  //비밀번호 변경하기 버튼 - 다음 단계 진행
            }
        }
        .navigationBarTitle(Text(userInfo.viewTitle.localized()), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
    }
}

//MARK: - 사용자 정보 입력 창
struct UserInfoEntryField: View {
    @ObservedObject var userInfo: UserInfoViewModel
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()    //타이머
    
    var body: some View {
        //Text Field - 이름
        Section(
            header:
                fieldTitle(title: "label.name".localized(), isRequired: true),
            content: {
                textField(comment: "comment.name".localized(), text: $userInfo.name, type: .namePhonePad)
            }
        )
        
        //호출한 상위 화면이 '비밀번호 변경'인 경우 아이디 입력창 표시
        if userInfo.viewPath == "changePassword" {
            //Text Field - 아이디(이메일)
            Section(
                header:
                    fieldTitle(title: "label.email".localized(), isRequired: true),
                content: {
                    textField(comment: "comment.email".localized(), text: $userInfo.email, type: .emailAddress)
                }
            )
        }
        
        //Text Field - 휴대전화번호
        Section(
            header:
                fieldTitle(title: "label.phone.number".localized(), isRequired: true),
            content: {
                VStack {
                    HStack {
                        defaultTextField(comment: "comment.phone.number".localized(), text: $userInfo.phone, type: .phonePad)
                        
                        ChangeAuthRequestButton(userInfo: userInfo)   //인증번호 요청
                    }
                    
                    Spacer()
                    
                    TextFieldUnderline()
                }
            }
        )
        
        //Text Field - 인증번호
        Section(
            header:
                fieldTitle(title: "label.auth.number".localized(), isRequired: true),
            content: {
                VStack {
                    HStack {
                        defaultTextField(comment: "comment.auth.number".localized(), text: $userInfo.authNumber, type: .numberPad)

                        //인증번호 요청 시, 타이머 시작
                        if userInfo.isAuthRequest {
                            Text("남은시간 \(String(format: "%02d", userInfo.minutesRemaining)):\(String(format: "%02d", userInfo.secondsRemaining))")
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .onReceive(timer) { _ in
                                    userInfo.authTimer() //인증 타이머 실행
                                }
                        }
                        else {
                            //인증 완료 시, 인증 완료 문구 출력
                            if userInfo.isAuthComplete {
                                Text("label.auth.complete".localized())
                                    .font(.subheadline)
                                    .foregroundColor(Color("#3498DB"))
                            }
                        }

                        //인증번호 확인 버튼
                        ChangeAuthCheckButton(userInfo: userInfo)
                            .disabled(!userInfo.isAuthRequest) //인증번호 요청중이 아닐때 비활성화
                    }
                    
                    Spacer()
        
                    TextFieldUnderline()
                }
            }
        )
    }
}

//MARK: - 인증 요청 버튼
struct ChangeAuthRequestButton: View {
    @ObservedObject var userInfo: UserInfoViewModel
    
    var body: some View {
        Button(
            action: {
                userInfo.viewUtil.dismissKeyboard() // 키보드 닫기
                userInfo.authRequest()              //휴대폰 인증 요청
            },
            label: {
                Text(!userInfo.isReRequest ? "button.auth.request".localized() : "button.auth.re.request".localized())
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: 95, minHeight: 22)
                    .background(Color("#3498DB"))
                    .cornerRadius(5.0)
                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
            }
        )
    }
}

//MARK: - 인증 확인 버튼
struct ChangeAuthCheckButton: View {
    @ObservedObject var userInfo: UserInfoViewModel
    
    var body: some View {
        Button(
            action: {
                userInfo.viewUtil.dismissKeyboard()     // 키보드 닫기
                userInfo.checkAuthNumber()              // 휴대폰 인증 확인
            },
            label: {
                Text("button.auth.check".localized())
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: 95, minHeight: 22)
                    .background(userInfo.isAuthRequest ? Color("#3498DB") : Color("#EFEFEF"))
                    .cornerRadius(5.0)
                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
            }
        )
    }
}
