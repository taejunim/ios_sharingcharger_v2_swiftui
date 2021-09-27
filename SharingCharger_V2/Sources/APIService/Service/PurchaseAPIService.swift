//
//  PurchaseAPIService.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/17.
//
//  - API Serivce 분할
//

import Alamofire
import PromisedFuture

// MARK: - [포인트 구매 관련 API]
class PurchaseAPIService {
    let apiClient = APIClient() //API Client - 공통 API 호출
    
    //MARK: - 포인트 구매 API 호출
    /// 사용자가 결제 후 결제 정보를 통해 결제한 금액 만큼 포인트로 전환
    /// - Parameters:
    ///   - userIdNo: 사용자 ID 번호
    ///   - parameters:
    ///     - approvalNumber: 결제 승인번호
    ///     - approvalDate: 결제 승인일시
    ///     - paymentSuccess: 결제 성공여부 - SUCCESS, FAILED
    ///     - paidAmount: 결제 금액
    /// - Returns: Purchase Model
    public func requestPurchase(userIdNo: String, parameters: [String:Any]) -> Future<Purchase, AFError> {
        
        return apiClient.request(route: APIRouter.post(useApi: "base", path: "/purchase/user/\(userIdNo)", parameters: parameters, contentType: "json"))
    }
}
