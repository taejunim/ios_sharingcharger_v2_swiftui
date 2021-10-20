//
//  ReservationView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/13.
//

import SwiftUI

//MARK: - 예약 화면
struct ReservationView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewUtil = ViewUtil()
    
    @ObservedObject var chargerMap: ChargerMapViewModel //충전기 지도 View Model
    @ObservedObject var chargerSearch: ChargerSearchViewModel   //충전기 검색 View Model
    @ObservedObject var reservation: ReservationViewModel   //예약 View Model
    @ObservedObject var point: PointViewModel   //포인트 View Model
    @ObservedObject var purchase = PurchaseViewModel()  //포인트 구매 View Model
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    VStack {
                        HStack {
                            Text("결제 정보 확인")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        
                        ReservedChargerSummaryInfo(chargerMap: chargerMap, chargerSearch: chargerSearch)    //예약할 충전기 요약 정보
                        
                        VerticalDividerline()
                        
                        ReservationPointInfo(reservation: reservation, purchase: purchase)  //예약 포인트 정보
                        
                        VerticalDividerline()
                        
                        Precautions()   //예약 주의사항
                    }
                }
                
                ReservationButton(reservation: reservation) //예약 버튼
            }
            .navigationBarTitle(Text("예약 진행"), displayMode: .inline) //Navigation Bar 타이틀
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
            .onAppear {
                reservation.reservationType = chargerSearch.searchType  //충전 유형

                let chargingStartDate = chargerSearch.chargingStartDate!    //충전 시작일시
                let chargingEndDate = chargerSearch.chargingEndDate!    //충전 종료일시
                
                reservation.reservationStartDate = chargingStartDate    //예약 시작일시
                reservation.reservationEndDate = chargingEndDate    //예약 종료일시
                reservation.reservedChargerId = chargerMap.selectChargerId  //예약 충전기 ID
                
                //포인트 확인 후 예약 가능 여부 판별
                reservation.checkChargingPoint(
                    chargerId: chargerMap.selectChargerId,  //충전기 ID
                    chargingStartDate,  //충전 시작일시
                    chargingEndDate //충전 종료일시
                ) { (isReservable) in
                    reservation.isReservable = isReservable //예약 가능 여부
                }
            }
            .popup(
                isPresented: $reservation.viewUtil.isShowToast,   //팝업 노출 여부
                type: .floater(verticalPadding: 80),
                position: .bottom,
                animation: .easeInOut(duration: 0.0),   //애니메이션 효과
                autohideIn: 1,  //팝업 노출 시간
                closeOnTap: false,
                closeOnTapOutside: false,
                view: {
                    reservation.viewUtil.toast()
                }
            )
            
            //포인트 부족 알림창에서 포인트 충전 진행 시, '포인트 결제 금액 입력 알림창' 호출
            if purchase.isShowPaymentInputAlert {
                PaymentInputAlert(purchase: purchase, point: point, reservation: reservation)   //포인트 결제 금액 입력 알림창
            }
            
            //결제 완료 시, '결제 완료 알림창' 호출
            if purchase.isShowCompletionAlert {
                PaymentCompletionAlert(purchase: purchase, point: point, reservation: reservation)  //결제 완료 알림창
            }
            
            //결제 실패 시, '결제 실패 알림창' 호출
            if purchase.isShowFailedAlert {
                PaymentFailedAlert(purchase: purchase)  //결제 실패 알림창
            }
            
            //예약 완료 버튼 클릭 시, '예약 확인 알림창' 호출
            if reservation.isShowConfirmAlert {
                ReservationConfirmAlert(chargerMap: chargerMap, chargerSearch: chargerSearch, reservation: reservation)    //예약 알림창
            }
        }
    }
}

//MARK: - 예약할 충전기 요약 정보
struct ReservedChargerSummaryInfo: View {
    @ObservedObject var chargerMap: ChargerMapViewModel //충전기 지도 View Model
    @ObservedObject var chargerSearch: ChargerSearchViewModel   //충전기 검색 View Model
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 0) {
                    //충전기 명
                    Text(chargerMap.chargerName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("#E74C3C"))
                    
                    Text("(" + chargerMap.bleNumber.suffix(5) + ")")    //충전기 BLE 번호 '(##:##)'
                    
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    Text(chargerMap.chargerAddress) //충전기 주소
                    Text(chargerMap.chargerDetailAddress) //충전기 상세주소
                }
                .foregroundColor(Color.gray)
            }
            
            //충전 예약 시간 정보
            VStack(alignment: .leading, spacing: 5) {
                //충전 예약 시작일시
                HStack(spacing: 1) {
                    Text("충전 예약 시작일시 : ")
                    Text("yyyy-MM-dd HH:mm".dateFormatter(formatDate: chargerSearch.chargingStartDate!))
                }
                
                //충전 예약 종료일시
                HStack(spacing: 1) {
                    Text("충전 예약 종료일시 : ")
                    Text("yyyy-MM-dd HH:mm".dateFormatter(formatDate: chargerSearch.chargingEndDate!))
                }
                
                //충 충전 예약 시간
                HStack(spacing: 1) {
                    Text("총 충전 예약 시간 : ")
                    Text(chargerSearch.textChargingTime)
                }
            }
        }
        .padding(.horizontal)
    }
}

