//
//  ChargingAlertView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/16.
//

import SwiftUI

struct ChargingAlert: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var chargerSearch: ChargerSearchViewModel
    @ObservedObject var reservation: ReservationViewModel
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack {
                VStack(spacing: 0) {
                    HStack{
                        Text("충전하기")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HorizontalDividerline()
                    
                    VStack(spacing: 10) {
                        HStack {
                            Text(chargerMap.chargerName)
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 5) {
                            HStack(spacing: 2) {
                                Text("충전 시작 :")
                                    .fontWeight(.bold)
                                
                                Text("\(chargerSearch.textStartDay) \(chargerSearch.textStartTime)")
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 2) {
                                Text("충전 종료 :")
                                    .fontWeight(.bold)
                                
                                Text("\(chargerSearch.textEndDay) \(chargerSearch.textEndTime)")
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Text("총 \(chargerSearch.textChargingTime) 충전")
                        .fontWeight(.bold)
                    
                    Text("충전을 진행하시겠습니까?")
                    
                    Spacer()
                    
                    HStack(spacing: 5) {
                        //취소 버튼 - 알림창 닫기
                        Button(
                            action: {
                                reservation.showChargingAlert = false
                            },
                            label: {
                                Text("취소")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, maxHeight: 35)
                                    .background(Color("#C0392B"))
                                    .cornerRadius(5.0)
                                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                            }
                        )
                        
                        Button(
                            action: {
                                //현재 일시 호출 후 즉시 충전 예약 진행
                                chargerSearch.getCurrentDate() { (currentDate) in
                                    let calcDate: Date = Calendar.current.date(byAdding: .second, value: chargerSearch.selectChargingTime, to: currentDate)!    //충전 종료 일시 계산

                                    chargerSearch.currentDate = currentDate //현재 일시
                                    chargerSearch.chargingStartDate = currentDate   //충전 시작일시
                                    chargerSearch.chargingEndDate = calcDate //충전 종료일시

                                    //즉시 충전 예약 실행
                                    reservation.reservation(chargerId: chargerMap.selectChargerId,  //충전기 ID
                                        chargerSearch.chargingStartDate!,   //충전 시작일시
                                        chargerSearch.chargingEndDate!  //충전 종료일시
                                    ) { (reservation) in
                                        
                                        withAnimation {
                                            chargerMap.showChargingView = true  //충전 화면 활성화
                                        }
                                        
                                        self.reservation.showChargingAlert = false  //충전하기 알림창 비활성화
                                        //chargerMap.currentLocation(chargerSearch.chargingStartDate!, chargerSearch.chargingEndDate!)    //현재 위치 조회
                                    }
                                }
                            },
                            label: {
                                Text("충전")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, maxHeight: 35)
                                    .background(Color("#3498DB"))
                                    .cornerRadius(5.0)
                                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                            }
                        )
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(5.0)
                .frame(width: geometryReader.size.width/1.3, height: 250)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 3, y: 3)
            }
            .padding()
            .frame(width: geometryReader.size.width, height: geometryReader.size.height)
            .background(Color.black.opacity(0.5))
        }
        .edgesIgnoringSafeArea(.all)
    }
}

//MARK: - 포인트 충전 알림창
struct ChargingPointAlert: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var reservation: ReservationViewModel
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack {
                VStack(spacing: 0) {
                    HStack{
                        Text("포인트 부족")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HorizontalDividerline()
                    
                    VStack(spacing: 10) {
                        VStack(spacing: 5) {
                            HStack(spacing: 2) {
                                Text("잔여 포인트 :")
                                    .fontWeight(.bold)
                                
                                Text(reservation.textUserPoint.pointFormatter())
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 1) {
                                Text("차감 포인트 :")
                                    .fontWeight(.bold)
                                
                                Text(reservation.textExpectedPoint.pointFormatter())

                                Spacer()
                            }
                            
                            HStack(spacing: 1) {
                                Text("부족 포인트 :")
                                    .fontWeight(.bold)
                                
                                Text(reservation.textNeedPoint.trimmingCharacters(in: ["-"]).pointFormatter())
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Text("포인트가 부족합니다.\n포인트를 충전하시겠습니까?")
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    HStack(spacing: 5) {
                        //취소 버튼 - 알림창 닫기
                        Button(
                            action: {
                                reservation.showChargingPointAlert = false 
                            },
                            label: {
                                Text("취소")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, maxHeight: 35)
                                    .background(Color("#C0392B"))
                                    .cornerRadius(5.0)
                                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                            }
                        )
                        
                        //포인트 충전 버튼
                        Button(
                            action: {
                                
                            },
                            label: {
                                Text("포인트 충전")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, maxHeight: 35)
                                    .background(Color("#3498DB"))
                                    .cornerRadius(5.0)
                                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                            }
                        )
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(5.0)
                .frame(width: geometryReader.size.width/1.3, height: 250)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 3, y: 3)
            }
            .padding()
            .frame(width: geometryReader.size.width, height: geometryReader.size.height)
            .background(Color.black.opacity(0.5))
        }
        .edgesIgnoringSafeArea(.all)
    }
}



//MARK: - 예약 취소 알림창
struct CancelReservationAlert: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var reservation: ReservationViewModel
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack {
                VStack(spacing: 0) {
                    HStack{
                        Text("예약 취소")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HorizontalDividerline()
                    
                    Spacer()
                    
                    Text("해당 충전기 예약 건을 취소하시겠습니까?")
                    
                    Spacer()
                    
                    HStack(spacing: 5) {
                        //취소 버튼 - 알림창 닫기
                        Button(
                            action: {
                                reservation.showCancelAlert = false //예약 취소 알림창 비활성화
                            },
                            label: {
                                Text("취소")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, maxHeight: 35)
                                    .background(Color("#C0392B"))
                                    .cornerRadius(5.0)
                                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                            }
                        )
                        
                        //예약 취소 확인 버튼
                        Button(
                            action: {
                                let reservationType = UserDefaults.standard.string(forKey: "reservationType")
                                
                                if reservationType == "Instant" {
                                    reservation.cancelInstantCharge() { (cancel) in
                                        reservation.showCancelAlert = false //예약 취소 알림창 비활성화
                                        chargerMap.currentLocation(chargerMap.currentDate, chargerMap.currentDate)  //현재 위치의 충전기 조회 갱신
                                    }
                                }
                                else if reservationType == "Scheduled" {
                                    
                                }
                            },
                            label: {
                                Text("확인")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, maxHeight: 35)
                                    .background(Color("#3498DB"))
                                    .cornerRadius(5.0)
                                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                            }
                        )
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(5.0)
                .frame(width: geometryReader.size.width/1.3, height: 200)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 3, y: 3)
            }
            .padding()
            .frame(width: geometryReader.size.width, height: geometryReader.size.height)
            .background(Color.black.opacity(0.5))
        }
        .edgesIgnoringSafeArea(.all)
    }
}
