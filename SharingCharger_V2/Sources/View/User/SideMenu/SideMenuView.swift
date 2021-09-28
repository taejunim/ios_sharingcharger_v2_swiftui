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
    @ObservedObject var point: PointViewModel
    @ObservedObject var purchase: PurchaseViewModel
    
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
                    UserProfile(sideMenu: sideMenu)
                    
                    Dividerline()
                    
                    UserPoint(point: point, purchase: purchase)
                    
                    UserReservationInfo(reservation: reservation)
                    
                    Dividerline()
                    
                    MenuList(sideMenu: sideMenu, point: point, purchase: purchase)
                        .padding(.horizontal)
                    
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
    @ObservedObject var sideMenu: SideMenuViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                //사용자 명
                Text(UserDefaults.standard.string(forKey: "userName") ?? "User Name")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                UserSettingButton(sideMenu: sideMenu)
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

struct UserSettingButton: View {
    @ObservedObject var sideMenu: SideMenuViewModel
    
    var body: some View {
        NavigationLink(
            destination: UserSettingView(sideMenu: sideMenu),
            label: {
                Image("Button-Setting")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
            }
        )
    }
}

//MARK: - 사용자 포인트 정보
struct UserPoint: View {
    @ObservedObject var point: PointViewModel
    @ObservedObject var purchase: PurchaseViewModel
        
    var body: some View {
        HStack {
            Text("잔여 포인트")
            
            Spacer()
            
            //사용자 잔여 포인트
            Text(String(point.currentPoint).pointFormatter())
                .foregroundColor(Color("#3498DB"))
                .fontWeight(.bold)
            
            //포인트 구매 버튼
            PointPaymentButton(purchase: purchase)
                .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .onAppear {
            point.getCurrentPoint()
        }
    }
}

//MARK: - 포인트 구매 버튼
struct PointPaymentButton: View {
    @ObservedObject var purchase: PurchaseViewModel
    
    var body: some View {
        Button(
            action: {
                purchase.showPaymentInputAlert = true   //포인트 결제 진행 알림창 열기
            },
            label: {
                Text("충전하기")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(minWidth: 100, minHeight: 30)
                    .background(Color("#3498DB"))
                    .cornerRadius(5.0)
            }
        )
    }
}

//MARK: - 사용자 예약 정보
struct UserReservationInfo: View {
    @ObservedObject var reservation: ReservationViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("예약 상태")
                
                Spacer()
                
                //예약 정보가 있는 경우
                if reservation.isUserReservation {
                    //예약 일시
                    Text(reservation.textReservationDate)
                        .foregroundColor(Color("#C0392B"))
                }
                else {
                    Text("-")
                }
            }
            
            //예약 정보가 있는 경우
            if reservation.isUserReservation {
                HStack {
                    Spacer()
                    
                    //예약 충전기 명
                    Text(reservation.reservedChargerName)
                        .foregroundColor(Color("#C0392B"))
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}

//MARK: - 메뉴 목록
struct MenuList: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var sideMenu: SideMenuViewModel
    @ObservedObject var point: PointViewModel
    @ObservedObject var purchase: PurchaseViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            ChargerUseHistoryMenuButton()   //충전기 사용 이력 메뉴 버튼
            
            DigitalWalletMenuButton()   //전자지갑 메뉴 버튼
            
            FavoritesMenuButton()   //즐겨찾기 메뉴 버튼
            
            IdentificationMenuButton() //회원 증명서 메뉴 버튼
            
            CustomerServiceMenuButton() //고객센터 메뉴 버튼
            
            NoticeMenuButton()  //공지사항 메뉴 버튼
            
            //회원 유형이 개인 소유주인 경우에만 노출
            if UserDefaults.standard.string(forKey: "userType") == "Personal" {
                OwnerChargerMenuButton()   //소유주 충전기 관리 메뉴 버튼
            }
        }
    }
}

//MARK: - 충전기 사용 이력 메뉴 버튼
struct ChargerUseHistoryMenuButton: View {
    var body: some View {
        NavigationLink(
            destination: ChargerUseHistoryView(),
            label: {
                HStack {
                    Text("충전기 사용 이력")
                    
                    Spacer()
                }
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, maxHeight: 40)
                .padding(.vertical, 5)
            }
        )
    }
}

//MARK: - 전자지갑 메뉴 버튼
struct DigitalWalletMenuButton: View {
    var body: some View {
        NavigationLink(
            destination: DigitalWalletView(),
            label: {
                HStack {
                    Text("전자지갑")
                    
                    Spacer()
                }
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, maxHeight: 40)
                .padding(.vertical, 5)
            }
        )
    }
}

//MARK: - 즐겨찾기 메뉴 버튼
struct FavoritesMenuButton: View {
    var body: some View {
        NavigationLink(
            destination: FavoritesView(),
            label: {
                HStack {
                    Text("즐겨찾기")
                    
                    Spacer()
                }
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, maxHeight: 40)
                .padding(.vertical, 5)
            }
        )
    }
}

//MARK: - 회원 증명서 메뉴 버튼
struct IdentificationMenuButton: View {
    var body: some View {
        NavigationLink(
            destination: IdentificationView(),
            label: {
                HStack {
                    Text("회원 증명서")
                    
                    Spacer()
                }
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, maxHeight: 40)
                .padding(.vertical, 5)
            }
        )
    }
}

//MARK: - 고객센터 메뉴 버튼
struct CustomerServiceMenuButton: View {
    var body: some View {
        Button(
            action: {
                
            },
            label: {
                HStack {
                    Text("고객센터")
                    
                    Spacer()
                }
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, maxHeight: 40)
                .padding(.vertical, 5)
            }
        )
    }
}

//MARK: - 공지사항 메뉴 버튼
struct NoticeMenuButton: View {
    var body: some View {
        NavigationLink(
            destination: NoticeView(),
            label: {
                HStack {
                    Text("공지사항")
                    
                    Spacer()
                }
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, maxHeight: 40)
                .padding(.vertical, 5)
            }
        )
    }
}

//MARK: - 소유자 충전기 관리 메뉴 버튼
struct OwnerChargerMenuButton: View {
    var body: some View {
        NavigationLink(
            destination: OwnerChargerView(),
            label: {
                HStack {
                    Text("충전기 관리")
                    
                    Spacer()
                }
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, maxHeight: 40)
                .padding(.vertical, 5)
            }
        )
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(
            sideMenu: SideMenuViewModel(),
            reservation: ReservationViewModel(),
            point: PointViewModel(),
            purchase: PurchaseViewModel()
        )
    }
}
