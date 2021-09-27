//
//  PaymentModal.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/23.
//

import SwiftUI

struct PaymentModal: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var purchase: PurchaseViewModel
    
    var body: some View {
        VStack {
            PaymentWebView(
                loadUrl: "https://devevzone.evzcharge.com/api/user/jeju_pay?product_amt=\(purchase.paymentAmount)&sp_user_define1=\(purchase.paymentUserIdNo)",
                //loadUrl: "http://172.30.1.29:8080",
                message: { (type, code, content) in
                    
                    //메시지 유형 - 알림
                    if type == "alert" {
    
                        //결제 창에서 취소 클릭 시, 현재 창 닫기
                        if code == "W002" {
                            withAnimation {
                                self.presentationMode.wrappedValue.dismiss()    //현재 화면 닫기
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
                        }
                        //결제 실패
                        else if code == "fail" {
                            print("Payment Result: \(code) - \(content)")
                        }
                    }
                }
            )
        }
    }
}

struct PaymentModal_Previews: PreviewProvider {
    static var previews: some View {
        PaymentModal(purchase: PurchaseViewModel())
    }
}
