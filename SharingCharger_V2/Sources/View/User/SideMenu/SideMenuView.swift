//
//  SideMenu.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/11.
//

import SwiftUI

//MARK: - 사이드 메뉴
struct SideMenuView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var sideMenu: SideMenuViewModel //사이드 메뉴 View Model
    @ObservedObject var reservation: ReservationViewModel   //예약 View Model
    @ObservedObject var point: PointViewModel   //포인트 View Model
    @ObservedObject var purchase: PurchaseViewModel //포인트 구매 View Model
    
    @State var dragOffset = CGSize.zero //Drag Offset
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    //우측 불투명 배경
                    Rectangle()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .foregroundColor(Color.black.opacity(0.2))
                        .onTapGesture {
                            sideMenu.isShowMenu = false //사이드 메뉴 비활성화
                        }
                        .edgesIgnoringSafeArea(.all)
                    
                    //좌측 사이드 메뉴 배경
                    Rectangle()
                        .foregroundColor(Color.white.opacity(0.85))
                        .frame(width: geometry.size.width/1.15, height: geometry.size.height)
                        .edgesIgnoringSafeArea(.all)
                        .transition(.move(edge: .leading))
                        .offset(dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    //드래그 이동 시, 사이드 메뉴 영역 좌측으로 이동
                                    if gesture.translation.width < 0 {
                                        dragOffset.width = gesture.translation.width
                                    }
                                }
                                .onEnded { gesture in
                                    //드래그 이동이 끝난 후, 이동 위치에 따라 사이드 메뉴 비활성화
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
                    UserProfile(sideMenu: sideMenu) //사용자 프로필
                    
                    Dividerline()
                    
                    UserPoint(point: point, purchase: purchase) //사용자 포인트 현황
                    
                    UserReservationInfo(reservation: reservation)   //사용자 예약 현황
                    
                    Dividerline()
                    
                    MenuList(sideMenu: sideMenu, point: point, purchase: purchase)  //메뉴 목록
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

//MARK: - 사용자 프로필
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
                
                UserSettingMenuButton(sideMenu: sideMenu)   //사용자 설정 메뉴 버튼
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

//MARK: - 사용자 설정 메뉴 버튼
struct UserSettingMenuButton: View {
    @ObservedObject var sideMenu: SideMenuViewModel
    
    var body: some View {
        NavigationLink(
            destination: UserSettingView(sideMenu: sideMenu),   //사용자 설정 화면
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
            Button(
                action: {
                    purchase.parentView = "sideMenuView"
                    purchase.isShowPaymentInputAlert = true   //포인트 결제 진행 알림창 열기
                },
                label: {
                    Text("충전하기")
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .padding(.horizontal)
                        .frame(minWidth: 100, minHeight: 30)
                        .background(Color("#3498DB"))
                        .cornerRadius(5.0)
                        .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                }
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .onAppear {
            point.getCurrentPoint()
        }
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
            
            ChargingHistoryMenuButton()   //충전기 사용 이력 메뉴 버튼
            
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
struct ChargingHistoryMenuButton: View {
    var body: some View {
        NavigationLink(
            destination: ChargingHistoryView(),   //충전기 사용 이력 화면
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
            destination: DigitalWalletView(),   //전자지갑 화면
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
            destination: FavoritesView(),   //즐겨찾기 화면
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
            destination: IdentificationView(),  //회원 증명서 화면
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
                showEmailDialog()
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
    
    func showEmailDialog() {
        
        let dialog = UIAlertController(title:"", message : "문의사항이 있으시면\n아래의 문의하기 버튼을 클릭해주세요.", preferredStyle: .alert)
        
        dialog
            .addAction(
                UIAlertAction(title: "닫기", style: UIAlertAction.Style.destructive) { (action:UIAlertAction) in
                    return
                }
            )
        
        dialog
            .addAction(
                UIAlertAction(title: "문의하기", style: UIAlertAction.Style.default) { (action:UIAlertAction) in
                    
                    let bodyContent: String = "App Version : \(String(describing: Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String))</br>"
                    + "Model Name : \(UIDevice.modelName)</br>"
                    + "OS Version : \(UIDevice.current.systemVersion)</br>"
                    + "이메일 : \(UserDefaults.standard.string(forKey: "userId") ?? "")</br>"
                    EmailHelper.shared.sendEmail(subject: "[몬딱충전 문의] : 제목을 입력해주세요.", body: bodyContent, to: "tjlim@metisinfo.co.kr")
                    return
                }
            )
        
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.rootViewController?.present(dialog, animated: true, completion: nil)
    }
}

//MARK: - 공지사항 메뉴 버튼
struct NoticeMenuButton: View {
    var body: some View {
        NavigationLink(
            destination: NoticeView(),  //공지사항 화면
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
            destination: OwnerChargerView(),    //소유주 충전기 관리 화면
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
