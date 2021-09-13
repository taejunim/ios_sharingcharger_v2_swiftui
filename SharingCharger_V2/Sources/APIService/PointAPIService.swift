//
//  PointAPIService.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/31.
//

import Alamofire
import PromisedFuture

class PointAPIService {
    let apiClient = APIClient() //API Client - 공통 API 호출
    
    //MARK: - 현재 사용자 포인트 조회 API 호출
    /// 로그인한 사용자의 현재 잔여 포인트 조회
    /// - Parameter userIdNo: 사용자 ID 번호
    /// - Returns: String
    public func requestCurrentDate(userIdNo: String) -> Future<String, AFError> {

        return apiClient.requestText(route: APIRouter.get(useApi: "base", path: "/point/users/\(userIdNo)", parameters: [:], contentType: "text"))
    }
    
    //MARK: - 사용자 포인트 이력 조회 API 호출
    /// 로그인한 사용자의 포인트 이력(구매, 사용 환불 등) 조회
    /// - Parameters:
    ///   - userIdNo: 사용자 ID 번호
    ///   - parameters:
    ///     - pointUsedType: 포인트 구분
    ///     - startDate: 조회 시작일자
    ///     - endDate: 조회 종료일자
    ///     - page: 페이지 번호
    ///     - size: 페이지 사이즈
    ///     - sort: 정렬 방식
    /// - Returns: Point History Model
    public func requestPointHistory(userIdNo: String, parameters: [String:String]) -> Future<PointHistory, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/point/users/\(userIdNo)/history", parameters: parameters, contentType: "json"))
    }
}
