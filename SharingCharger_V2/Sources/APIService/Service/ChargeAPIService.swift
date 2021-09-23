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
    public func requestChargerUseAuth(chargerId: String, parameters: [String:Any]) -> Future<UserReservation, AFError> {
        
        return apiClient.request(route: APIRouter.post(useApi: "base", path: "/recharge/authenticate/charger/\(chargerId)", parameters: parameters))
    }
    
    public func requestChargeStart(chargerId: String, parameters: [String:Any]) -> Future<UserReservation, AFError> {
        
        return apiClient.request(route: APIRouter.post(useApi: "base", path: "/recharge/start/charger/\(chargerId)", parameters: parameters))
    }
    
    public func requestChargeEnd(chargerId: String, parameters: [String:Any]) -> Future<UserReservation, AFError> {
        
        return apiClient.request(route: APIRouter.put(useApi: "base", path: "/recharge/end/charger/\(chargerId)", parameters: parameters))
    }
    
    public func requestChargeAbnormalEnd(chargerId: String, parameters: [String:Any]) -> Future<UserReservation, AFError> {
        
        return apiClient.request(route: APIRouter.put(useApi: "base", path: "/recharge/end/charger/\(chargerId)/unplanned", parameters: parameters))
    }
    
}
