//
//  ChargerMapView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/09.
//

import SwiftUI

//MARK: - 충전기 지도 화면
struct ChargerMapView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewOptionSet = ViewOptionSet() //화면 Option Set
    @ObservedObject var sideMenu = SideMenuViewModel()  //사이드 메뉴 View Model
    @ObservedObject var chargerMap = ChargerMapViewModel()  //충전기 지도 View Model
    @ObservedObject var chargerSearch = ChargerSearchViewModel()    //충전기 조회 View Model
    @ObservedObject var reservation = ReservationViewModel()    //예약 View Model
    
    var body: some View {
        ZStack {
            //자동 로그인 시, NavigationView 화면 추가
            if UserDefaults.standard.bool(forKey: "autoSignIn") {
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
                                chargerMap.latitude = latitude  //위도
                                chargerMap.longitude = longitude    //경도
                                
                                //충전기 목록 호출
                                chargerMap.getChargerList(
                                    zoomLevel: chargerMap.zoomLevel,
                                    latitude: chargerMap.latitude,
                                    longitude: chargerMap.longitude,
                                    searchStartDate: chargerSearch.chargingStartDate!,
                                    searchEndDate: chargerSearch.chargingEndDate!
                                )
                            },
                            //지도 확대 및 축소 시 Zoom 레벨 호출
                            changedZoomLevel: { (zoomLevel) in
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
                                    )
                                }
                            },
                            //지도의 마커 선택 시 해당 마커의 ID 호출
                            selectedMarker: { (markerId) in
                                chargerMap.selectedCharger(chargerId: markerId) //충전기 마커 선택 시, 함수 실행(충전기 정보, 예약현황 등)
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

                        FrameView(sideMenu: sideMenu, chargerMap: chargerMap, chargerSearch: chargerSearch) //지도 프레임 화면 - 메뉴 버튼, 주소 검색 버튼, 하단 검색 조건 버튼
                        
                        ChargerInfoModal(chargerMap: chargerMap, chargerSearch: chargerSearch, reservation: reservation)    //충전기 정보 Modal View

                        //사이드 메뉴 표시 여부에 따라 노출
                        if sideMenu.isShowMenu {
                            SideMenuView(sideMenu: sideMenu)    //사이드 메뉴
                        }
                        
                        //로딩 표시 여부에 따라 표출
                        if chargerMap.viewUtil.isLoading {
                            chargerMap.viewUtil.loadingView()  //로딩 화면
                        }
                    }
                    .navigationBarHidden(true)
                }
            }
            //자동 로그인이 아닌 일반 로그인 시
            else {
                ZStack {
//                    MapView(
//                        latitude: $chargerMap.latitude,
//                        longitude: $chargerMap.longitude,
//                        getAddress: { address in
//                            chargerMap.currentAddress = address
//                        },
//                        selected: { selected in
//                            print(selected)
//                        }
//                    )
                    //.edgesIgnoringSafeArea(.all)

                    FrameView(sideMenu: sideMenu, chargerMap: chargerMap, chargerSearch: chargerSearch)

                    if sideMenu.isShowMenu {
                        SideMenuView(sideMenu: sideMenu)
                    }
                }
                .navigationBarHidden(true)
            }
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
                )
            }
        }
    }
}

//MARK: - 지도 프레임 화면
struct FrameView: View {
    @ObservedObject var sideMenu: SideMenuViewModel
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var chargerSearch: ChargerSearchViewModel
    
