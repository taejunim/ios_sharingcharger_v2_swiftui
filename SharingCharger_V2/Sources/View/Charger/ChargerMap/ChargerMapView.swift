//
//  ChargerMapView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/09.
//

import SwiftUI

//MARK: - 충전기 지도 화면
struct ChargerMapView: View {
    @ObservedObject var viewOptionSet = ViewOptionSet() //화면 Option Set
    @ObservedObject var sideMenu = SideMenuViewModel()  //사이드 메뉴 View Model
    @ObservedObject var chargerMap = ChargerMapViewModel()  //충전기 지도 View Model
    @ObservedObject var chargerSearch = ChargerSearchViewModel()    //충전기 조회 View Model
    @ObservedObject var reservation = ReservationViewModel()    //예약 View Model
    @ObservedObject var point = PointViewModel()    //포인트 View Model
    @ObservedObject var purchase = PurchaseViewModel()  //포인트 구매 View Model
    @ObservedObject var charging = ChargingViewModel()  //포인트 구매 View Model
    @ObservedObject var favorites = FavoritesViewModel()    //즐겨찾기 View Model
    
    var body: some View {
        //로그아웃 시, 로그인 화면으로 이동
        if sideMenu.isSignOut {
            SignInView()    //로그인 화면
        }
        else {
            NavigationView {
                ZStack {
                    //지도 화면
                    MapView(
                        mapView: $chargerMap.mapView,   //Map View
                        latitude: $chargerMap.latitude, //위도
                        longitude: $chargerMap.longitude,   //경도
                        markerItems: $chargerMap.markerItems,   //지도 마커 정보 목록
                        getAddress: { (address) in
                            chargerMap.currentAddress = address //현재 지도 중심의 주소
                        },
                        //지도 이동 후 위경도 정보 호출
                        movedPoint: { (latitude, longitude) in
                            //현재 위치 이동 시 실행 방지
                            if !chargerMap.isCurrentLocation {
                                chargerMap.latitude = latitude  //위도
                                chargerMap.longitude = longitude    //경도
                                
                                //충전기 목록 호출
                                chargerMap.getChargerList(
                                    zoomLevel: chargerMap.zoomLevel,
                                    latitude: chargerMap.latitude,
                                    longitude: chargerMap.longitude,
                                    searchStartDate: chargerSearch.chargingStartDate!,
                                    searchEndDate: chargerSearch.chargingEndDate!
                                ) { _ in }
                            }
                        },
                        //지도 확대 및 축소 시 Zoom 레벨 호출
                        changedZoomLevel: { (zoomLevel) in
                            //현재 위치 이동 시 실행 방지
                            if !chargerMap.isCurrentLocation {
                                //Zoom Level 변경된 경우 실행
                                if chargerMap.zoomLevel != zoomLevel {
                                    chargerMap.zoomLevel = zoomLevel    //Zoom Level
                                    
                                    //충전기 목록 호출
                                    chargerMap.getChargerList(
                                        zoomLevel: chargerMap.zoomLevel,
                                        latitude: chargerMap.latitude,
                                        longitude: chargerMap.longitude,
                                        searchStartDate: chargerSearch.chargingStartDate!,
                                        searchEndDate: chargerSearch.chargingEndDate!
                                    ) { _ in }
                                }
                            }
                        },
                        //지도의 마커 선택 시 해당 마커의 ID 호출
                        selectedMarker: { (markerId) in
                            chargerMap.selectedCharger(chargerId: markerId) //충전기 마커 선택 시, 함수 실행(충전기 정보, 예약현황 등)
                            favorites.getChargerFavorite(chargerId: String(markerId))
                        },
                        //지도 탭 이벤트 발생 시 실행(마커 선택 제외)
                        isTapOn: { (isTapOn) in
                            chargerMap.isTapOnMap = true    //지도 탭 여부

                            withAnimation {
                                chargerMap.isShowInfoView = false   //충전기 정보 화면 비활성
                            }
                        }
                    )
                    .edgesIgnoringSafeArea(.all)

                    Group {
                        //지도 프레임 화면 - 메뉴 버튼, 주소 검색 버튼, 하단 검색 조건 버튼
                        FrameView(sideMenu: sideMenu, chargerMap: chargerMap, chargerSearch: chargerSearch, reservation: reservation)
                        
                        //충전기 정보 Modal View
                        ChargerInfoModal(chargerMap: chargerMap, chargerSearch: chargerSearch, reservation: reservation, purchase: purchase, point: point, favorites: favorites)
                    }
                    
                    Group {
                        //로딩 표시 여부에 따라 표출
                        if chargerMap.viewUtil.isLoading {
                            chargerMap.viewUtil.loadingView()  //로딩 화면
                        }
                        
                        //사이드 메뉴 표시 여부에 따라 노출
                        if sideMenu.isShowMenu {
                            SideMenuView(sideMenu: sideMenu, chargerMap: chargerMap, reservation: reservation, point: point, purchase: purchase, favorites: favorites)    //사이드 메뉴
                        }
                    }
                    
                    //충전하기 버튼 클릭 시, 충전 화면 이동
                    if chargerMap.isShowChargingView {
                        ChargingView(chargerMap: chargerMap, reservation: reservation, charging: charging)
                            .transition(.move(edge: .trailing))   //노출 시작 위치
                    }
                    
                    Group {
                        //충전기 정보 Modal 화면에서 충전하기 진행 시, 잔여 포인트가 충분할 경우 '충전하기 알림창' 호출
                        if reservation.isShowChargingAlert {
                            ChargingAlert(chargerMap: chargerMap, chargerSearch: chargerSearch, reservation: reservation)   //충전하기 알림창
                        }
                        
                        //충전기 정보 Modal 화면에서 예약 취소 시, 예약 취소 알림창 호출
                        if reservation.isShowCancelAlert {
                            CancelReservationAlert(chargerMap: chargerMap, reservation: reservation)    //충전기 예약 취소 알림창
                        }
                    }
                    
                    Group {
                        //충전기 정보 Modal 화면에서 충전하기 진행 시, 잔여 포인트가 부족할 경우 '포인트 부족 알림창' 호출
                        if purchase.isShowPointLackAlert {
                            PointLackAlert(chargerMap: chargerMap, reservation: reservation, purchase: purchase)    //포인트 부족 알림창
                        }
                        
                        //포인트 부족 알림창에서 포인트 충전 진행 시, '포인트 결제 금액 입력 알림창' 호출
                        if purchase.isShowPaymentInputAlert {
                            PaymentInputAlert(purchase: purchase, point: point, reservation: reservation)   //포인트 결제 금액 입력 알림창
                        }
                        
                        //결제 완료 시, '결제 완료 알림창' 호출
                        if purchase.isShowCompletionAlert {
                            PaymentCompletionAlert(purchase: purchase, point: point, reservation: reservation)  //결제 완료 알림창
                        }
                        
                        if purchase.isShowFailedAlert {
                            PaymentFailedAlert(purchase: purchase)
                        }
                    }
                }
                .navigationBarHidden(true)
            }
            .onAppear {
                chargerMap.location.startLocation()    //위치 서비스 시작
                chargerMap.getLoacation()   //현재 위치 정보 호출

                chargerMap.radius = chargerSearch.selectRadius  //충전기 조회 반경범위
                chargerSearch.changeStartTimeRange()    //충전기 조회 - 충전 시작 시간 범위 설정

                //현재 시간 호출 후 충전기 목록 조회 호출
                chargerSearch.getCurrentDate() { (currentDate) in
                    let calcDate: Date = Calendar.current.date(byAdding: .second, value: chargerSearch.selectChargingTime, to: currentDate)!

                    chargerSearch.chargingStartDate = currentDate   //충전 시작일시
                    chargerSearch.chargingEndDate = calcDate    //충전 종료일시
                    chargerMap.searchStartDate = currentDate    //조회 시작일시
                    chargerMap.searchEndDate = calcDate //조회 종료일시
                    
                    //충전기 목록 조회
                    chargerMap.getChargerList(
                        zoomLevel: 0,   //Zoom Level
                        latitude: chargerMap.latitude,  //위도
                        longitude: chargerMap.longitude,    //경도
                        searchStartDate: chargerSearch.chargingStartDate!,  //조회 시작일시
                        searchEndDate: chargerSearch.chargingEndDate!   //조회 종료일시
                    ) { _ in }
                }
            }
        }
    }
}

