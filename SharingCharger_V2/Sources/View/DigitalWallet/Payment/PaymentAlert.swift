//
//  PaymentAlert.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/28.
//

import SwiftUI

//MARK: - 결제 완료 알림창
struct PaymentCompletionAlert: View {
    @ObservedObject var purchase: PurchaseViewModel
    @ObservedObject var point: PointViewModel
    @ObservedObject var reservation: ReservationViewModel
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack {
                VStack(spacing: 0) {
                    HStack{
                        Text("결제 완료")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HorizontalDividerline()
                    
                    Spacer()
                    
                    Text("정상적으로 결제가 완료되었습니다.")
                    
                    Spacer()
                    
                    Button(
                        action: {
                            /// 결제 성공 시 호출한 상위 화면에 따라 화면 업데이트
                            /// - parentView: 결제 팝업창을 호출한 상위 화면
                            ///   - pointLackAlert: 포인트 부족 알림창
                            ///   - reservationView:  예약 진행 화면
                            ///   - sideMenuView: 사이드 메뉴 화면
                            ///   - digitalWalletView: 전자지갑 화면
                            //상위 화면 - 예약 화면
                            if purchase.parentView == "reservationView" {
                                reservation.checkChargingPoint(
                                    chargerId: reservation.reservedChargerId,
                                    reservation.reservationStartDate!, reservation.reservationEndDate!
                                ) { (isReservable) in
                                    reservation.isReservable = isReservable
                                }
                            }
                            //상위 화면 - 포인트 부족 알림창
                            else if purchase.parentView == "pointLackAlert" {
                                purchase.isShowPointLackAlert = false
                            }
                            //상위 화면 - 사이드 메뉴, 전자지갑 화면
                            else if purchase.parentView == "sideMenuView" || purchase.parentView == "digitalWalletView" {
                                point.getCurrentPoint()
                            }
                            
                            purchase.showCompletionAlert = false //결제 완료 알림창 열기
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
                    .padding(.horizontal, 10)
                }
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(5.0)
                .frame(width: geometryReader.size.width/1.2, height: 200)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 3, y: 3)
            }
            .padding()
            .frame(width: geometryReader.size.width, height: geometryReader.size.height)
            .background(Color.black.opacity(0.5))
        }
        .edgesIgnoringSafeArea(.all)
    }
}
