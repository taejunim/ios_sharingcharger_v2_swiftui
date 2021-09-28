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
                                Text("충전 시작일시 :")
                                    .fontWeight(.bold)
                                
                                Text("\(chargerSearch.textStartDay) \(chargerSearch.textStartTime)")
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 2) {
                                Text("충전 종료일시 :")
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
                                        //충전기 재 조회 후, 예약한 충전기로 이동
                                        chargerMap.moveToReservedCharger(chargerId: String(reservation.chargerId), latitude: chargerMap.latitude, longitude: chargerMap.longitude)
                                        
                                        withAnimation {
                                            chargerMap.showChargingView = true  //충전 화면 활성화
                                        }
                                        
                                        self.reservation.showChargingAlert = false  //충전하기 알림창 비활성화
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
                .frame(width: geometryReader.size.width/1.2, height: 250)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 3, y: 3)
            }
            .padding()
            .frame(width: geometryReader.size.width, height: geometryReader.size.height)
            .background(Color.black.opacity(0.5))
        }
        .edgesIgnoringSafeArea(.all)
    }
}

//MARK: - 포인트 부족 알림창
struct PointLackAlert: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var reservation: ReservationViewModel
    @ObservedObject var purchase: PurchaseViewModel
    
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
                            HStack(spacing: 1) {
                                Text("잔여 포인트 : ")
                                    .fontWeight(.bold)
                                
                                Text(reservation.textUserPoint.pointFormatter())    //사용자 포인트
                                    .fontWeight(.bold)
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 1) {
                                Text("차감 포인트 : ")
                                    .fontWeight(.bold)
                                
                                Text("-" + reservation.textExpectedPoint.pointFormatter())    //충전 시 예상 차감 포인트
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("#C0392B"))
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 1) {
                                Text("부족 포인트 : ")
                                    .fontWeight(.bold)
                                
                                Text(reservation.textNeedPoint.pointFormatter())  //잔여 포인트 - 예상 차감 포인트
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("#C0392B"))
                                
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
                                purchase.showPointLackAlert = false  //현재 알림창 닫기
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
                                purchase.showPaymentInputAlert = true   //포인트 결제 진행 알림창 열기
                            },
                            label: {
                                Text("포인트 충전")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, maxHeight: 35)
                                    .background(Color("#3498DB"))
                                    .cornerRadius(5.0)
                                    .shadow(color: Color.gray, radius: 1, x: 1.5, y: 1.5)
                            }
                        )
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(5.0)
                .frame(width: geometryReader.size.width/1.2, height: 250)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 3, y: 3)
            }
            .padding()
            .frame(width: geometryReader.size.width, height: geometryReader.size.height)
            .background(Color.black.opacity(0.5))
        }
        .edgesIgnoringSafeArea(.all)
    }
}