//MARK: - 지도 프레임 화면
struct FrameView: View {
    @ObservedObject var sideMenu: SideMenuViewModel //사이드 메뉴 View Model
    @ObservedObject var chargerMap: ChargerMapViewModel //충전기 지도 View Model
    @ObservedObject var chargerSearch: ChargerSearchViewModel   //충전기 검색 View Model
    @ObservedObject var reservation: ReservationViewModel   //예약 View Model
    
    var body: some View {
        VStack {
            HStack {
                SideMenuButton(sideMenu: sideMenu)  //사이드 메뉴 버튼
                Spacer().frame(width: 15)
                MapAddressButton(chargerMap: chargerMap)  //지도 주소
            }
            .padding([.leading, .bottom, .trailing])
            
            HStack {
                Spacer()
                
                CurrentLocationButton(chargerMap: chargerMap, chargerSearch: chargerSearch, reservation: reservation) //현재 위치 이동 버튼
            }
            .padding(.horizontal)
            
            Spacer()
            
            //충전기 정보 창 노출 여부에 따라 표시
            if !chargerMap.isShowInfoView {
                withAnimation {
                    //충전기 검색 정보 화면 - 충전기 조회 조건 버튼 및 조회한 충전기 목록
                    ChargerSearchInfo(chargerMap: chargerMap, chargerSearch: chargerSearch, reservation: reservation)
                        .transition(.move(edge: .bottom))   //노출 시작 위치
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

//MARK: - 사이드 메뉴 버튼
struct SideMenuButton: View {
    @ObservedObject var sideMenu: SideMenuViewModel //사이드 메뉴 View Model
    
    var body: some View {
        Button(
            action: {
                withAnimation {
                    sideMenu.isShowMenu = true
                }
            },
            label: {
                Image("Button-Menu")
                    .resizable()
                    .scaledToFit()
                    .padding(3)
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .cornerRadius(5.0)
                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
            }
        )
    }
}

//MARK: - 지도 주소
struct MapAddressButton: View {
    @ObservedObject var chargerMap: ChargerMapViewModel //충전기 지도 View Model
    
    @State var viewPath: String = "chargerMap"
    
    var body: some View {
        Button(
            action: {
                chargerMap.isShowAddressSearchModal = true
            },
            label: {
                HStack {
                    //현재 지도 중심 주소
                    Text(chargerMap.currentAddress)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(Color.white)
                .cornerRadius(5.0)
                .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
            }
        )
        .sheet(
            isPresented: $chargerMap.isShowAddressSearchModal,
            content: {
                AddressSearchModal(chargerMap: chargerMap, regist: ChargerRegistViewModel(), viewPath: $viewPath) //주소 검색 모달 창
            }
        )
    }
}

//MARK: - 현재 위치 이동 버튼
struct CurrentLocationButton: View {
    @ObservedObject var chargerMap: ChargerMapViewModel //충전기 지도 View Model
    @ObservedObject var chargerSearch: ChargerSearchViewModel   //충전기 검색 View Model
    @ObservedObject var reservation: ReservationViewModel   //예약 View Model
    
    var body: some View {
        Button(
            action: {
                //검색조건의 충전 예약 유형이 '즉시 충전'인 경우
                if chargerSearch.selectChargeType == "Instant" {
                    chargerMap.getCurrentDate() { currentDate in
                        let calcDate: Date = Calendar.current.date(byAdding: .second, value: chargerSearch.selectChargingTime, to: currentDate)!

                        chargerSearch.selectStartDate = currentDate
                        chargerSearch.chargingStartDate = currentDate   //충전 시작일시
                        chargerSearch.chargingEndDate = calcDate    //충전 종료일시
                        
                        //현재 위치 이동 실행 - 현재 위치 이동 시, 현재 위치의 충전기 목록 조회
                        chargerMap.currentLocation(chargerSearch.chargingStartDate!, chargerSearch.chargingEndDate!)
                    }
                }
                //검색조건의 충전 예약 유형이 '예약 충전'인 경우
                else {
                    //현재 위치 이동 실행 - 현재 위치 이동 시, 현재 위치의 충전기 목록 조회
                    chargerMap.currentLocation(chargerSearch.chargingStartDate!, chargerSearch.chargingEndDate!)
                }
                
                reservation.getUserReservation()    //사용자의 현재 예약 정보 호출
            },
            label: {
                ZStack {
                    Circle()
                        .foregroundColor(.white)
                        .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                    
                    Image("Button-Location")
                        .resizable()
                        .scaledToFit()
                        .padding(5)
                }
                .frame(width: 40, height: 40)
            }
        )
    }
}

struct ChargerMapView_Previews: PreviewProvider {
    static var previews: some View {
        ChargerMapView()
    }
}
