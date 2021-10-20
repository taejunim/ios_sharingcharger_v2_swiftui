//
//  SignInView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/07/30.
//

import SwiftUI
import ExytePopupView

//MARK: - 로그인 화면
struct SignInView: View {
    @ObservedObject var signInViewModel = SignInViewModel() //로그인 View Model
    @ObservedObject var location = Location()
    @ObservedObject var charging = ChargingViewModel()
    
    var body: some View {
        if signInViewModel.signInStatus == "success" {
            ChargerMapView()
        }
        else {
            NavigationView {
                ZStack {
                    VStack {
                        //시작 화면 이미지
                        Image("LaunchImage-Top")
                            .resizable()
                            .scaledToFit()
                        
                        Spacer()
                        
                        VStack {
                            SignInEntryField(signInViewModel: signInViewModel)  //로그인 정보 입력 창

                            HStack {
                                SignInButton(signInViewModel: signInViewModel)  //로그인 버튼

                                Spacer().frame(width: 1)    //버튼 사이 간격

                                SignUpButton()  //회원가입 버튼
                            }

                            HStack {
                                Spacer()

                                FindAccountViewButton(signInViewModel: signInViewModel) //아이디 찾기 버튼

                                Text("/")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.gray)

                                ChangePasswordButton(signInViewModel: signInViewModel)  //비밀번호 변경 버튼

                                Spacer()
                            }
                            .padding(.top)
                        }
                        .padding()
                        
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                    }
                    
                    //로딩 표시 여부에 따라 표출
                    if signInViewModel.viewUtil.isLoading {
                        signInViewModel.viewUtil.loadingView()  //로딩 화면
                    }
                }
                .navigationBarHidden(true)
                .edgesIgnoringSafeArea([.bottom, .horizontal])
                .popup(
                    isPresented: $signInViewModel.viewUtil.isShowToast,   //팝업 노출 여부
                    type: .floater(verticalPadding: 80),
                    position: .bottom,
                    animation: .easeInOut(duration: 0.0),   //애니메이션 효과
                    autohideIn: 1,  //팝업 노출 시간
                    closeOnTap: false,
                    closeOnTapOutside: false,
                    view: {
                        signInViewModel.viewUtil.toast()
                    }
                )
                .onAppear {
                    location.startLocation()    //위치 정보 시작
                }
            }
        }
    }
}

//MARK: - 로그인 정보 입력 창
struct SignInEntryField: View {
    @ObservedObject var signInViewModel: SignInViewModel
    
    var body: some View {
        VStack {
            //아이디(이메일) 입력창
            textField(comment: "label.email".localized(), text: $signInViewModel.id, type: .emailAddress)
            
            //비밀번호 입력 창
            secureField(comment: "label.password".localized(), text: $signInViewModel.password)
        }
    }
}

//MARK: - 로그인 버튼
struct SignInButton: View {
    @ObservedObject var signInViewModel: SignInViewModel
    
    var body: some View {
        Button(
            action: {
                signInViewModel.viewUtil.dismissKeyboard()  //키보드 닫기

                //아이디(이메일), 비밀번호 유효성 검사
                if signInViewModel.validation() {
                    signInViewModel.signIn()    //로그인 실행
                }
            },
            label: {
                Text("button.sign.in".localized())
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, minHeight: 35)
                    .background(Color("#3498DB"))
            }
        )
    }
}

//MARK: - 회원가입 화면 이동 버튼
struct SignUpButton: View {
    var body: some View {
        NavigationLink(
            destination: SignUpView(),  //회원가입 화면 이동
            label: {
                Text("button.sign.up".localized())
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(/*@START_MENU_TOKEN@*/.horizontal/*@END_MENU_TOKEN@*/)
                    .frame(maxWidth: .infinity, minHeight: 35)
                    .background(Color("#5E5E5E"))
            }
        )
    }
}

//MARK: - 아이디 찾기 화면 이동 버튼
struct FindAccountViewButton: View {
    @ObservedObject var signInViewModel: SignInViewModel
    
    var body: some View {
        NavigationLink(
            destination: FindAccountView(), //아이디 찾기 화면
            label: {
                HStack {
                    Spacer()
                    
                    Text("아이디 찾기")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.gray)
                        .underline()
                }
                .frame(width: 100)
            }
        )
    }
}

//MARK: - 비밀번호 변경 화면 이동 버튼
struct ChangePasswordButton: View {
    @ObservedObject var signInViewModel: SignInViewModel
    
    var body: some View {
        NavigationLink(
            destination: ChangePasswordView(isSigned: false),   //패스워드 변경 화면
            label: {
                HStack {
                    Text("button.change.password".localized())
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.gray)
                        .underline()
                        
                    Spacer()
                }
                .frame(width: 100)
            }
        )
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
