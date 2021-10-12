//
//  ChargerInfoModal.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/27.
//

import SwiftUI

//MARK: - 충전기 정보 Modal 화면
struct ChargerInfoModal: View {
    @ObservedObject var chargerMap: ChargerMapViewModel //충전기 지도 View Model
    @ObservedObject var chargerSearch: ChargerSearchViewModel   //충전기 검색 View Model
    @ObservedObject var reservation: ReservationViewModel   //예약 View Model
    @ObservedObject var purchase: PurchaseViewModel //포인트 구매 View Model
    @ObservedObject var point: PointViewModel   //포인트 View Model
    
    var body: some View {
        GeometryReader { (geometry) in
            SlideOverModal(
                isShown: $chargerMap.isShowInfoView,    //충전기 정보 Modal 활성화
                modalHeight: geometry.size.height/2.5,
                content: {
                    VStack {
                        VStack(spacing: 5) {
                            //예약 정보가 존재하고 해당 충전기가 예약된 충전기인 경우 노출
                            if reservation.isUserReservation == true && reservation.reservedChargerId == chargerMap.selectChargerId {
                                ReservationSummaryInfo(reservation: reservation)    //예약 요약 정보 화면
                                Dividerline()
                                    .padding(.vertical, 5)
                            }
                            
                            ChargerSummaryInfo(chargerMap: chargerMap)  //충전기 요약 정보 화면
                            ChargeUnitPrice(chargerMap: chargerMap) //충전 단가 정보
                            
                            //예약 정보가 없거나 해당 충전기가 예약된 충전기가 아닌 경우 노출
                            if reservation.isUserReservation == false || reservation.reservedChargerId != chargerMap.selectChargerId {
                                ChargerAvailableTime(chargerMap: chargerMap, reservation: reservation)  //충전이 이용 가능 시간 정보
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        ChargingProgressButton(chargerMap: chargerMap, chargerSearch: chargerSearch, reservation: reservation, purchase: purchase, point: point)  //충전 진행 버튼
                    }
                    .padding(.top, 25)
                }
            )
            .popup(
                isPresented: $reservation.viewUtil.isShowToast,   //팝업 노출 여부
                type: .floater(verticalPadding: 80),
                position: .bottom,
                animation: .easeInOut(duration: 0.0),   //애니메이션 효과
                autohideIn: 2,  //팝업 노출 시간
                closeOnTap: false,
                closeOnTapOutside: false,
                view: {
                    reservation.viewUtil.toast()
                }
            )
        }
    }
}

//MARK: - 예약 요약 정보
struct ReservationSummaryInfo: View {
    @ObservedObject var reservation: ReservationViewModel   //예약 View Model
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("총 " + reservation.textChargingTime + " 충전")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("\(reservation.textStartDay) \(reservation.textStartTime) ~ \(reservation.textEndDay) \(reservation.textEndTime)")
                
                Text("예상 차감 포인트 : " + reservation.textExpectedPoint.pointFormatter())
                    .foregroundColor(Color.gray)
            }
            
            Spacer()
        }
    }
}

//MARK: - 충전기 요약 정보 화면
struct ChargerSummaryInfo: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 0) {
                    //충전기 명
                    Text(chargerMap.chargerName)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("(" + chargerMap.bleNumber.suffix(5) + ")")
                    
                    ChargerFavoritesButton(chargerMap: chargerMap)  //충전기 즐겨찾기 버튼
                }
                
                Text(chargerMap.chargerAddress) //충전기 주소
                Text(chargerMap.chargerDetailAddress) //충전기 상세주소
                    .foregroundColor(Color.gray)
            }
            
            Spacer()
            
            ChargerNavigationButton(chargerMap: chargerMap) //충전기 내비게이션 버튼 - 카카오 내비게이션 연동
        }
    }
}

//MARK: - 충전기 즐겨찾기 버튼
struct ChargerFavoritesButton: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        Button(
            action: {
                if !chargerMap.isFavorites {
                    chargerMap.addFavorites()
                    chargerMap.isFavorites = true
                }
                else {
                    chargerMap.deleteFavorites()
                    chargerMap.isFavorites = false
                }
            },
            label: {
                Image(chargerMap.isFavorites ? "Charger-Favorite-Fill" : "Charger-Favorite")
                    .resizable()
                    .scaledToFit()
                    .padding(.bottom, 8)
                    .frame(width: 40, height: 40)
                    .cornerRadius(5.0)
                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
            }
        )
    }
}

//MARK: - 충전기 내비게이션 연동
struct ChargerNavigationButton: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        Button(
            action: {
                chargerMap.launchNavigation()
            },
            label: {
                ZStack {
                    Circle()
                        .foregroundColor(Color("#3498DB"))

                    Image("Map-Roadmap")
                        .resizable()
                        .scaledToFit()
                        .padding(.leading, 5)
                }
                .frame(width: 70 ,height: 70)
                .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
            }
        )
    }
}

//MARK: - 충전 단가 정보
struct ChargeUnitPrice: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        HStack {
            Text("충전 요금 :")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("시간 당 " + chargerMap.chargeUnitPrice.trimmingCharacters(in: ["p"]).pointFormatter())
            
            Spacer()
        }
    }
}

//MARK: - 충전기 이용 가능 시간 정보
struct ChargerAvailableTime: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var reservation: ReservationViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("이용 가능 시간")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            
            //Text("항시 충전 가능")
            
            //이용 가능 시간 라벨
            LazyHStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 150, height: 25)
                        .foregroundColor(Color("#1ABC9C"))
                        .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                    
                    Text("16:30 ~ 23:59")
                        .foregroundColor(Color.white)
                        .font(.footnote)
                        .fontWeight(.bold)
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 150, height: 25)
                        .foregroundColor(Color("#1ABC9C"))
                        .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                    
                    Text("00:00 ~ 23:59")
                        .foregroundColor(Color.white)
                        .font(.footnote)
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            
            Text("위 시간대 이용 가능")
                .font(.footnote)
        }
    }
}

