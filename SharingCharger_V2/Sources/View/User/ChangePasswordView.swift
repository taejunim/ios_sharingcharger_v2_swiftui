//
//  ChangePasswordView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/09.
//

import SwiftUI

//MARK: - 비밀번호 변경 화면
struct ChangePasswordView: View {
    @Environment(\.presentationMode) var presentationMode   //Back 버튼 기능 추가에 필요
    
    @ObservedObject var userViewModel = UserViewModel() //사용자 View Model
    @State var isSigned: Bool = false
    
    var body: some View {
        VStack {
            //로그인 여부에 따른 화면 호출
            if !isSigned {
                UserAuthView(userViewModel: userViewModel)  //사용자 인증 화면
            }
            else {
                NewPasswordView(userViewModel: userViewModel)   //새 비밀번호 입력 화면
            }
        }
        .onAppear {
            userViewModel.isSigned = isSigned   //로그인 여부
        }
    }
}

//MARK: - 사용자 인증 화면 (로그아웃 상태)
///로그아웃 상태인 경우 사용자 인증 후, 비밀번호 변경 가능
struct UserAuthView: View {
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    UserInfoEntryField(userViewModel: userViewModel)    //사용자 정보 입력 화면
                }
                .padding()
            }
            
            ChangeNextStepButton(userViewModel: userViewModel)  //비밀번호 변경하기 버튼 - 다음 단계 진행
        }
        .navigationBarTitle(Text("title.password.step.one".localized()), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
    }
}

//MARK: - 사용자 인증 입력 창
struct UserInfoEntryField: View {
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        //Text Field - 이름
        Section(
            header:
                fieldTitle(title: "label.name".localized(), isRequired: true),
            content: {
                textField(comment: "comment.name".localized(), text: $userViewModel.name, type: .namePhonePad)
            }
        )
        
        //Text Field - 아이디(이메일)
        Section(
            header:
                fieldTitle(title: "label.email".localized(), isRequired: true),
            content: {
                textField(comment: "comment.email".localized(), text: $userViewModel.email, type: .emailAddress)
            }
        )
        
        //Text Field - 휴대전화번호
        Section(
            header:
                fieldTitle(title: "label.phone.number".localized(), isRequired: true),
            content: {
                VStack {
                    HStack {
                        defaultTextField(comment: "comment.phone.number".localized(), text: $userViewModel.phoneNumber, type: .phonePad)
                        
                        ChangeAuthRequestButton(userViewModel: userViewModel)   //인증번호 요청
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
                        defaultTextField(comment: "comment.auth.number".localized(), text: $userViewModel.authNumber, type: .numberPad)

                        //인증번호 요청 시, 타이머 시작
                        if userViewModel.isAuthRequest {
                            Text("남은시간 03:00")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                        
                        //인증번호 확인 버튼
                        ChangeAuthCheckButton(userViewModel: userViewModel)
                            .disabled(!userViewModel.isAuthRequest) //인증번호 요청중이 아닐때 비활성화
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
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        Button(
            action: {
                
            },
            label: {
                Text(!userViewModel.isReRequest ? "button.auth.request".localized() : "button.auth.re.request".localized())
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
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        Button(
            action: {
                
            },
            label: {
                Text("button.auth.check".localized())
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: 95, minHeight: 22)
                    .background(userViewModel.isAuthRequest ? Color("#3498DB") : Color("#EFEFEF"))
                    .cornerRadius(5.0)
                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
            }
        )
    }
}

//MARK: - 비밀번호 변경하기 버튼
///사용자 인증 후 새 비밀번호 입력 화면으로 이동
struct ChangeNextStepButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        NavigationLink(
            destination: NewPasswordView(userViewModel: userViewModel), //새 비밀번호 입력 창
            isActive: $userViewModel.isNewPassword,
            label: {
                Button(
                    action: {
                        userViewModel.isNewPassword = true
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
    
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    PasswordEntryField(userViewModel: userViewModel)    //비밀번호 입력 창
                }
                .padding()
            }
            
            ChangeCompleteButton(userViewModel: userViewModel)  //비밀번호 변경 완료 버튼
        }
        .navigationBarTitle(Text(userViewModel.isSigned ? "title.password.change".localized() : "title.password.step.two".localized()), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
    }
}

//MARK: - 비밀번호 입력 창
///로그인 상태 - 현재 비밀번호, 새 비밀번호, 새 비밀번호 확인 입력
///로그아웃 상태 - 새 비밀번호, 새 비밀번호 확인 입력
struct PasswordEntryField: View {
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        //로그인 상태인 경우 노출
        if userViewModel.isSigned {
            //Text Field - 현재 비밀번호
            Section(
                header:
                    fieldTitle(title: "label.current.password".localized(), isRequired: true),
                content: {
                    secureField(comment: "comment.password.current".localized(), text: $userViewModel.currentPassword)
                }
            )
        }
        
        //Text Field - 새 비밀번호
        Section(
            header:
                fieldTitle(title: "label.new.password".localized(), isRequired: true),
            content: {
                secureField(comment: "comment.password".localized(), text: $userViewModel.newPassword)
            }
        )
        
        //Text Field - 새 비밀번호 확인
        Section(
            header:
                fieldTitle(title: "label.new.password.confirm".localized(), isRequired: true),
            content: {
                secureField(comment: "comment.password.confirm".localized(), text: $userViewModel.confirmNewPassword)
            }
        )
    }
}

//MARK: - 비밀번호 변경 완료 버튼
struct ChangeCompleteButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        Button(
            action: {
                userViewModel.test()
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

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView(isSigned: false)
    }
}
