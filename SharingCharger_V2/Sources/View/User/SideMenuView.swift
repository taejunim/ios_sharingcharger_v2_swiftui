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
    @ObservedObject var reservation: ReservationViewModel
    
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
                        .frame(width: geometry.size.width/1.15, height: geometry.size.height)
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
                    UserProfile()
                    
                    Dividerline()
                    
                    UserPoint()
                    
                    UserReservationInfo(reservation: reservation)
                    
                    Dividerline()
                    
                    MenuList(sideMenu: sideMenu).padding(.horizontal)
                    
                    Spacer()
                }
                .frame(width: geometry.size.width/1.15, height: geometry.size.height)
                .offset(dragOffset)
            }
            .transition(.move(edge: .leading))
        }
    }
}

struct UserProfile: View {
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                //사용자 명
                Text(UserDefaults.standard.string(forKey: "userName") ?? "User Name")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(
                    action: {
                        
                    },
                    label: {
                        Image("Button-Setting")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                )
            }
            
            HStack {
                //사용자 ID
                Text(UserDefaults.standard.string(forKey: "userId") ?? "User ID")
                    .fontWeight(.bold)
                
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

struct UserPoint: View {
    @ObservedObject var point = PointViewModel()
        
    var body: some View {
        HStack {
            Text("잔여 포인트")
            
            Spacer()
            
            Text(String(point.currentPoint).pointFormatter())
                .foregroundColor(Color("#3498DB"))
            
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .onAppear {
            point.getCurrentPoint()
        }
    }
}

struct UserReservationInfo: View {
    @ObservedObject var reservation: ReservationViewModel
    
    var body: some View {
        HStack {
            Text("예약 상태")
            
            Spacer()
            
            VStack {
                Text(reservation.textReservationDate)
                Text(reservation.reservedChargerName)
            }
            .foregroundColor(Color("#E4513D"))
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

struct MenuList: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var sideMenu: SideMenuViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            
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
        SideMenuView(sideMenu: SideMenuViewModel(), reservation: ReservationViewModel())
    }
}
