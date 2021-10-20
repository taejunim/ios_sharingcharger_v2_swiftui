//
//  PaymentAlert.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/28.
//

import SwiftUI

//MARK: - 포인트 부족 알림창
struct PointLackAlert: View {
    @ObservedObject var chargerMap: ChargerMapViewModel //충전기 지도 View Model
    @ObservedObject var reservation: ReservationViewModel   //예약 View Model
    @ObservedObject var purchase: PurchaseViewModel //포인트 구매 View Model
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack {
                VStack(spacing: 0) {
                    //알림창 제목
                    HStack{
                        Text("포인트 부족")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HorizontalDividerline()
                    
                    //알림창 내용
                    VStack(spacing: 10) {
                        VStack(spacing: 5) {
                            //잔여 포인트
                            HStack(spacing: 1) {
                                Text("잔여 포인트 : ")
                                    .fontWeight(.bold)
                                
                                Text(reservation.textUserPoint.pointFormatter())    //사용자 포인트
                                    .fontWeight(.bold)
                                
                                Spacer()
                            }
                            
                            //차감 포인트
                            HStack(spacing: 1) {
                                Text("차감 포인트 : ")
                                    .fontWeight(.bold)
                                
                                Text("-" + reservation.textExpectedPoint.pointFormatter())    //충전 시 예상 차감 포인트
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("#C0392B"))
                                
                                Spacer()
                            }
                            
                            //부족 포인트
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
                    
                    //알림창 버튼
                    HStack(spacing: 5) {
                        //취소 버튼 - 알림창 닫기
                        Button(
                            action: {
                                purchase.isShowPointLackAlert = false  //현재 알림창 닫기
                            },
                            label: {
                                Text("취소")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, minHeight: 35)
                                    .background(Color("#C0392B"))
                                    .cornerRadius(5.0)
                                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                            }
                        )
                        
                        //포인트 충전 버튼
                        Button(
                            action: {
                                purchase.parentView = "pointLackAlert"
                                purchase.isShowPaymentInputAlert = true   //포인트 결제 진행 알림창 열기
                            },
                            label: {
                                Text("포인트 충전")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, minHeight: 35)
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
    @ObservedObject var point: PointViewModel
    @ObservedObject var reservation: ReservationViewModel
    
    @State var isShowAlert: Bool = false
    
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
                        //알림창 제목
                        HStack{
                            Text("포인트 충전")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HorizontalDividerline()
                        
                        Spacer()
                        
                        //알림창 내용
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
                                    //purchase.paymentAmount = 0
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
                        
                        //충전 금액 정보
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
                        
                        //알림창 버튼
                        HStack(spacing: 5) {
                            //취소 버튼 - 알림창 닫기
                            Button(
                                action: {
                                    purchase.isShowPaymentInputAlert = false  //알림창 닫기
                                },
                                label: {
                                    Text("취소")
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.white)
                                        .padding(.horizontal)
                                        .frame(maxWidth: .infinity, minHeight: 35)
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
                                },
                                label: {
                                    Text("결제 진행")
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.white)
                                        .padding(.horizontal)
                                        .frame(maxWidth: .infinity, minHeight: 35)
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
                .background(Color.black.opacity(purchase.isShowPointLackAlert ? 0 : 0.5))
                .onAppear {
                    purchase.paymentUserIdNo = UserDefaults.standard.string(forKey: "userIdNo")!
                    purchase.paymentAmount = 0  //결제금액 초기화
                    purchase.stringPaymentAmount = "0"  //직접입력 결제금액 초기화
                }
                .sheet(
                    isPresented: $purchase.isShowPaymentModal,
                    content: {
                        PaymentModal(purchase: purchase, point: point, reservation: reservation)    //결제 Web View 팝업
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

//MARK: - 결제 완료 알림창
struct PaymentCompletionAlert: View {
    @ObservedObject var purchase: PurchaseViewModel
    @ObservedObject var point: PointViewModel
    @ObservedObject var reservation: ReservationViewModel
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack {
                VStack(spacing: 0) {
                    //알림창 제목
                    HStack{
                        Text("결제 완료")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HorizontalDividerline()
                    
                    Spacer()
                    
                    Text("정상적으로 결제가 완료되었습니다.")  //알림창 내용
                    
                    Spacer()
                    
                    //알림창 버튼 - 결제 완료 확인 버튼
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
                            
                            purchase.isShowCompletionAlert = false //결제 완료 알림창 닫기
                        },
                        label: {
                            Text("확인")
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, minHeight: 35)
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

//MARK: - 결제 실패 알림창
struct PaymentFailedAlert: View {
    @ObservedObject var purchase: PurchaseViewModel
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack {
                VStack(spacing: 0) {
                    //알림창 제목
                    HStack{
                        Text("결제 실패")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HorizontalDividerline()
                    
                    Spacer()
                    
                    //알림창 내용
                    Text("결제가 실패하였습니다.다시 시도 바랍니다.\n문제가 지속될 시, 고객 센터에 문의 바랍니다.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                    
                    Spacer()
                    
                    //알림창 버튼 - 결제 실패 확인 버튼
                    Button(
                        action: {
                            purchase.isShowFailedAlert = false
                        },
                        label: {
                            Text("확인")
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, minHeight: 35)
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
