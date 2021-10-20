//
//  PaymentModal.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/23.
//

import SwiftUI

//MARK: - 결제 팝업 화면
struct PaymentModal: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var purchase: PurchaseViewModel
    @ObservedObject var point: PointViewModel
    @ObservedObject var reservation: ReservationViewModel
    
    var body: some View {
        ZStack {
            PaymentWebView(
                loadUrl: "https://devevzone.evzcharge.com/api/user/jeju_pay?product_amt=\(purchase.paymentAmount)&sp_user_define1=\(purchase.paymentUserIdNo)",
                message: { (type, code, content) in
                    //메시지 유형 - 알림
                    if type == "alert" {
    
                        //결제 창에서 취소 클릭 시, 현재 창 닫기
                        if code == "W002" || code == "W324" || code == "W344" {
                            purchase.isPayment = false   //결제 성공 여부
                            
                            withAnimation {
                               // self.presentationMode.wrappedValue.dismiss()    //현재 화면 닫기
                                purchase.isShowPaymentInputAlert = false //포인트 충전 알림창 닫기
                            }
                        }
                        //코드가 없는 메시지
                        else if code == "notCode" {
                            print("Not Code Message: \(content)")
                        }
                    }
                    //메시지 유형 - 결제 결과
                    else if type == "result" {
                        //결제 성공
                        if code == "success" {
                            print("Payment Result: \(code) - \(content)")
                            
                            purchase.isPayment = true   //결제 성공 여부
                            purchase.isShowPaymentInputAlert = false //포인트 충전 알림창 닫기
                            
                            withAnimation {
                                purchase.isShowCompletionAlert = true
                            }
                        }
                        //결제 실패
                        else if code == "fail" {
                            print("Payment Result: \(code) - \(content)")
                            
                            purchase.isPayment = false   //결제 성공 여부
                            
                            withAnimation {
                                self.presentationMode.wrappedValue.dismiss()    //현재 화면 닫기
                                purchase.isShowFailedAlert = true
                            }
                        }
                    }
                }
            )
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct PaymentModal_Previews: PreviewProvider {
    static var previews: some View {
        PaymentModal(purchase: PurchaseViewModel(), point: PointViewModel(), reservation: ReservationViewModel())
    }
}
