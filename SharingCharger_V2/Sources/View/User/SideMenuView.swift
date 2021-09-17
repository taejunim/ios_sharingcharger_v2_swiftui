//
//  SideMenu.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/11.
//

import SwiftUI

struct SideMenuView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var sideMenu: SideMenuViewModel
    
    @State var dragOffset = CGSize.zero //Drag Offset
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .foregroundColor(Color.black.opacity(0.2))
                        .onTapGesture {
                            sideMenu.isShowMenu = false
                        }.edgesIgnoringSafeArea(.all)
                    
                    Rectangle()
                        .foregroundColor(Color.white.opacity(0.85))
                        .frame(width: geometry.size.width/1.2, height: geometry.size.height)
                        .edgesIgnoringSafeArea(.all)
                        .transition(.move(edge: .leading))
                        .offset(dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                if gesture.translation.width < 0 {
                                        dragOffset.width = gesture.translation.width
                                    }
                                }
                                .onEnded { gesture in
                                    if gesture.translation.width < -120 {
                                        withAnimation {
                                            sideMenu.isShowMenu = false
                                        }
                                    }
                                    else {
                                        dragOffset = .zero
                                    }
                                }
                        )
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                VStack {
                    MenuList(sideMenu: sideMenu).padding(.horizontal)
                }
                .frame(width: geometry.size.width/1.2, height: geometry.size.height)
                .offset(dragOffset)
            }
            .transition(.move(edge: .leading))
        }
    }
}

struct Profile: View {
    var body: some View {
        Text("profile")
    }
}

struct UserPoint: View {
    var body: some View {
        Text("user point")
    }
}

struct UserReservationInfo: View {
    var body: some View {
        Text("Rervation")
    }
}

struct MenuList: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var sideMenu: SideMenuViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
//            NavigationLink(
//                destination: FavoritesView(),
//                isActive: $isActive,
//                label: {
//                    Button(
//                        action: {
//                            isActive = true
//                        },
//                        label: {
//                            HStack {
//                                Text("즐겨찾기")
//                                    .foregroundColor(Color.black)
//
//                                Spacer()
//                            }
//                            .frame(maxWidth: .infinity, maxHeight: 40)
//                        }
//                    )
//                }
//            )
//
//            NavigationLink(
//                destination: PointView(),
//                isActive: $isActive2,
//                label: {
//                    Button(
//                        action: {
//                            isActive2 = true
//                        },
//                        label: {
//                            HStack {
//                                Text("포인트 이력")
//                                    .foregroundColor(Color.black)
//
//                                Spacer()
//                            }
//                            .frame(maxWidth: .infinity, maxHeight: 40)
//                        }
//                    )
//                }
//            )
            
            FavoritesMenuButton()
            
            PointMenuButton()
            
            SignOutButton(sideMenu: sideMenu)
        }
    }
}

struct FavoritesMenuButton: View {
    
    var body: some View {
        NavigationLink(
            destination: FavoritesView(),
            label: {
                HStack {
                    Text("즐겨찾기")
                        .foregroundColor(Color.black)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: 40)
            }
        )
    }
}

struct PointMenuButton: View {
    var body: some View {
        NavigationLink(
            destination: PointHistoryView(),
            label: {
                HStack {
                    Text("포인트 이력")
                        .foregroundColor(Color.black)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: 40)
            }
        )
    }
}

struct SignOutButton: View {
    @ObservedObject var sideMenu: SideMenuViewModel
    
    var body: some View {
        Button(
            action: {
                for key in UserDefaults.standard.dictionaryRepresentation().keys {
                    UserDefaults.standard.removeObject(forKey: key.description)
                }
                withAnimation {
                    sideMenu.isSignOut = true
                    UserDefaults.standard.set(false, forKey: "autoSignIn")
                }
            },
            label: {
                HStack {
                    Text("로그아웃 - 임시")
                        .foregroundColor(Color.black)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: 40)
            }
        )
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(sideMenu: SideMenuViewModel())
    }
}
