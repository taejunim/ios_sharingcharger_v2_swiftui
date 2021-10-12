//
//  ChargingView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/15.
//

import SwiftUI

//MARK: - 충전 화면
struct ChargingView: View {
    @ObservedObject var viewUtil = ViewUtil()   //화면 유틸리티
    @ObservedObject var viewOptionSet = ViewOptionSet() //화면 옵션 설정
    @ObservedObject var chargerMap: ChargerMapViewModel //충전기 지도 View Model
    @ObservedObject var reservation: ReservationViewModel   //예약 View Model
    @ObservedObject var charging: ChargingViewModel //충전 View Model
    
    var body: some View {
        ZStack {
            NavigationView {
                ChargerBLESearchView(chargerMap: chargerMap, reservation: reservation, charging: charging)  //충전기 BLE 검색 화면
            }
            .onAppear {
                charging.userIdNo = reservation.userIdNo    //예약한 사용자 ID번호
                charging.reservationId = reservation.reservationId  //예약 ID
                charging.chargerId = reservation.reservedChargerId  //예약 충전기 ID
                charging.bleNumber = reservation.reservedchargerBLENumber   //예약 충전기 BLE 번호
                charging.chargerStatus = reservation.reservationStatus  //충전 예약 상태 - RESERVE: 예약, KEEP: 충전
                charging.reservationStartDate = reservation.reservationStartDate    //예약 시작일시
                charging.reservationEndDate = reservation.reservationEndDate    //예약 종료일시
                
                //사용자가 예약한 건에 대해 충전 상태인 경우
                if charging.chargerStatus == "KEEP" {
                    charging.isCharging = true  //충전 상태로 변경
                    charging.chargeId = UserDefaults.standard.string(forKey: "chargeId")!   //사용자 정보에 저장된 충전 정보 ID
                    charging.chargingStartDate = UserDefaults.standard.object(forKey: "chargingStartDate") as! Date //사용자 정보에 저장된 충전 시작일시 호출
                }
                else {
                    charging.isCharging = false //충전 상태 초기화
                }
                
                charging.searchChargerBLE() //충전기 검색
            }
            .popup(
                isPresented: $charging.isShowToast,   //팝업 노출 여부
                type: .floater(verticalPadding: 80),
                position: .bottom,
                animation: .easeInOut(duration: 0.0),   //애니메이션 효과
                autohideIn: 2,  //팝업 노출 시간
                closeOnTap: false,
                closeOnTapOutside: false,
                view: {
                    viewUtil.toastPopup(message: charging.showMessage)
                }
            )
            
            //로딩 화면 호출 여부에 따라 로딩 화면 호출
            if charging.isLoading {
                viewUtil.loadingView()  //로딩 화면
            }
        }
    }
}

//MARK: - 충전기 BLE 검색 화면
struct ChargerBLESearchView: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var reservation: ReservationViewModel
    @ObservedObject var charging: ChargingViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            ScrollView {
                VStack {
                    HStack {
                        Text("근처 충전기와 연결을 시작합니다.\n커넥터와 차량이 연결되어 있는지 확인 후, 충전기 앞에서 연결 버튼을 터치해 주세요.")
                            .foregroundColor(Color("#5E5E5E"))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 5)
                    
                    VerticalDividerline()
                    
                    ConnectionGuide()   //충전기 연결 가이드
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            
            ChargerBLESearchButton(charging: charging, chargerMap: chargerMap, reservation: reservation)  //충전기 BLE 검색 버튼
        }
        .navigationBarTitle(Text("충전기 검색"), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackMainButton(chargerMap: chargerMap, charging: charging, reservation: reservation))  //커스텀 Back 버튼 추가
    }
}

//MARK: - 충전기 연결 가이드
struct ConnectionGuide: View {
    var body: some View {
        VStack {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 90, height: 25)
                        .foregroundColor(Color("#3498DB"))    //충전기 상태에 따른 배경 색상
                        .shadow(color: .gray, radius: 1, x: 1.2, y: 1.2)
                    
                    Text("STEP 1")
                        .foregroundColor(Color.white)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Text("충전기에 전원이 들어와 있는지 확인하십시오.")
                    .foregroundColor(Color("#5E5E5E"))
                
                Spacer()
            }
            .padding(.top, 5)
            .frame(maxWidth: .infinity, minHeight: 100)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            
            HorizontalDividerline()
            
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 90, height: 25)
                        .foregroundColor(Color("#3498DB"))
                        .shadow(color: .gray, radius: 1, x: 1.2, y: 1.2)
                    
                    Text("STEP 2")
                        .foregroundColor(Color.white)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Text("충전기가 대기상태인지 확인하십시오.")
                    .foregroundColor(Color("#5E5E5E"))
                
                Spacer()
            }
            .padding(.top, 5)
            .frame(maxWidth: .infinity, minHeight: 100)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            
            HorizontalDividerline()
            
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 90, height: 25)
                        .foregroundColor(Color("#3498DB"))    //충전기 상태에 따른 배경 색상
                        .shadow(color: .gray, radius: 1, x: 1.2, y: 1.2)
                    
                    Text("STEP 3")
                        .foregroundColor(Color.white)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Text("충전기 근처에 스마트폰을 가져가십시오.\n자동으로 충전기 감지가 진행됩니다.")
                    .foregroundColor(Color("#5E5E5E"))
                
                Spacer()
            }
            .padding(.top, 5)
            .frame(maxWidth: .infinity, minHeight: 100)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .border(Color("#EFEFEF"), width: 2)
        .padding(.horizontal, 5)
    }
}

