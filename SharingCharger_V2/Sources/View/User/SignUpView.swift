//
//  SignUpView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/02.
//

import SwiftUI
import WebKit
import ExytePopupView

//MARK: - 회원가입 화면
struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode   //Back 버튼 기능 추가에 필요
    
    @ObservedObject var viewOptionSet = ViewOptionSet() //화면 Option Set
    @ObservedObject var signUpViewModel = SignUpViewModel() //회원가입 View Model

    var body: some View {
        ZStack {
            VStack {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading) {
                        AccountEntryField(signUpViewModel: signUpViewModel) //회원가입 정보 입력 창
                        
                        Spacer()
                        
                        PrivacyConsent(signUpViewModel: signUpViewModel)    //개인정보 동의여부 화면
                    }
                    .padding()
                }
                
                AccountRegistButton(signUpViewModel: signUpViewModel)   //회원가입 등록 버튼
            }
            .navigationBarTitle(Text("title.sign.up".localized()), displayMode: .inline) //Navigation Bar 타이틀
            .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
            .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
            
            //로딩 표시 여부에 따라 표출
            if signUpViewModel.viewUtil.isLoading {
                signUpViewModel.viewUtil.loadingView()  //로딩 화면
            }
        }
        .popup(
            isPresented: $signUpViewModel.viewUtil.isShowToast,   //팝업 노출 여부
            type: .floater(verticalPadding: 80),
            position: .bottom,
            animation: .easeInOut(duration: 0.0),   //애니메이션 효과
            autohideIn: 2,  //팝업 노출 시간
            closeOnTap: false,
            closeOnTapOutside: false,
            view: {
                signUpViewModel.viewUtil.toast()    //Toast 팝업 화면
            }
        )
        .onAppear {
            let isPresented = presentationMode.wrappedValue.isPresented
            
            if !isPresented {
                signUpViewModel.viewReset() //회원정보 화면 초기화
            }
        }
    }
}

//MARK: - 회원가입 정보 입력 창
struct AccountEntryField: View {
    @ObservedObject var signUpViewModel: SignUpViewModel
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()    //타이머
    
