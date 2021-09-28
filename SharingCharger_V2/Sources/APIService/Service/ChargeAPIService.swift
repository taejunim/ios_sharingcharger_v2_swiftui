//
//  ChargeAPIService.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/17.
//
//  - API Serivce 분할
//

import Alamofire
import PromisedFuture

// MARK: - [충전 관련 API]
class ChargeAPIService {
    let apiClient = APIClient() //API Client - 공통 API 호출
    
    //MARK: - 충전 시작 전 인증 API 호출
    public func requestChargerUseAuth(chargerId: String, parameters: [String:Any]) -> Future<String, AFError> {
        
        return apiClient.requestText(route: APIRouter.post(useApi: "base", path: "/recharge/authenticate/charger/\(chargerId)", parameters: parameters, contentType: "text"))
    }
    
    //MARK: - 충전 시작 API 호출
    public func requestChargeStart(chargerId: String, parameters: [String:Any]) -> Future<ChargeInfo, AFError> {
        
        return apiClient.request(route: APIRouter.post(useApi: "base", path: "/recharge/start/charger/\(chargerId)", parameters: parameters, contentType: "json"))
    }
    
    //MARK: - 충전 종료 API 호출
    public func requestChargeEnd(chargerId: String, parameters: [String:Any]) -> Future<ChargeInfo, AFError> {
        
        return apiClient.request(route: APIRouter.put(useApi: "base", path: "/recharge/end/charger/\(chargerId)", parameters: parameters))
    }
    
    //MARK: - 충전 비 정상 종료 API 호출
    public func requestChargeAbnormalEnd(chargerId: String, parameters: [String:Any]) -> Future<ChargeInfo, AFError> {
        
        return apiClient.request(route: APIRouter.put(useApi: "base", path: "/recharge/end/charger/\(chargerId)/unplanned", parameters: parameters))
    }
    
    //MARK: - 사용자의 충전기 사용 이력 조회 API 호출
    public func requestChargeHistory(userIdNo: String, parameters: [String:String]) -> Future<[ChargeInfo], AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/recharges/users/\(userIdNo)/history", parameters: parameters, contentType: "json"))
    }
    
    //MARK: - 소유주의 충전기 사용 이력 조회 API 호출
    public func requestOwnerChargeHistory(userIdNo: String, parameters: [String:String]) -> Future<[ChargeInfo], AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/recharges/owner/\(userIdNo)", parameters: parameters, contentType: "json"))
    }
}