    var body: some View {
        VStack {
            HStack {
                SideMenuButton(sideMenu: sideMenu)  //사이드 메뉴 버튼
                Spacer().frame(width: 15)
                MapAddress(chargerMap: chargerMap)  //지도 주소
            }
            .padding([.leading, .bottom, .trailing])
            
            HStack {
                Spacer()
                CurrentLocationButton(chargerMap: chargerMap, chargerSearch: chargerSearch) //현재 위치 이동 버튼
            }
            .padding(.horizontal)
            
            Spacer()
            
            //충전기 정보 창 노출 여부에 따라 표시
            if !chargerMap.isShowInfoView {
                withAnimation {
                    //충전기 검색 정보 화면 - 충전기 조회 조건 버튼 및 조회한 충전기 목록
                    SearchInfoView(chargerMap: chargerMap, chargerSearch: chargerSearch)
                        .transition(.move(edge: .bottom))   //노출 시작 위치
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

//MARK: - 사이드 메뉴 버튼
struct SideMenuButton: View {
    @ObservedObject var sideMenu: SideMenuViewModel
    
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
struct MapAddress: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        Button(
            action: {
                
            },
            label: {
                HStack {
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
    }
}

//MARK: - 현재 위치 이동 버튼
struct CurrentLocationButton: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var chargerSearch: ChargerSearchViewModel
    
    var body: some View {
        Button(
            action: {
                //현재 위치 이동 실행 - 현재 위치 이동 시, 현재 위치의 충전기 목록 조회
                chargerMap.currentLocation(chargerSearch.chargingStartDate!, chargerSearch.chargingEndDate!)
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

//MARK: - 검색 정보 화면
struct SearchInfoView: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var chargerSearch: ChargerSearchViewModel
    
    var body: some View {
        GeometryReader { (geometry) in
            VStack {
                Spacer()
                
                VStack {
                    SearchModalButton(chargerMap: chargerMap, chargerSearch: chargerSearch) //검색조건 팝업창 버튼
                    
                    HorizontalDividerline() //구분선 - Horizontal Padding
                
                    SearchChargerList(chargerMap: chargerMap, chargerSearch: chargerSearch) //조회된 충전기 목록
                }
                .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.4)  //디바이스 화면 비율에 따라 자동 높이 조절
                .background(Color.white)
                .cornerRadius(5.0)
                .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                .padding(.horizontal, 20)
            }
        }
    }
}

//MARK: - 검색조건 설정 팝업 창 버튼
struct SearchModalButton: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var chargerSearch: ChargerSearchViewModel
    
    var body: some View {
        Button(
            action: {
                chargerMap.isShowSearchModal = true //검색조건 설정 팝업 창 호출 여부
            },
            label: {
                HStack {
                    //배터리 이미지
                    ZStack {
                        Circle()
                            .foregroundColor(Color("#3498DB"))
                            .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                        
                        Image("Charge-Battery")
                            .resizable()
                            .scaledToFit()
                            .padding(3)
                    }
                    .frame(width: 70 ,height: 70)
                    
                    Spacer()
                    
                    VStack(spacing: 10) {
                        //총 충전 시간 텍스트
                        Text("총 " + chargerSearch.textChargingTime + " 충전")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        //충전 시작 일시 ~ 종료 일시 텍스트
                        Text("\(chargerSearch.textStartDay) \(chargerSearch.textStartTime) ~ \(chargerSearch.textEndTime)")
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up")
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.black)
                .padding([.top, .leading, .trailing])
            }
        )
        .sheet(
            isPresented: $chargerMap.isShowSearchModal,
            content: {
                //충전기 검색조건 팝업 창
                ChargerSearchModal(chargerSearch: chargerSearch, chargerMap: chargerMap)
            }
        )
    }
}

//MARK: - 검색된 충전기 목록
struct SearchChargerList: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var chargerSearch: ChargerSearchViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                let searchChargers = chargerMap.searchChargers  //조회된 충전기 목록
                
                //조회된 충전기 목록 생성
                ForEach(searchChargers, id: \.self) { charger in
                    let chargerName: String = charger["chargerName"]!
                    let bleNumber: String = charger["bleNumber"]!
                    let address: String = charger["address"]!
                    let detailAddress: String = charger["detailAddress"]!
                    let chargerStatus: String = charger["chargerStatus"]!
                    
                    let chargerImage: String = {
                        if chargerStatus == "READY" {
                            return "Map-Pin-Blue-Select"
                        }
                        else if chargerStatus == "RESERVATION" {
                            return "Map-Pin-Red-Select"
                        }
                        else {
                            return "Map-Pin-Red-Select"
                        }
                    }()
                    
                    Button(
                        action: {
                            print(charger["chargerName"]!)
                        },
                        label: {
                            HStack {
                                VStack(spacing: 1) {
                                    HStack(spacing: 1) {
                                        Image(chargerImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 25, height: 25)
                                            .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                                        
                                        Text(chargerName)
                                            .fontWeight(.bold)
                                            .multilineTextAlignment(.leading)
                                        
                                        Text("(\(bleNumber))")
                                            .font(.subheadline)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                    }
                                    
                                    HStack(spacing: 1) {
                                        Rectangle()
                                            .frame(width: 25)
                                            .foregroundColor(Color.white)
                                        
                                        VStack(alignment: .leading) {
                                            Text(address)
                                                .font(.subheadline)
                                            
                                            Text(detailAddress)
                                                .font(.subheadline)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                
                                Spacer()
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .frame(width: 75, height: 30)
                                        .foregroundColor(Color("#3498DB"))
                                        .shadow(color: .gray, radius: 1, x: 1.2, y: 1.2)
                                    
                                    Text("충전 가능")
                                        .font(.subheadline)
                                        .foregroundColor(Color.white)
                                }
                            }
                            .foregroundColor(.black)
                            .padding(10)
                        }
                    )
                    
                    HorizontalDividerline()
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct ChargerMapView_Previews: PreviewProvider {
    static var previews: some View {
        ChargerMapView()
    }
}