    var body: some View {
        //Text Field - 이름
        Section(
            header:
                fieldTitle(title: "label.name".localized(), isRequired: true),
            content: {
                textField(comment: "comment.name".localized(), text: $signUpViewModel.name, type: .namePhonePad)
            }
        )
        
        //Text Field - 아이디(이메일)
        Section(
            header:
                fieldTitle(title: "label.email".localized(), isRequired: true),
            content: {
                VStack {
                    HStack {
                        defaultTextField(comment: "comment.email".localized(), text: $signUpViewModel.email, type: .emailAddress)
                        
                        //중복 확인 여부에 따라 '사용 가능/불가' 텍스트 노출
                        if signUpViewModel.isDuplicateCheck {
                            //중복되지 않는 경우
                            if signUpViewModel.duplicateStaus == "non duplicate" {
                                Text("label.available".localized())
                                    .font(.subheadline)
                                    .foregroundColor(Color("#3498DB"))
                            }
                            //중복인 경우
                            else if signUpViewModel.duplicateStaus == "duplicate" {
                                Text("label.not.available".localized())
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        DuplicateCheckButton(signUpViewModel: signUpViewModel)   //아이디(이메일) 중복 확인 버튼
                    }
                    
                    Spacer()
        
                    TextFieldUnderline()    //텍스트 필드 밑줄
                }
            }
        )
        
        //Text Field - 휴대전화번호
        Section(
            header:
                fieldTitle(title: "label.phone.number".localized(), isRequired: true),
            content: {
                VStack {
                    HStack {
                        defaultTextField(comment: "comment.phone.number".localized(), text: $signUpViewModel.phoneNumber, type: .phonePad)
                        
                        AuthRequestButton(signUpViewModel: signUpViewModel) //인증 요청 버튼
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
                        defaultTextField(comment: "comment.auth.number".localized(), text: $signUpViewModel.authNumber, type: .numberPad)

                        //인증 요청 시, 남은 시간 타이머 노출
                        if signUpViewModel.isAuthRequest {
                            Text("남은시간 \(String(format: "%02d", signUpViewModel.minutesRemaining)):\(String(format: "%02d", signUpViewModel.secondsRemaining))")
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .onReceive(timer) { _ in
                                    signUpViewModel.authTimer() //인증 타이머 실행
                                }
                        }
                        else {
                            //인증 완료 시, 인증 완료 문구 출력
                            if signUpViewModel.isAuthComplete {
                                Text("label.auth.complete".localized())
                                    .font(.subheadline)
                                    .foregroundColor(Color("#3498DB"))
                            }
                        }
                        
                        //인증번호 확인 버튼
                        AuthCheckButton(signUpViewModel: signUpViewModel)
                            .disabled(!signUpViewModel.isStartTimer)
                    }
                    
                    Spacer()
        
                    TextFieldUnderline()
                }
            }
        )
        
        //Text Field - 비밀번호
        Section(
            header:
                fieldTitle(title: "label.password".localized(), isRequired: true),
            content: {
                secureField(comment: "comment.password".localized(), text: $signUpViewModel.password)
            }
        )
        
        //Text Field - 비밀번호 확인
        Section(
            header:
                fieldTitle(title: "label.password.confirm".localized(), isRequired: true),
            content: {
                secureField(comment: "comment.password.confirm".localized(), text: $signUpViewModel.confirmPassword)
            }
        )
    }
}

//MARK: - 아이디(이메일) 중복 확인 버튼
struct DuplicateCheckButton: View {
    @ObservedObject var signUpViewModel: SignUpViewModel
    
    var body: some View {
        Button(
            action: {
                signUpViewModel.viewUtil.dismissKeyboard()  //키보드 닫기
                signUpViewModel.duplicateCheck()    //아이디 중복 확인 실행
            },
            label: {
                Text("button.duplicate.check")
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

//MARK: - 인증 요청 버튼
struct AuthRequestButton: View {
    @ObservedObject var signUpViewModel: SignUpViewModel
    
    var body: some View {
        Button(
            action: {
                signUpViewModel.viewUtil.dismissKeyboard()  //키보드 닫기
                signUpViewModel.authRequest()   //인증 요청 실행
            },
            label: {
                //인증 시간내에 인증 못할 경우, '인증 요청'을 '재요청' 문구로 변경
                Text(!signUpViewModel.isReRequest ? "button.auth.request".localized() : "button.auth.re.request".localized())
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
struct AuthCheckButton: View {
    @ObservedObject var signUpViewModel: SignUpViewModel
    
    var body: some View {
        Button(
            action: {
                signUpViewModel.viewUtil.dismissKeyboard()  //키보드 닫기
                signUpViewModel.checkAuthNumber()   //인증번호 확인 실행
            },
            label: {
                Text("button.auth.check".localized())
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: 95, minHeight: 22)
                    .background(signUpViewModel.isStartTimer ? Color("#3498DB") : Color("#EFEFEF"))
                    .cornerRadius(5.0)
                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
            }
        )
    }
}

//MARK: - 개인정보 동의여부 화면
struct PrivacyConsent: View {
    @ObservedObject var signUpViewModel: SignUpViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            //개인정보 동의여부 타이틀
            Text("title.privacy.consent".localized())
                .font(.title3)
            
            Spacer()
            
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    //서비스 이용약관 동의 라벨
                    HStack {
                        Text("title.terms.agree".localized())
                            .font(.subheadline)
                        RequiredInputLabel()
                    }

                    Spacer()

                    //개인정보 처리방침 동의 라벨
                    HStack {
                        Text("title.privacy.agree".localized())
                            .font(.subheadline)
                        RequiredInputLabel()
                    }
                }

                Spacer()

                //서비스 이용약관 & 개인정보 처리방침 내용 확인
                VStack {
                    TermsContentButton(signUpViewModel: signUpViewModel)    //서비스 이용약관 내용 확인 버튼

                    Spacer()

                    PrivacyContentButton(signUpViewModel: signUpViewModel)  //개인정보 처리방침 내용 확인 버튼
                }

                //동의 여부
                VStack(alignment: .leading) {
                    //서비스 이용약관 동의
                    Text(signUpViewModel.isTermsAgree ? "label.agree".localized() : "label.disagree".localized())
                        .font(.footnote)
                        .padding(.vertical, 5)
                        .foregroundColor(signUpViewModel.isTermsAgree ? Color("#3498DB") : Color("#E4513D"))
                    //개인정보 처리방침 동의
                    Text(signUpViewModel.isPrivacyAgree ? "label.agree".localized() : "label.disagree".localized())
                        .font(.footnote)
                        .padding(.vertical, 5)
                        .foregroundColor(signUpViewModel.isPrivacyAgree ? Color("#3498DB") : Color("#E4513D"))
                }
            }
        }
        .padding(.top)
    }
}

//MARK: - 서비스 이용약관 내용 확인 버튼
struct TermsContentButton: View {
    @ObservedObject var signUpViewModel: SignUpViewModel
    
    var body: some View {
        NavigationLink(
            destination: TermsContent(signUpViewModel: signUpViewModel),    //서비스 이용약관 화면
            isActive: $signUpViewModel.isTermsContent,  //서비스 이용약관 화면 호출 여부
            label: {
                Button(
                    action: {
                        signUpViewModel.viewUtil.dismissKeyboard()  //키보드 닫기
                        signUpViewModel.getTermsContent()   //서비스 이용약관 내용 API 호출
                    },
                    label: {
                        Text("button.content".localized())
                            .font(.footnote)
                            .foregroundColor(Color.black)
                            .padding(.horizontal, 8)
                            .frame(maxWidth: 70, minHeight: 25)
                            .background(Color.white)
                            .cornerRadius(5.0)
                            .shadow(color: .gray, radius: 1, x: 1.0, y: 1.0)
                    }
                )
            }
        )
    }
}

//MARK: - 개인정보 처리방침 내용 확인 버튼
struct PrivacyContentButton: View {
    @ObservedObject var signUpViewModel: SignUpViewModel
    
    var body: some View {
        NavigationLink(
            destination: PrivacyContent(signUpViewModel: signUpViewModel),  //개인정보 처리방침 화면
            isActive: $signUpViewModel.isPrivacyContent,    //개인정보 처리방침 화면 호출 여부
            label: {
                Button(
                    action: {
                        signUpViewModel.viewUtil.dismissKeyboard()  //키보드 닫기
                        signUpViewModel.getPrivacyContent() //개인정보 처리방침 내용 API 호출
                    },
                    label: {
                        Text("button.content".localized())
                            .font(.footnote)
                            .foregroundColor(Color.black)
                            .padding(.horizontal, 8)
                            .frame(maxWidth: 70, minHeight: 25)
                            .background(Color.white)
                            .cornerRadius(5.0)
                            .shadow(color: .gray, radius: 1, x: 1.0, y: 1.0)
                    }
                )
            }
        )
    }
}

//MARK: - 서비스 이용약관 내용
struct TermsContent: View {
    @Environment(\.presentationMode) var presentationMode   //Back 버튼 기능 추가에 필요
    @ObservedObject var signUpViewModel: SignUpViewModel
    
    var body: some View {
        VStack {
            //내용 호출 성공 여부에 따라 표출
            if signUpViewModel.isGetContent {
                HTMLText(htmlContent: signUpViewModel.termsContent) //HTML 태그 뷰어
            }
            else {
                Spacer()
                Text("server.error".message()).multilineTextAlignment(.center)  //서버 에러 메시지 출력
                Spacer()
            }
            
            TermsAgreeButton(signUpViewModel: signUpViewModel)  //서비스 이용약관 동의 버튼
        }
        .navigationBarTitle(Text("title.terms".localized()), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
    }
}

//MARK: - 서비스 이용약관 동의 버튼
struct TermsAgreeButton: View {
    @ObservedObject var signUpViewModel: SignUpViewModel
    
    var body: some View {
        Button(
            action: {
                signUpViewModel.isTermsAgree = true //서비스 이용약관 동의 여부
            },
            label: {
                Text("button.agree".localized())
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(signUpViewModel.isGetContent ? Color("#3498DB") : Color("#EFEFEF"))
            }
        )
        .disabled(signUpViewModel.isGetContent ? false : true)  //내용 호출 실패 시, 버튼 비활성화
    }
}

//MARK: - 개인정보 처리방침 내용
struct PrivacyContent: View {
    @Environment(\.presentationMode) var presentationMode   //Back 버튼 기능 추가에 필요
    @ObservedObject var signUpViewModel: SignUpViewModel
    
    var body: some View {
        VStack {
            //내용 호출 성공 여부에 따라 표출
            if signUpViewModel.isGetContent {
                HTMLText(htmlContent: signUpViewModel.privacyContent)   //HTML 태그 뷰어
            }
            else {
                Spacer()
                Text("server.error".message()).multilineTextAlignment(.center)  //서버 에러 메시지 출력
                Spacer()
            }
            
            PrivacyAgreeButton(signUpViewModel: signUpViewModel)    //개인정보 처리방침 동의 버튼
        }
        .navigationBarTitle(Text("title.privacy".localized()), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
    }
}

//MARK: - 개인정보 처리방침 동의 버튼
struct PrivacyAgreeButton: View {
    @ObservedObject var signUpViewModel: SignUpViewModel
    
    var body: some View {
        Button(
            action: {
                signUpViewModel.isPrivacyAgree = true   //개인정보 처리방침 동의 여부
            },
            label: {
                Text("button.agree".localized())
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(signUpViewModel.isGetContent ? Color("#3498DB") : Color("#EFEFEF"))
            }
        )
        .disabled(signUpViewModel.isGetContent ? false : true)  //내용 호출 실패 시, 버튼 비활성화
    }
}

//MARK: - 계정 등록 버튼
struct AccountRegistButton: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var signUpViewModel: SignUpViewModel
    
    var body: some View {
        Button(
            action: {
                signUpViewModel.viewUtil.dismissKeyboard()  //키보드 닫기
                
                //회원가입 정보 유효성 검사
                if signUpViewModel.validation() {
                    //회원가입 실행
                    signUpViewModel.signUp() { (result) in
                        //회원가입 완료인 경우 회원가입 화면 닫기
                        if result == "success" {
                            //등록 완료 메시지 출력 후 회원가입 화면 닫기
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                signUpViewModel.viewReset() //입력 화면 초기화
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
            },
            label: {
                Text("button.regist".localized())
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

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