//MARK: - 포인트 결제 금액 입력 알림창
struct PaymentInputAlert:View {
    @ObservedObject var purchase: PurchaseViewModel
    
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        return formatter
    }()
    
    var body: some View {
        GeometryReader { geometryReader in
            ZStack {
                VStack {
                    VStack(spacing: 0) {
                        HStack{
                            Text("포인트 충전")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HorizontalDividerline()
                        
                        Spacer()
                        
                        Text("충전할 금액을 선택하거나, 직접 입력해주세요.")
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 5) {
                            //포인트 선택 버튼
                            ForEach(purchase.paymentArray, id: \.self) { (amount) in
                                let formatAmount = amount.amountFormatter() //금액 포맷팅
                                
                                Button(
                                    action: {
                                        purchase.isDirectlyInput = false    //직접입력 비활성화
                                        purchase.paymentAmount = amount //결제 금액 변경
                                        purchase.stringPaymentAmount = String(amount)   //직접입력 금액 변경
                                    },
                                    label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 5)
                                                .frame(width: 75, height: 30)
                                                .foregroundColor(Color("#5E5E5E"))
                                                .shadow(color: .gray, radius: 1, x: 1.2, y: 1.2)

                                            Text(formatAmount)
                                                .font(.subheadline)
                                                .foregroundColor(Color.white)
                                                .fontWeight(.bold)
                                        }
                                    }
                                )
                            }
                            
                            //직접입력 버튼
                            Button(
                                action: {
                                    purchase.isDirectlyInput = true //직접입력 활성화
                                    purchase.paymentAmount = 0
                                },
                                label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5)
                                            .frame(width: 75, height: 30)
                                            .foregroundColor(Color("#5E5E5E"))    //충전기 상태에 따른 배경 색상
                                            .shadow(color: .gray, radius: 1, x: 1.2, y: 1.2)

                                        Text("직접입력")
                                            .font(.subheadline)
                                            .foregroundColor(Color.white)
                                            .fontWeight(.bold)
                                    }
                                }
                            )
                        }
                        .padding(.top, 10)
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        VStack(spacing: 10) {
                            HStack {
                                Spacer()
                                
                                Text("충전 금액 :")
                                    .fontWeight(.bold)
                                
                                //충전 금액 선택
                                if !purchase.isDirectlyInput {
                                    TextField("", value: $purchase.paymentAmount, formatter: numberFormatter)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 100)
                                        .disabled(true)
                                }
                                //충전 금액 직접입력
                                else {
                                    TextField("", text: $purchase.stringPaymentAmount)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 100)
                                }
                                
                                Spacer()
                            }
                            
                            Text("결제를 진행하시겠습니까?")
                                .multilineTextAlignment(.center)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 5) {
                            //취소 버튼 - 알림창 닫기
                            Button(
                                action: {
                                    purchase.showPaymentInputAlert = false  //알림창 닫기
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
                            
                            //결제 진행 버튼
                            Button(
                                action: {
                                    purchase.viewUtil.dismissKeyboard()  //키보드 닫기
                                    purchase.checkPaymentAmount()   //결제금액 확인 후 결제 진행 실행
                                    
                                    //purchase.showPaymentModal = true
                                },
                                label: {
                                    Text("결제 진행")
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
                    .frame(width: geometryReader.size.width/1.2, height: 260)
                    .shadow(color: Color.black.opacity(0.3), radius: 1, x: 3, y: 3)
                }
                .padding()
                .frame(width: geometryReader.size.width, height: geometryReader.size.height)
                .background(Color.black.opacity(purchase.showPointLackAlert ? 0 : 0.5))
                .onAppear {
                    purchase.paymentUserIdNo = UserDefaults.standard.string(forKey: "userIdNo")!
                    purchase.paymentAmount = 0  //결제금액 초기화
                    purchase.stringPaymentAmount = "0"  //직접입력 결제금액 초기화
                }
                .sheet(
                    isPresented: $purchase.showPaymentModal,
                    content: {
                        PaymentModal(purchase: purchase)    //결제 Web View 팝업
                    }
                )
                .popup(
                    isPresented: $purchase.viewUtil.isShowToast,   //팝업 노출 여부
                    type: .floater(verticalPadding: 80),
                    position: .bottom,
                    animation: .easeInOut(duration: 0.0),   //애니메이션 효과
                    autohideIn: 2,  //팝업 노출 시간
                    closeOnTap: false,
                    closeOnTapOutside: false,
                    view: {
                        purchase.viewUtil.toast()
                    }
                )
                
                //로딩 표시 여부에 따라 표출
                if purchase.viewUtil.isLoading {
                    purchase.viewUtil.loadingView() //로딩 화면
                }
            }
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
                                let reservationType = UserDefaults.standard.string(forKey: "reservationType")   //예약 유형 - 즉시 충전, 예약 충전
                                
                                //즉시 충전인 경우
                                if reservationType == "Instant" {
                                    reservation.cancelInstantCharge() { (cancel) in
                                        reservation.showCancelAlert = false //예약 취소 알림창 비활성화
                                        //reservation.textReservationDate = ""
                                        //reservation.reservedChargerName = ""
                                        chargerMap.currentLocation(chargerMap.currentDate, chargerMap.currentDate)  //현재 위치의 충전기 조회 갱신
                                    }
                                }
                                //예약 충전인 경우
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
                                    .shadow(color: Color.gray, radius: 1, x: 1.5, y: 1.5)
                            }
                        )
                    }
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