//MARK: - 충전기 BLE 검색 버튼
struct ChargerBLESearchButton: View {
    @ObservedObject var charging: ChargingViewModel
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var reservation: ReservationViewModel
    
    var body: some View {
        NavigationLink(
            destination: ChargerBLEControlView(charging: charging, chargerMap: chargerMap, reservation: reservation),
            isActive: $charging.isSearch,
            label: {
                Button(
                    action: {
                        charging.searchChargerBLE()
                    },
                    label: {
                        Text("충전기 검색")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(Color("#3498DB"))
                    }
                )
            }
        )
    }
}

//MARK: - 충전기 지도 화면 이동 버튼
struct BackMainButton: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var charging: ChargingViewModel
    @ObservedObject var reservation: ReservationViewModel
    
    var body: some View {
        Button(
            action: {
                withAnimation {
                    charging.isShowChargingResult = false
                    chargerMap.isShowChargingView = false
                }
                
                reservation.getUserReservation()
                
                //충전기 목록 재조회
                charging.getCurrentDate() { (currentDate) in
                    chargerMap.getChargerList(
                        zoomLevel: 0,   //Zoom Level
                        latitude: chargerMap.latitude,  //위도
                        longitude: chargerMap.longitude,    //경도
                        searchStartDate: currentDate,  //조회 시작일시
                        searchEndDate: currentDate   //조회 종료일시
                    ) { _ in }
                }
            },
            label: {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
                .padding(.trailing)
            }
        )
        .onDisappear {
            reservation.getUserReservation()    //사용자 예약 정보 조회
            
            //충전기 목록 재조회
            charging.getCurrentDate() { (currentDate) in
                chargerMap.getChargerList(
                    zoomLevel: 0,   //Zoom Level
                    latitude: chargerMap.latitude,  //위도
                    longitude: chargerMap.longitude,    //경도
                    searchStartDate: currentDate,  //조회 시작일시
                    searchEndDate: currentDate   //조회 종료일시
                ) { _ in }
            }
        }
    }
}

//MARK: - 충전기 BLE 제어 화면
struct ChargerBLEControlView: View {
    @Environment(\.presentationMode) var presentationMode   //Back 버튼 기능 추가에 필요
    
    @ObservedObject var charging: ChargingViewModel
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var reservation: ReservationViewModel
    
    var body: some View {
        ZStack {
            VStack {
                ChargerBLEConnectionButton(charging: charging)  //충전기 BLE 연결 버튼
                
                HorizontalDividerline()
                    .padding(.vertical)
                
                ChargingInfoView(charging: charging, chargerMap: chargerMap)  //충전 정보
                
                HorizontalDividerline()
                    .padding(.vertical)
                
                Spacer()
                
                ChargingTimer(charging: charging) //충전 타이머
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    ChargeStartButton(charging: charging)   //충전 시작 버튼
                    
                    Spacer()
                    
                    ChargeEndButton(charging: charging) //충전 종료 버튼
                    
                    Spacer()
                }
                .padding(.vertical)
                
                Spacer()
            }
            .padding(.top, 10)
            .navigationBarTitle(Text("충전"), displayMode: .inline) //Navigation Bar 타이틀
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
            
            //충전 종료 시, 충전 결과 팝업창 호출
            if charging.isShowChargingResult {
                ChargingResultAlert(charging: charging, chargerMap: chargerMap, reservation: reservation)
            }
        }
        .onAppear {
            charging.connectChargerBLE(bleNumber: charging.bleNumber)   //충전기 연결
        }
        .onDisappear {
            if charging.isConnect {
                charging.disconnetChargerBLE()
            }
        }
    }
}

//MARK: - 충전기 BLE 연결 버튼
struct ChargerBLEConnectionButton: View {
    @ObservedObject var charging: ChargingViewModel
    
