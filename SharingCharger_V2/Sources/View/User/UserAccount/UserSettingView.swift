//
//  UserSettingView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/23.
//

import SwiftUI

struct UserSettingView: View {
    @Environment(\.presentationMode) var presentationMode   //Back 버튼 기능 추가에 필요
    @ObservedObject var viewUtil = ViewUtil()   //화면 유틸리티
    @ObservedObject var sideMenu: SideMenuViewModel
    
    var body: some View {
        ZStack {
            VStack {
                VStack(spacing: 0) {
                    ChangePasswordViewButton()  //비밀번호 변경 화면 이동 버튼
                    
                    Dividerline()
                    
                    //일반 사용자에게만 노출
                    if UserDefaults.standard.string(forKey: "userType") == "General" {
                        SwitchOwnerButton(sideMenu: sideMenu) //소유주 전환 버튼
                    }
                    
                    Dividerline()
                }
                
                SignOutButton(sideMenu: sideMenu)   //로그아웃 버튼
                
                Spacer()
            }
            .navigationBarTitle(Text("설정"), displayMode: .inline) //Navigation Bar 타이틀
            .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
            .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
            .popup(
                isPresented: $sideMenu.isShowToast,   //팝업 노출 여부
                type: .floater(verticalPadding: 80),
                position: .bottom,
                animation: .easeInOut(duration: 0.0),   //애니메이션 효과
                autohideIn: 2,  //팝업 노출 시간
                closeOnTap: false,
                closeOnTapOutside: false,
                view: {
                    viewUtil.toastPopup(message: sideMenu.showMessage)
                }
            )
            
            //소유주 전환 확인 알림창 호출
            if sideMenu.isShowSwitchOwnerAlert {
               SwitchOwnerConfirmAlert(sideMenu: sideMenu)
            }
            
            //로그아웃 확인 알림창 호출
            if sideMenu.isShowSignOutAlert {
                SignOutConfirmAlert(sideMenu: sideMenu)
            }
        }
        .onDisappear {
            sideMenu.isShowSwitchOwnerAlert = false //소유주 전환 알림창 비활성화
            sideMenu.isShowSignOutAlert = false //로그아웃 알림창 비활성화
        }
    }
}

//MARK: - 비밀번호 변경 화면 이동 버튼
struct ChangePasswordViewButton: View {
    var body: some View {
        NavigationLink(
            destination: ChangePasswordView(isSigned: true),    //비밀번호 변경 화면
            label: {
                HStack {
                    Text("비밀번호 변경")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, minHeight: 40)
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        )
    }
}

//MARK: 소유주 전환 버튼
struct SwitchOwnerButton: View {
    @ObservedObject var sideMenu: SideMenuViewModel
    
    var body: some View {
        Button(
            action: {
                sideMenu.isShowSwitchOwnerAlert = true  //소유주 전환 확인 알림창 호출
            },
            label: {
                HStack {
                    Text("소유주 전환")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, minHeight: 40)
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        )
    }
}

//MARK: - 소유주 전환 확인 알림창
struct SwitchOwnerConfirmAlert: View {
    @ObservedObject var sideMenu: SideMenuViewModel
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack {
                VStack(spacing: 0) {
                    HStack{
                        Text("소유주 전환")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HorizontalDividerline()
                    
                    Spacer()
                    
                    HStack {
                        Text("소유주로 전환 시, 다시 일반 사용자로의 전환은 고객 센터를 통해서만 전환이 가능합니다.")
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    VStack {
                        Text("소유주 전환을 진행하시겠습니까?")
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 5) {
                        //취소 버튼 - 알림창 닫기
                        Button(
                            action: {
                                sideMenu.isShowSwitchOwnerAlert = false
                            },
                            label: {
                                Text("취소")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, minHeight: 35)
                                    .background(Color("#C0392B"))
                                    .cornerRadius(5.0)
                                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                            }
                        )
                        
                        //소유주 전환 확인 버튼
                        Button(
                            action: {
                                sideMenu.switchOwner()  //소유주 전환 실행
                                sideMenu.isShowSwitchOwnerAlert = false //소유주 전환 확인 알림창 닫기
                            },
                            label: {
                                Text("확인")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, minHeight: 35)
                                    .background(Color("#5E5E5E"))
                                    .cornerRadius(5.0)
                                    .shadow(color: Color.gray, radius: 1, x: 1.5, y: 1.5)
                            }
                        )
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(5.0)
                .frame(width: geometryReader.size.width/1.2, height: 200)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 3, y: 3)
            }
            .padding()
            .frame(width: geometryReader.size.width, height: geometryReader.size.height)
            .background(Color.black.opacity(0.5))
        }
        .edgesIgnoringSafeArea(.all)
    }
}

//MARK: - 로그아웃 버튼
struct SignOutButton: View {
    @ObservedObject var sideMenu: SideMenuViewModel
    
    var body: some View {
        Button(
            action: { 
                sideMenu.isShowSignOutAlert = true  //로그아웃 확인 알림창 호출
            },
            label: {
                Text("로그아웃")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(Color("#5E5E5E"))
                    .padding(.horizontal)
            }
        )
    }
}

//MARK: - 로그아웃 확인 알림창
struct SignOutConfirmAlert: View {
    @ObservedObject var sideMenu: SideMenuViewModel
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack {
                VStack(spacing: 0) {
                    HStack{
                        Text("로그아웃")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HorizontalDividerline()
                    
                    Spacer()
                    
                    VStack {
                        Text("로그아웃을 진행하시겠습니까?")
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 5) {
                        //취소 버튼 - 알림창 닫기
                        Button(
                            action: {
                                sideMenu.isShowSignOutAlert = false
                            },
                            label: {
                                Text("취소")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, minHeight: 35)
                                    .background(Color("#C0392B"))
                                    .cornerRadius(5.0)
                                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                            }
                        )
                        
                        //로그아웃 확인 버튼
                        Button(
                            action: {
                                withAnimation(.easeInOut(duration: 1.0)) {
                                    sideMenu.signOunt() //로그아웃 실행
                                }
                            },
                            label: {
                                Text("확인")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, minHeight: 35)
                                    .background(Color("#5E5E5E"))
                                    .cornerRadius(5.0)
                                    .shadow(color: Color.gray, radius: 1, x: 1.5, y: 1.5)
                            }
                        )
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(5.0)
                .frame(width: geometryReader.size.width/1.2, height: 200)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 3, y: 3)
            }
            .padding()
            .frame(width: geometryReader.size.width, height: geometryReader.size.height)
            .background(Color.black.opacity(0.5))
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct UserSettingView_Previews: PreviewProvider {
    static var previews: some View {
        UserSettingView(sideMenu: SideMenuViewModel())
    }
}
