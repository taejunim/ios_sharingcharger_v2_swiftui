//
//  ReservationView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/13.
//

import SwiftUI

struct ReservationView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var chargerSearch: ChargerSearchViewModel
    @ObservedObject var reservation: ReservationViewModel
    @ObservedObject var purchase: PurchaseViewModel
    
    var body: some View {
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
                    
                    ReservedChargerSummaryInfo(chargerMap: chargerMap, chargerSearch: chargerSearch)
                    
                    VerticalDividerline()
                    
                    ReservationPointInfo(reservation: reservation)
                    
                    VerticalDividerline()
                    
                    Precautions()
                }
            }
            
            ReservationButton(reservation: reservation)
        }
        .navigationBarTitle(Text("예약 진행"), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
        .onAppear {
            reservation.reservationType = chargerSearch.searchType  //충전 유형

            let chargingStartDate = chargerSearch.chargingStartDate!
            let chargingEndDate = chargerSearch.chargingEndDate!
            
            //포인트 확인 후 예약 가능 여부 판별
            reservation.checkChargingPoint(chargerId: chargerMap.selectChargerId, chargingStartDate, chargingEndDate) { (isReservable) in
                reservation.isReservable = isReservable
            }
        }
    }
}

struct ReservedChargerSummaryInfo: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var chargerSearch: ChargerSearchViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 0) {
                    //충전기 명
                    Text(chargerMap.chargerName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("#E74C3C"))
                    
                    Text("(" + chargerMap.bleNumber.suffix(5) + ")")
                    
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    Text(chargerMap.chargerAddress) //충전기 주소
                    Text(chargerMap.chargerDetailAddress) //충전기 상세주소
                }
                .foregroundColor(Color.gray)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 1) {
                    Text("충전 예약 시작일시 : ")
                    Text("yyyy-MM-dd HH:mm".dateFormatter(formatDate: chargerSearch.chargingStartDate!))
                }
                
                HStack(spacing: 1) {
                    Text("충전 예약 종료일시 : ")
                    Text("yyyy-MM-dd HH:mm".dateFormatter(formatDate: chargerSearch.chargingEndDate!))
                }
                
                HStack(spacing: 1) {
                    Text("총 충전 예약 시간 : ")
                    Text(chargerSearch.textChargingTime)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct ReservationPointInfo: View {
    @ObservedObject var reservation: ReservationViewModel
    
    var body: some View {
        VStack(spacing: 1) {
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
            
            if reservation.isReservable {
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
            else {
                HStack {
                    Text("예약 진행 부족 포인트")
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text(reservation.textNeedPoint.pointFormatter())
                        .fontWeight(.bold)
                        .foregroundColor(Color("#C0392B"))
                        .frame(minHeight: 30)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct Precautions: View {
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("※ 예약 전 주의 사항")
                    .font(.headline)
                    .foregroundColor(Color("#E74C3C"))
                
                Spacer()
            }
            
            Text("하단의 '예약 완료' 버튼 클릭 시 포인트가 차감됩니다.\n포인트 부족 시에는 포인트를 충전 후 예약을 진행하여 주시기 바랍니다.")
                .font(.subheadline)
                .foregroundColor(Color("#5E5E5E"))
        }
        .padding(.horizontal)
    }
}

struct ReservationButton: View {
    @ObservedObject var reservation: ReservationViewModel
    
    var body: some View {
        Button(
            action: {
                
            },
            label: {
                Text("예약 완료")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(Color(reservation.isReservable ? "#3498DB" : "#BDBDBD"))
            }
        )
        .disabled(!reservation.isReservable)
    }
}

struct ReservationView_Previews: PreviewProvider {
    static var previews: some View {
        ReservationView(chargerMap: ChargerMapViewModel(), chargerSearch: ChargerSearchViewModel(), reservation: ReservationViewModel(), purchase: PurchaseViewModel())
    }
}