    var body: some View {
        Button(
            action: {
                charging.connectChargerBLE(bleNumber: charging.bleNumber)
            },
            label: {
                Text(!charging.isConnect ? "충전기 연결" : "충전기 연결됨")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(Color(!charging.isConnect ? "#1ABC9C" : "#535353"))
                    .cornerRadius(5.0)
                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                    .padding(.horizontal)
            }
        )
        .padding(.top)
        .disabled(charging.isConnect)
    }
}

//MARK: - 충전 정보
struct ChargingInfoView: View {
    @ObservedObject var charging: ChargingViewModel
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 1) {
                    //충전기 명
                    Text(chargerMap.chargerName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    //BLE 번호 - 뒷 번호 4자리 (##:##)
                    Text("(" + charging.bleNumber.suffix(5) + ")")
                    
                    Spacer()
                }
                
                Text(chargerMap.chargerAddress) //충전기 주소
                    .foregroundColor(Color.gray)
                
                Text(chargerMap.chargerDetailAddress) //충전기 상세주소
                    .foregroundColor(Color.gray)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text("'예약 시작일시 :' yyyy-MM-dd HH:mm".dateFormatter(formatDate: charging.reservationStartDate!))
                Text("'예약 종료일시 :' yyyy-MM-dd HH:mm".dateFormatter(formatDate: charging.reservationEndDate!))
                
                if charging.isCharging {
                    Text("'충전 시작일시 :' yyyy-MM-dd HH:mm".dateFormatter(formatDate: charging.chargingStartDate))
                }
            }
            .foregroundColor(Color.gray)
        }
        .padding(.horizontal)
    }
}

//MARK: - 충전 타이머
struct ChargingTimer: View {
    @ObservedObject var charging: ChargingViewModel
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()    //타이머
    
    var body: some View {
        VStack {
            Text("\(String(format: "%02d",charging.hoursRemaining)):\(String(format: "%02d",charging.minutesRemaining))")
                .font(.system(size: 70))
                .fontWeight(.bold)
                .shadow(color: .gray, radius: 1, x: 1.8, y: 1.8)
                .onReceive(timer) { _ in
                    //타이머 시작 시에 실행
                    if charging.isStartTimer {
                        charging.chargingTimer()    //충전 시간 타이머 실행
                    }
                }
        }
    }
}

//MARK: - 충전 시작 버튼
struct ChargeStartButton: View {
    @ObservedObject var charging: ChargingViewModel
    
    var body: some View {
        Button(
            action: {
                charging.requestStartCharging() //충전 시작 요청
            },
            label: {
                VStack {
                    ZStack {
                        Circle()
                            .foregroundColor(!charging.isConnect ? Color("#BDBDBD") : charging.isCharging ? Color("#BDBDBD") : Color("#3498DB"))
                            .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                        
                        Image("Charge-State-Start")
                            .resizable()
                            .scaledToFit()
                            .padding()
                    }
                    .frame(width: 100 ,height: 100)
                    
                    Text("충전 시작")
                        .foregroundColor(!charging.isConnect ? Color("#BDBDBD") : charging.isCharging ? Color("#BDBDBD") : Color.black)
                        .fontWeight(!charging.isConnect ? .none : charging.isCharging ? .none : .semibold)
                        .shadow(color: .gray, radius: 1, x: 1.2, y: 1.2)
                }
            }
        )
        .disabled(!charging.isConnect ? true : charging.isCharging)
    }
}

//MARK: - 충전 종료 버튼
struct ChargeEndButton: View {
    @ObservedObject var charging: ChargingViewModel
    
    var body: some View {
        Button(
            action: {
                charging.requestEndCharging()   //충전 종료 요청 
            },
            label: {
                VStack {
                    ZStack {
                        Circle()
                            .foregroundColor(!charging.isConnect ? Color("#BDBDBD") : !charging.isCharging ? Color("#BDBDBD") : Color("#C0392B"))
                            .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                        
                        Image("Charge-State-End")
                            .resizable()
                            .scaledToFit()
                            .padding()
                    }
                    .frame(width: 100 ,height: 100)
                    
                    Text("충전 종료")
                        .foregroundColor(!charging.isConnect ? Color("#BDBDBD") : !charging.isCharging ? Color("#BDBDBD") : Color.black)
                        .fontWeight(!charging.isCharging ? .none : .semibold)
                        .shadow(color: .gray, radius: 1, x: 1.2, y: 1.2)
                }
            }
        )
        .disabled(!charging.isCharging)
    }
}

struct ChargingView_Previews: PreviewProvider {
    
    static var previews: some View {
        ChargingView(chargerMap: ChargerMapViewModel(), reservation: ReservationViewModel(), charging: ChargingViewModel())
    }
}
