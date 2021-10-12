//
//  ChargerSearchInfo.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/13.
//
//  - 소스코드 분할

import SwiftUI

//MARK: - 충전기 검색 정보 화면 (충전기 지도 하단 영역)
struct ChargerSearchInfo: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var chargerSearch: ChargerSearchViewModel
    @ObservedObject var reservation: ReservationViewModel
    
    var body: some View {
        GeometryReader { (geometry) in
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    //사용자의 예약 정보 여부에 따라 버튼 변경
                    if !reservation.isUserReservation {
                        SearchModalButton(chargerMap: chargerMap, chargerSearch: chargerSearch) //검색조건 팝업창 버튼
                        
                        HorizontalDividerline() //구분선 - Horizontal Padding
                    }
                    else {
                        ReservationModalButton(chargerMap: chargerMap, reservation: reservation)    //예약 정보 팝업창 버튼
                    }
                    
                    SearchChargerList(chargerMap: chargerMap, chargerSearch: chargerSearch, reservation: reservation) //조회된 충전기 목록
                }
                .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.4)  //디바이스 화면 비율에 따라 자동 높이 조절
                .background(Color.white)
                .cornerRadius(5.0)
                .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                .padding(.horizontal, 20)
            }
            .onAppear {
                reservation.userIdNo = UserDefaults.standard.string(forKey: "userIdNo") ?? "" //사용자 ID 번호
                reservation.getUserReservation()    //사용자 예약 정보 호출
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
                    .padding(.trailing, 10)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up")
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.black)
                .padding()
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

//MARK: - 예약 정보 팝업 창 버튼
struct ReservationModalButton: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var reservation: ReservationViewModel

    var body: some View {
        Button(
            action: {
                let chargerId = reservation.reservedChargerId
                let chargerLatitude = chargerMap.latitude
                let chargerLongitude = chargerMap.longitude
                
                chargerMap.moveToReservedCharger(chargerId: chargerId, latitude: chargerLatitude, longitude: chargerLongitude)
            },
            label: {
                HStack {
                    //배터리 이미지
                    ZStack {
                        Circle()
                            .foregroundColor(Color("#0081C5"))
                            .shadow(color: Color("#006AC5"), radius: 1, x: 1.5, y: 1.5)

                        Image("Charge-Battery")
                            .resizable()
                            .scaledToFit()
                            .padding(3)
                    }
                    .frame(width: 70 ,height: 70)

                    Spacer()

                    VStack(spacing: 10) {
                        HStack {
                            //총 충전 시간 텍스트
                            Text("총 " + reservation.textChargingTime + " 충전")
                                .font(.title2)
                                .fontWeight(.bold)

                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: 55, height: 25)
                                    .foregroundColor(Color("#1ABC9C"))
                                    .shadow(color: Color("#006AC5"), radius: 1, x: 1.2, y: 1.2)

                                Text(reservation.textReservationStatus)
                                    .font(.subheadline)
                                    .foregroundColor(Color.white)
                                    .fontWeight(.bold)
                            }
                        }

                        //충전 시작 일시 ~ 종료 일시 텍스트
                        Text("\(reservation.textStartDay) \(reservation.textStartTime) ~ \(reservation.textEndTime)")
                    }
                    .padding(.trailing, 10)

                    Spacer()

                    Image(systemName: "chevron.up")
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .padding()
                .background(Color("#3498DB"))
            }
        )
    }
}

