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
    
    //MARK: - 현재 사용자 포인트 조회
    public func requestCurrentDate(userIdNo: String) -> Future<String, AFError> {

        return apiClient.requestText(route: APIRouter.get(useApi: "base", path: "/point/users/\(userIdNo)", parameters: [:], contentType: "text"))
    }
    
    //MARK: - 사용자 포인트 이력 조회
    public func requestPointHistory(userIdNo: String, parameters: [String:String]) -> Future<PointHistory, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/point/users/\(userIdNo)/history", parameters: parameters, contentType: "json"))
    }
}
