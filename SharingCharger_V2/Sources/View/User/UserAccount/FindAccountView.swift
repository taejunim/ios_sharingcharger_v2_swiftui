//
//  FindAccountView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/17.
//

import SwiftUI

struct FindAccountView: View {
    @Environment(\.presentationMode) var presentationMode   //Back 버튼 기능 추가에 필요
    @ObservedObject var user = UserViewModel() //사용자 View Model
    
    var body: some View {
        ZStack {
            UserAuthView(user: user)
            
            if user.showFindAccountPopup {
               FindAccountPopup(user: user)
            }
        }
        .popup(
            isPresented: $user.viewUtil.isShowToast,   //팝업 노출 여부
            type: .floater(verticalPadding: 80),
            position: .bottom,                          //팝업 위치
            animation: .easeInOut(duration: 0.0),   //애니메이션 효과
            autohideIn: 1,  //팝업 노출 시간
            closeOnTap: false,
            closeOnTapOutside: false,
            view: {
                user.viewUtil.toast()    //Toast 팝업 화면
            }
        )
        .onAppear {
            user.viewPath = "findAccount"
            user.viewTitle = "title.account.find"
            user.showFindAccountPopup = false
            let isPresented = presentationMode.wrappedValue.isPresented
            if !isPresented {
                user.viewReset() //아이디 찾기 화면 초기화
            }
        }
    }
}

struct FindAccountButton: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var user: UserViewModel
    
    var body: some View {
        Button(
            action: {
                user.viewUtil.dismissKeyboard()  //키보드 닫기
                
                //아이디 찾기 정보 유효성 검사
                if user.validationCheck() {
                    user.requestFindId()                //아이디 찾기 실행
                    //서버 에러일 경우 팝업창 숨김
                    if user.result == "server error"{
                        user.showFindAccountPopup = false
                    }else{
                        user.showFindAccountPopup = true    //아이디 찾기 결과 창
                    }
                    
                }

            },
            label: {
                Text("아이디 찾기")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(Color("#3498DB"))
            }
        )
    }
}

struct FindAccountPopup: View {
    @ObservedObject var user: UserViewModel
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack {
                VStack(spacing: 0) {
                    HStack{
                        Text("아이디 찾기")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HorizontalDividerline()
                    
                    Spacer()
                    
                    VStack(spacing: 10) {
                       
                        if user.isFindAccount {
                            let searchIds = user.searchIds
                            Text("아이디 찾기 결과")
                            ForEach(searchIds, id: \.self) {id in
                                let name: String = id["username"]!
                                
                                Text("\(name)")
                            }
                        }else{
                            Text("입력한 정보와 일치하는 계정이 없습니다.")
                        }
                    }
                    .padding(.horizontal, 10)
                    
                    Spacer()
                    
                    Button(
                        
                        action: {
                            user.showFindAccountPopup = false
                        },
                        label: {
                            Text("확인")
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, maxHeight: 35)
                                .background(Color("#3498DB"))
                                .cornerRadius(5.0)
                                .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                        }
                    )
                    .padding(.horizontal, 10)
                }
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(5.0)
                .frame(width: geometryReader.size.width/1.2, height: 250)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 3, y: 3)
            }
            .padding()
            .frame(width: geometryReader.size.width, height: geometryReader.size.height)
            .background(Color.black.opacity(0.5))
        }
        .edgesIgnoringSafeArea(.all)
    }
}
