//
//  ChargerMapView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/09.
//

import SwiftUI

struct ChargerMapView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewOptionSet = ViewOptionSet() //화면 Option Set
    @ObservedObject var chargerMap = ChargerMapViewModel()
    @ObservedObject var sideMenu = SideMenuViewModel()

    var body: some View {
        ZStack {
            //자동 로그인 시, NavigationView 화면 추가
            if UserDefaults.standard.bool(forKey: "autoSignIn") {
                NavigationView {
                    ZStack {
                        MapView(
                            latitude: $chargerMap.latitude,
                            longitude: $chargerMap.longitude,
                            markerItems: $chargerMap.markerItems,
                            getAddress: { (address) in
                                chargerMap.currentAddress = address
                            },
                            movedPoint: { (latitude, longitude)  in
                                chargerMap.latitude = latitude
                                chargerMap.longitude = longitude
                                chargerMap.getChargerList(zoomLevel: chargerMap.zoomLevel, latitude: chargerMap.latitude, longitude: chargerMap.longitude)
                            },
                            changedZoomLevel: { (zoomLevel) in
                                if chargerMap.zoomLevel != zoomLevel {
                                    print(zoomLevel)
                                    chargerMap.zoomLevel = zoomLevel
                                    chargerMap.getChargerList(zoomLevel: chargerMap.zoomLevel, latitude: chargerMap.latitude, longitude: chargerMap.longitude)
                                }
                            },
                            selectedMarker: { (markerId) in
                                chargerMap.selectedCharger(chargerId: markerId)
                            },
                            isTapOn: { (isTapOn) in
                                chargerMap.isTapOnMap = true
                                
                                withAnimation {
                                    chargerMap.isShowInfoView = false
                                }
                            }
                        )
                        .edgesIgnoringSafeArea(.all)

                        FrameView(chargerMap: chargerMap, sideMenu: sideMenu)
                        
                        ChargerInfoModal(chargerMap: chargerMap)

                        if sideMenu.isShowMenu {
                            SideMenuView(sideMenu: sideMenu)
                        }
                        
                        //로딩 표시 여부에 따라 표출
                        if chargerMap.viewUtil.isLoading {
                            chargerMap.viewUtil.loadingView()  //로딩 화면
                        }
                    }
                    .navigationBarHidden(true)
                }
            }
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

                    FrameView(chargerMap: chargerMap, sideMenu: sideMenu)

                    if sideMenu.isShowMenu {
                        SideMenuView(sideMenu: sideMenu)
                    }
                }
                .navigationBarHidden(true)
            }
        }
        .onAppear {
            chargerMap.getCurrentDate() { (currentDate) in
                chargerMap.currentDate = currentDate
            }
            
            chargerMap.location.startLocation()    //위치 서비스 시작
            chargerMap.getLoacation()   //현재 위치 정보 호출
            chargerMap.getChargerList(zoomLevel: 1, latitude: chargerMap.latitude, longitude: chargerMap.longitude)
        }
    }
}

struct FrameView: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var sideMenu: SideMenuViewModel
    
    var body: some View {
        VStack {
            HStack {
                SideMenuButton(sideMenu: sideMenu)
                
                Spacer().frame(width: 15)
                
                MapAddress(chargerMap: chargerMap)
            }
            .padding([.leading, .bottom, .trailing])
            
            HStack {
                Spacer()
                
                CurrentLocationButton(chargerMap: chargerMap)
            }
            .padding(.horizontal)
            
            Spacer()
            
            if !chargerMap.isShowInfoView {
                withAnimation {
                    SearchModalButton(chargerMap: chargerMap)
                        .transition(.move(edge: .bottom))
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

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

struct CurrentLocationButton: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        Button(
            action: {
                chargerMap.currentLocation()
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

struct SearchModalButton: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        Button(
            action: {
                chargerMap.isShowSearchModal = true
            },
            label: {
                VStack {
                    HStack {
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
                            Text("총 " + chargerMap.textChargingTime + " 충전")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("\(chargerMap.startDay) \(chargerMap.startTime)~\(chargerMap.endTime)")
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.up")
                    }
                    .foregroundColor(.black)
                    .padding()
                }
                .frame(maxWidth: .infinity, minHeight: 100)
                .background(Color.white)
                .cornerRadius(3.0)
                .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                .padding(.horizontal, 20)
            }
        )
        .onAppear {
            chargerMap.setTotalChargingTime()
            chargerMap.setSearchDate()
        }
        .sheet(
            isPresented: $chargerMap.isShowSearchModal,
            content: {
                ChargerSearchModal(chargerMap: chargerMap)
            }
        )
    }
}

struct ChargerMapView_Previews: PreviewProvider {
    static var previews: some View {
        ChargerMapView()
    }
}