//MARK: - 예약 포인트 정보
struct ReservationPointInfo: View {
    @ObservedObject var reservation: ReservationViewModel   //예약 View Model
    @ObservedObject var purchase: PurchaseViewModel //포인트 구매 View Model
    
    var body: some View {
        VStack(spacing: 1) {
            //현재 잔여 포인트
            HStack {
                Text("현재 잔여 포인트")
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(reservation.textUserPoint.pointFormatter())
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(minWidth: 120, minHeight: 30)
                    .background(Color(reservation.isReservable ? "#3498DB" : "#C0392B"))
                    .cornerRadius(20.0)
                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
            }
            
            VerticalDividerline()
            
            //예상 차감 포인트
            HStack {
                Text("예상 차감 포인트")
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("-" + reservation.textExpectedPoint.pointFormatter())
                    .fontWeight(.bold)
                    .foregroundColor(Color("#C0392B"))
                    .frame(minHeight: 30)
            }
            
            VerticalDividerline()
            
            //예약 가능 상태
            if reservation.isReservable {
                //예약 진행 후 현재 잔여 포인트
                HStack {
                    Text("예약 진행 후 잔여 포인트")
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text(reservation.textRemainingPoint.pointFormatter())
                        .fontWeight(.bold)
                        .foregroundColor(Color("#3498DB"))
                        .frame(minHeight: 30)
                }
            }
            //예약 불가능 상태 - 포인트 부족
            else {
                //예약 진행 부족 포인트
                HStack {
                    Text("예약 진행 부족 포인트")
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text(reservation.textNeedPoint.pointFormatter())
                        .fontWeight(.bold)
                        .foregroundColor(Color("#C0392B"))
                        .frame(minHeight: 30)
                }
                
                VerticalDividerline()
                
                //포인트 구매 버튼
                Button(
                    action: {
                        purchase.parentView = "reservationView" //결제창 호출 화면
                        purchase.isShowPaymentInputAlert = true //결제 금액 입력 팝업창 호출
                    },
                    label: {
                        Text("포인트 충전")
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, minHeight: 30)
                            .background(Color("#C0392B"))
                            .cornerRadius(5.0)
                            .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                    }
                )
            }
        }
        .padding(.horizontal)
    }
}

//MARK: - 주의사항
struct Precautions: View {
    var body: some View {
        VStack(spacing: 10) {
            //주의사항 제목
            HStack {
                Text("※ 예약 전 주의 사항")
                    .font(.headline)
                    .foregroundColor(Color("#E74C3C"))
                
                Spacer()
            }
            
            //주의사하아 내용
            Text("하단의 '예약 완료' 버튼 클릭 시 포인트가 차감됩니다.\n포인트 부족 시에는 포인트를 충전 후 예약을 진행하여 주시기 바랍니다.")
                .font(.subheadline)
                .foregroundColor(Color("#5E5E5E"))
        }
        .padding(.horizontal)
    }
}

//MARK: - 예약 완료 버튼
struct ReservationButton: View {
    @ObservedObject var reservation: ReservationViewModel   //예약 View Model
    
    var body: some View {
        Button(
            action: {
                reservation.isShowConfirmAlert = true   //예약 확인 알림창
            },
            label: {
                Text("예약 완료")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(Color(reservation.isReservable ? "#3498DB" : "#BDBDBD"))    //예약 가능 상태에 따라 버튼 색상 변경
            }
        )
        .disabled(!reservation.isReservable)    //예약 가능 상태에 따라 버튼 비활성화
    }
}

struct ReservationView_Previews: PreviewProvider {
    static var previews: some View {
        ReservationView(chargerMap: ChargerMapViewModel(), chargerSearch: ChargerSearchViewModel(), reservation: ReservationViewModel(), point: PointViewModel())
    }
}
