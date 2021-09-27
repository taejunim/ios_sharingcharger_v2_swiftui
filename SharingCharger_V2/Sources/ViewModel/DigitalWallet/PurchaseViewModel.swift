//
//  PurchaseViewModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/17.
//

import Foundation
import WebKit

class PurchaseViewModel: ObservableObject {
    private let purchaseAPI = PurchaseAPIService()  //포인트 구매 API Service
    private let pointAPI = PointAPIService()  //포인트 API Service
    
    @Published var viewUtil = ViewUtil()
    
    @Published var showPointLackAlert: Bool = false //포인트 부족 알림창 활성 여부
    @Published var showPaymentInputAlert: Bool = false  //결제 입력 알림창 활성 여부
    
    @Published var paymentArray: [Int] = [10000, 30000, 50000]  //결제 금액 선택 목록
    @Published var isDirectlyInput: Bool = false    //직접입력 여부
    @Published var paymentAmount: Int = 0   //선택 결제 금액
    
    //직접입력 결제 금액
    @Published var stringPaymentAmount: String = "0" {
        didSet {
            changePaymentAmount()   //직접입력 결제 금액 변경
        }
    }
    
    @Published var isCheckAmount: Bool = false  //결제 금액 확인 여부
    @Published var isPayment: Bool = false  //결제 성공 여부
    
    @Published var paymentWebView = WKWebView(frame: .zero)
    @Published var showPaymentModal: Bool = false
    @Published var paymentUserIdNo: String = ""

    //MARK: - 직접 입력한 결제 금액 변경
    func changePaymentAmount() {
        //직접입력 금액이 빈값이 아니고 첫번째 숫자가 0이 아닐때만 결제 금액 변경
        if stringPaymentAmount != "" {
            let firstNumber = stringPaymentAmount[stringPaymentAmount.startIndex]   //첫번째 입력 숫자
            
            if firstNumber != "0" {
                paymentAmount = Int(stringPaymentAmount) ?? 0
            }
            else {
                paymentAmount = 0
            }
        }
        else {
            paymentAmount = 0
        }
    }
    
    func payment() {
        
    }
    
    func checkPaymentAmount() {
        
        if paymentAmount == 0 {
            isCheckAmount = false   //결제금액 확인 결과
            
            //결제 금액을 선택하지 않은 경우 메시지 출력
            if !isDirectlyInput {
                viewUtil.showToast(isShow: true, message: "충전 금액을 선택하지 않았습니다.\n충전 금액을 선택해주세요.")
            }
            //결제 금액을 입력하지 않았거나 잘못된 금액을 입력한 경우 메시지 출력
            else {
                viewUtil.showToast(isShow: true, message: "충전 금액을 입력하지 않았거나,\n잘못된 금액을 입력하였습니다.\n입력한 충전 금액을 확인해주세요.")
            }
        }
        //결제 금액이 0이 아닌 경우 결제 단계 실행
        else {
            isCheckAmount = true    //결제금액 확인 결과
            showPaymentModal = true //결제 Web View 팝업창 호출
            
            //포인트 구매 API 실행
//            purchacePoint() { (result) in
//                self.viewUtil.isLoading = false //로딩 종료
//                
//                if result == "success" {
//                    self.isPayment = true
//                    self.paymentAmount = 0
//                    self.stringPaymentAmount = "0"
//                    self.viewUtil.showToast(isShow: true, message: "충전이 완료되었습니다.")
//                }
//                else {
//                    self.isPayment = false
//                    self.viewUtil.showToast(isShow: true, message: "server.error".message())
//                }
//            }
        }
    }
    
    //MARK: - 포인트 구매 API 호출
    /// - Parameter completion: 포인트 구매 결과(String)
    func purchacePoint(completion: @escaping (String) -> Void) {
        
        let userIdNo = UserDefaults.standard.string(forKey: "userIdNo")!
        
        let parameters: [String:Any] = [
            "approvalNumber": Int("0")!,    //결제 승인번호
            "approvalDate": "yyyy-MM-dd'T'HH:mm:ss.sss'Z'".dateFormatter(formatDate: Date()),   //결제 승인일시
            "paymentSuccess": "SUCCESS",    //결제 성공여부 - SUCCESS, FAILED
            "paidAmount": paymentAmount //결제 금액
        ]
        
        let request = purchaseAPI.requestPurchase(userIdNo: userIdNo, parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (puchase) in
                completion("success")
            },
            //API 호출 실패
            onFailure: { (error) in
                print(error)
                completion("fail")
            }
        )
    }
}