//MARK: - 충전 진행 버튼
///검색 조건의 충전 유형에 따라 '즉시 충전', '예약 충전' 단계로 진행
struct ChargingProgressButton: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var chargerSearch: ChargerSearchViewModel
    @ObservedObject var reservation: ReservationViewModel
    @ObservedObject var purchase: PurchaseViewModel
    @ObservedObject var point: PointViewModel
    
    var body: some View {
        //사용자의 예약 정보가 없거나 다른 사용자가 예약한 충전기가 아닌 경우
        if reservation.isUserReservation == false || reservation.reservedChargerId != chargerMap.selectChargerId {
            
            //선택한 충전 유형에 따라 충전 단계 변경 - 즉시 충전 버튼
            if chargerSearch.searchType == "Instant" {
                InstantChargeButton(chargerMap: chargerMap, chargerSearch: chargerSearch, reservation: reservation, purchase: purchase)
            }
            //선택한 충전 유형에 따라 충전 단계 변경 - 예약 충전 버튼
            else if chargerSearch.searchType == "Scheduled" {
                ReservationChargeButton(chargerMap: chargerMap, chargerSearch: chargerSearch, reservation: reservation, purchase: purchase, point: point)
            }
        }
        else {
            //예약 상태
            if reservation.reservationStatus == "RESERVE" {
                HStack(spacing: 0) {
                    //충전 예약 취소 버튼
                    Button(
                        action: {
                            reservation.isShowCancelAlert = true
                        },
                        label: {
                            Text("예약 취소")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, maxHeight: 40)
                                .background(Color("#C0392B"))
                        }
                    )
                    
                    //충전 시작 진행 버튼
                    Button(
                        action: {
                            reservation.getCurrentDate() { (currentDate) in
                                
                                if currentDate > reservation.reservationStartDate! {
                                    withAnimation {
                                        chargerMap.isShowChargingView = true  //충전 화면 활성화
                                    }
                                }
                                else {
                                    chargerMap.isShowInfoView = false   //충전기 상세 화면 닫기
                                    reservation.viewUtil.isShowToast = true
                                    reservation.viewUtil.showToast(isShow: true, message: "현재 예약하신 충전 시간이 아닙니다.\n예약 시작일시 : \("yyyy-MM-dd HH:mm".dateFormatter(formatDate: reservation.reservationStartDate!))")
                                }
                            }
                        },
                        label: {
                            Text("충전 시작")
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
            //충전 상태
            else if reservation.reservationStatus == "KEEP" {
                Button(
                    action: {
                        withAnimation {
                            chargerMap.isShowChargingView = true  //충전 화면 활성화
                        }
                    },
                    label: {
                        Text("충전 종료")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, maxHeight: 40)
                            .background(Color("#C0392B"))
                    }
                )
            }
        }
    }
}

//MARK: - 즉시 충전 버튼
struct InstantChargeButton: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var chargerSearch: ChargerSearchViewModel
    @ObservedObject var reservation: ReservationViewModel
    @ObservedObject var purchase: PurchaseViewModel
    
    var body: some View {
        Button(
            action: {
                reservation.reservationType = chargerSearch.searchType  //충전 유형

                //현재 일시 호출 후 포인트 확인
                chargerSearch.getCurrentDate() { (currentDate) in
                    let chargingStartDate = currentDate //충전 시작일시
                    let chargingEndDate: Date = Calendar.current.date(byAdding: .second, value: chargerSearch.selectChargingTime, to: currentDate)! //충전 종료일시 계산
                    
                    //포인트 확인 실행
                    reservation.checkChargingPoint(chargerId: chargerMap.selectChargerId, chargingStartDate, chargingEndDate) { (isRechargeable) in
                        
                        //충전할 포인트가 있는 경우
                        if isRechargeable {
                            reservation.isShowChargingAlert = true    //충전 진행 알림창 호출
                        }
                        //충전할 포인트가 부족한 경우
                        else {
                            purchase.isShowPointLackAlert = true  //포인트 부족 알림창 호출
                        }
                    }
                }
            },
            label: {
                //선택한 충전 유형에 따라 버튼 라벨 변경
                Text("충전하기")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(reservation.isUserReservation ? Color("#EFEFEF") : Color("#3498DB"))
            }
        )
        .disabled(reservation.isUserReservation)
    }
}

//MARK: - 예약 충전 버튼
struct ReservationChargeButton: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var chargerSearch: ChargerSearchViewModel
    @ObservedObject var reservation: ReservationViewModel
    @ObservedObject var purchase: PurchaseViewModel
    @ObservedObject var point: PointViewModel
    
    var body: some View {
        NavigationLink(
            destination: ReservationView(chargerMap: chargerMap, chargerSearch: chargerSearch, reservation: reservation, point: point),
            label: {
                Text("예약하기")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(reservation.isUserReservation ? Color("#EFEFEF") : Color("#3498DB"))
            }
        )
        .disabled(reservation.isUserReservation)
    }
}

struct ChargerInfoModal_Previews: PreviewProvider {
    static var previews: some View {
        ChargerInfoModal(chargerMap: ChargerMapViewModel(), chargerSearch: ChargerSearchViewModel(), reservation: ReservationViewModel(), purchase: PurchaseViewModel(), point: PointViewModel())
    }
}