//MARK: - 검색된 충전기 목록
struct SearchChargerList: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var chargerSearch: ChargerSearchViewModel
    @ObservedObject var reservation: ReservationViewModel
    
    var body: some View {
        if chargerMap.searchChargers == [] {
            
            
            VStack(spacing: 5) {
                if !chargerMap.viewUtil.isLoading {
                    Image(systemName: "exclamationmark.circle")
                        .font(.largeTitle)
                        .foregroundColor(Color("#BDBDBD"))
                    
                    Text("주변에 이용 가능한 충전기가 없습니다.")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.center)
                }
                else {
                    Image(systemName: "ellipsis.circle")
                        .font(.largeTitle)
                        .foregroundColor(Color("#BDBDBD"))
                    
                    Text("주변에 이용 가능한 충전기를 찾는 중입니다.")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .padding()
        }
        else {
            ScrollView {
                VStack {
                    let searchChargers = chargerMap.searchChargers  //조회된 충전기 목록
                    
                    //조회된 충전기 목록 생성
                    ForEach(searchChargers, id: \.self) { charger in
                        let chargerId: String = charger["chargerId"]!   //충전기 ID
                        let chargerName: String = charger["chargerName"]!   //충전기 명
                        let bleNumber: String = charger["bleNumber"]!   //BLE Number
                        let address: String = charger["address"]!   //주소
                        let detailAddress: String = charger["detailAddress"]!   //상세주소
                        let chargerStatus: String = charger["chargerStatus"]!   //충전기 상태
                        var statusText: String = "" //충전기 상태 텍스트
                        var statusColor: String = ""    //충전기 상태 색상
                        
                        //충전기 상태에 따른 이미지, 텍스트, 색상 지정
                        let chargerImage: String = {
                            //충전 대기 상태
                            if chargerStatus == "READY" {
                                statusText = "대기중"
                                statusColor = "#3498DB"
                                
                                return "Map-Pin-Blue-Select"
                            }
                            //예약 상태
                            else if chargerStatus == "RESERVATION" {
                                statusText = "예약중"
                                
                                if reservation.isUserReservation {
                                    if chargerId == reservation.reservedChargerId {
                                        statusColor = "#1ABC9C"
                                    }
                                    else {
                                        statusColor = "#C0392B"
                                    }
                                }
                                else {
                                    statusColor = "#C0392B"
                                }
                                
                                return "Map-Pin-Red-Select"
                            }
                            else if chargerStatus == "CHARGING" {
                                
                                if reservation.isUserReservation {
                                    if chargerId == reservation.reservedChargerId {
                                        statusText = "충전중"
                                        statusColor = "#1ABC9C"
                                    }
                                    else {
                                        statusText = "사용중"
                                        statusColor = "#C0392B"
                                    }
                                }
                                else {
                                    statusText = "사용중"
                                    statusColor = "#C0392B"
                                }
                                
                                return "Map-Pin-Red-Select"
                            }
                            else {
                                statusText = "충전불가"
                                statusColor = "#C0392B"
                                
                                return "Map-Pin-Red-Select"
                            }
                        }()
                        
                        Button(
                            action: {
                                chargerMap.moveToSelectedCharger(chargerId: chargerId)
                            },
                            label: {
                                HStack {
                                    VStack(spacing: 1) {
                                        HStack(spacing: 1) {
                                            //충전기 이미지
                                            Image(chargerImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 25, height: 25)
                                                .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                                            
                                            HStack(spacing: 1) {
                                                //충전기 명
                                                Text(chargerName)
                                                    .fontWeight(.bold)
                                                //BLE 번호 - 뒷 번호 4자리 (##:##)
                                                Text("(" + bleNumber.suffix(5) + ")")
                                                    .font(.subheadline)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        
                                        HStack(spacing: 1) {
                                            Rectangle()
                                                .frame(width: 25, height: 25)
                                                .foregroundColor(Color.white)
                                            
                                            VStack(alignment: .leading) {
                                                //충전기 주소
                                                Text(address)
                                                    .font(.subheadline)
                                                //충전기 상세주소
                                                Text(detailAddress)
                                                    .font(.subheadline)
                                            }
                                            .foregroundColor(Color.gray)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    //충전기 상태 표시
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .frame(width: 70, height: 25)
                                            .foregroundColor(Color(statusColor))    //충전기 상태에 따른 배경 색상
                                            .shadow(color: .gray, radius: 1, x: 1.2, y: 1.2)
                                        
                                        Text(statusText)
                                            .font(.subheadline)
                                            .foregroundColor(Color.white)
                                            .fontWeight(.bold)
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
}


struct SearchInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ChargerSearchInfo(chargerMap: ChargerMapViewModel(), chargerSearch: ChargerSearchViewModel(), reservation: ReservationViewModel())
    }
}
