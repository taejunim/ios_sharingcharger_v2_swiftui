//
//  ChangePasswordView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/09.
//

import SwiftUI

//MARK: - 비밀번호 변경 화면
struct ChangePasswordView: View {
    //@Environment(\.presentationMode) var presentationMode   //Back 버튼 기능 추가에 필요
    @ObservedObject var userInfo = UserInfoViewModel() //사용자 View Model
    
    @State var isSigned: Bool = false
    
    var body: some View {
        VStack {
            //로그인 여부에 따른 화면 호출
            if !isSigned {
                UserAuthView(userInfo: userInfo)  //사용자 인증 화면
            }
            else {
                NewPasswordView(userInfo: userInfo)   //새 비밀번호 입력 화면
            }
        }
        .onAppear {
            userInfo.isSigned = isSigned   //로그인 여부
            userInfo.viewPath = "changePassword"
            userInfo.viewTitle = "title.password.step.one"
        }
    }
}

//MARK: - 비밀번호 변경하기 버튼
///사용자 인증 후 새 비밀번호 입력 화면으로 이동
struct ChangeNextStepButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var userInfo: UserInfoViewModel
    
    var body: some View {
        NavigationLink(
            destination: NewPasswordView(userInfo: userInfo), //새 비밀번호 입력 창
            isActive: $userInfo.isNewPassword,
            label: {
                Button(
                    action: {
                        userInfo.isNewPassword = true
                    },
                    label: {
                        Text("button.password.next.step".localized())
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, maxHeight: 40)
                            .background(Color("#3498DB"))
                    }
                )
            }
        )
    }
}

//MARK: - 새 비밀번호 입력 화면
struct NewPasswordView: View {
    @Environment(\.presentationMode) var presentationMode   //Back 버튼 기능 추가에 필요
    @ObservedObject var userInfo: UserInfoViewModel
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    PasswordEntryField(userInfo: userInfo)    //비밀번호 입력 창
                }
                .padding()
            }
            
            ChangeCompleteButton(userInfo: userInfo)  //비밀번호 변경 완료 버튼
        }
        .navigationBarTitle(Text(userInfo.isSigned ? "title.password.change".localized() : "title.password.step.two".localized()), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
    }
}

//MARK: - 비밀번호 입력 창
///로그인 상태 - 현재 비밀번호, 새 비밀번호, 새 비밀번호 확인 입력
///로그아웃 상태 - 새 비밀번호, 새 비밀번호 확인 입력
struct PasswordEntryField: View {
    @ObservedObject var userInfo: UserInfoViewModel
    
    var body: some View {
        //로그인 상태인 경우 노출
        if userInfo.isSigned {
            //Text Field - 현재 비밀번호
            Section(
                header:
                    fieldTitle(title: "label.current.password".localized(), isRequired: true),
                content: {
                    secureField(comment: "comment.password.current".localized(), text: $userInfo.currentPassword)
                }
            )
        }
        
        //Text Field - 새 비밀번호
        Section(
            header:
                fieldTitle(title: "label.new.password".localized(), isRequired: true),
            content: {
                secureField(comment: "comment.password".localized(), text: $userInfo.newPassword)
            }
        )
        
        //Text Field - 새 비밀번호 확인
        Section(
            header:
                fieldTitle(title: "label.new.password.confirm".localized(), isRequired: true),
            content: {
                secureField(comment: "comment.password.confirm".localized(), text: $userInfo.confirmNewPassword)
            }
        )
    }
}

//MARK: - 비밀번호 변경 완료 버튼
struct ChangeCompleteButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var userInfo: UserInfoViewModel
    
    var body: some View {
        Button(
            action: {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                    self.presentationMode.wrappedValue.dismiss()
//                }
            },
            label: {
                Text("button.password.complete".localized())
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(Color("#3498DB"))   //회원가입 정보 입력에 따른 배경색상 변경
            }
        )
    }
}
