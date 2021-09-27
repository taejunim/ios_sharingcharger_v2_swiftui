//
//  UserSettingView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/23.
//

import SwiftUI

struct UserSettingView: View {
    @Environment(\.presentationMode) var presentationMode   //Back 버튼 기능 추가에 필요
    @ObservedObject var sideMenu: SideMenuViewModel
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                ChangePasswordViewButton()
                
                Dividerline()
                
                SwitchOwnerButton()
                
                Dividerline()
            }
            
            SignOutButton(sideMenu: sideMenu)
            
            Spacer()
        }
        .navigationBarTitle(Text("설정"), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
    }
}

struct ChangePasswordViewButton: View {
    var body: some View {
        NavigationLink(
            destination: ChangePasswordView(isSigned: true),
            label: {
                HStack {
                    Text("비밀번호 찾기")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, maxHeight: 40)
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        )
    }
}

struct SwitchOwnerButton: View {
    var body: some View {
        NavigationLink(
            destination: NoticeView(),
            label: {
                HStack {
                    Text("소유주 전환")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, maxHeight: 40)
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        )
    }
}

struct SignOutButton: View {
    @ObservedObject var sideMenu: SideMenuViewModel
    
    var body: some View {
        Button(
            action: { 
                withAnimation(.easeInOut(duration: 1.5)) {
                    sideMenu.isSignOut = true
                    
                    for key in UserDefaults.standard.dictionaryRepresentation().keys {
                        UserDefaults.standard.removeObject(forKey: key.description)
                    }

                    UserDefaults.standard.set(false, forKey: "autoSignIn")
                }
            },
            label: {
                Text("로그아웃")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(Color("#5E5E5E"))
                    .padding(.horizontal)
            }
        )
    }
}

struct UserSettingView_Previews: PreviewProvider {
    static var previews: some View {
        UserSettingView(sideMenu: SideMenuViewModel())
    }
}
