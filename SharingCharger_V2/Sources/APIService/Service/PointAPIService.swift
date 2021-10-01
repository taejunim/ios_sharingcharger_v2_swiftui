//
//  PointAPIService.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/31.
//

import Alamofire
import PromisedFuture

// MARK: - [포인트 관련 API]
class PointAPIService {
    let apiClient = APIClient() //API Client - 공통 API 호출
    
    //MARK: - [포인트 조회 관련 API]
    //MARK: - 현재 사용자 포인트 조회 API 호출
    /// 로그인한 사용자의 현재 잔여 포인트 조회
    /// - Parameter userIdNo: 사용자 ID 번호
    /// - Returns: 사용자 잔여 포인트 (String)
    public func requestCurrentDate(userIdNo: String) -> Future<String, AFError> {

        return apiClient.requestText(route: APIRouter.get(useApi: "base", path: "/point/users/\(userIdNo)", parameters: [:], contentType: "text"))
    }
    
    //MARK: - 사용자 포인트 이력 조회 API 호출
    /// 로그인한 사용자의 포인트 이력(구매, 사용, 환불 등) 조회
    /// - Parameters:
    ///   - userIdNo: 사용자 ID 번호
    ///   - parameters:
    ///     - pointUsedType: 포인트 구분
    ///       - PURCHASE: 구매
    ///       - USED: 사용
    ///       - REFUND: 부분 환불
    ///     - startDate: 조회 시작일자
    ///     - endDate: 조회 종료일자
    ///     - page: 페이지 번호
    ///     - size: 페이지 사이즈
    ///     - sort: 정렬 방식
    ///       - ASC
    ///       - DESC
    /// - Returns: Point History Model
    public func requestPointHistory(userIdNo: String, parameters: [String:String]) -> Future<PointHistory, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/point/users/\(userIdNo)/history", parameters: parameters, contentType: "json"))
    }
    
    //MARK: - 사용자 전자지갑 이력 조회 API 호출
    /// 사용자의 포인트 구매 이력 조회 - 구매, 구매취소, 포인트 환전, 포인트 지급, 포인트 회수
    /// - Parameters:
    ///   - userIdNo: 사용자 ID 번호
    ///   - parameters:
    ///     - pointUsedType: 포인트 구분
    ///       - PURCHASE: 구매
    ///       - PURCHASE_CANCEL: 구매 취소
    ///       - EXCHANGE: 포인트 환전
    ///       - GIVE: 포인트 지급
    ///       - WITHDRAW: 포인트 회수
    ///     - startDate: 조회 시작일자
    ///     - endDate: 조회 종료일자
    ///     - page: 페이지 번호
    ///     - size: 페이지 사이즈
    ///     - sort: 정렬 방식
    ///       - ASC
    ///       - DESC
    /// - Returns: Point History Model
    public func requestWalletPointHistory(userIdNo: String, parameters: [String:String]) -> Future<PointHistory, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/point/users/electronicWallet/\(userIdNo)/history", parameters: parameters, contentType: "json"))
    }

    //MARK: - 예상 차감 포인트 조회
    /// 해당 충전기의 충전 시 차감되는 예상 포인트 조회
    /// - Parameters:
    ///   - chargerId: 충전기 ID
    ///   - parameters:
    ///     - startDate: 충전 시작일시
    ///     - endDate: 충전 종료일시
    /// - Returns: 예상 차감 포인트 (String)
    public func requestExpectedPoint(chargerId: String, parameters: [String:String]) -> Future<String, AFError> {
        
        return apiClient.requestText(route: APIRouter.get(useApi: "base", path: "/point/chargers/\(chargerId)/calculate", parameters: parameters, contentType: "text"))
    }
    
    //MARK: - 월별 수익 포인트 조회(소유주)
    /// <#Description#>
    /// - Parameters:
    ///   - userIdNo: <#userIdNo description#>
    ///   - parameters: <#parameters description#>
    /// - Returns: <#description#>
    public func requestProfitPoints(userIdNo: String, parameters: [String:String]) -> Future<PointHistory, AFError> {
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/dashboard/personal/\(userIdNo)/stat/point", parameters: parameters, contentType: "json"))
    }
}
