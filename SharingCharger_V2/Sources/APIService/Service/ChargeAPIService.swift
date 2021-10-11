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
    /// 충전 시작 전, 충전기 사용 가능 여부 조회
    /// - Parameters:
    ///   - chargerId: 충전기 ID
    ///   - parameters:
    ///     - userId:   사용자 ID 번호
    ///     - reservationId: 예약 ID 번호
    ///     - rechargeStartDate: 충전 시작일시
    /// - Returns: 인증 여부(String)
    public func requestChargerUseAuth(chargerId: String, parameters: [String:Any]) -> Future<String, AFError> {
        
        return apiClient.requestText(route: APIRouter.post(useApi: "base", path: "/recharge/authenticate/charger/\(chargerId)", parameters: parameters, contentType: "json"))
    }
    
    //MARK: - 충전 시작 API 호출
    /// 충전 시작 요청 후, 충전 시작 정보 호출
    /// - Parameters:
    ///   - chargerId: 충전기 ID
    ///   - parameters:
    ///     - userId:   사용자 ID 번호
    ///     - reservationId: 예약 ID 번호
    ///     - rechargeStartDate: 충전 시작일시
    /// - Returns: Charge Info Model
    public func requestChargeStart(chargerId: String, parameters: [String:Any]) -> Future<ChargeInfo, AFError> {
        
        return apiClient.request(route: APIRouter.post(useApi: "base", path: "/recharge/start/charger/\(chargerId)", parameters: parameters, contentType: "json"))
    }
    
    //MARK: - 충전 종료 API 호출
    /// 현재 충전 건의  충전 종료 요청 후, 충전 종료 정보 호출
    /// - Parameters:
    ///   - chargerId: 충전기 ID
    ///   - parameters:
    ///     - rechargeId: 충전 정보 ID (충전기 BLE 태그 정보 ID)
    ///     - rechargeMinute: 충전기 사용 시간
    ///     - rechargeKwh: 충전 kWh
    /// - Returns: Charge Info Model
    public func requestChargeEnd(chargerId: String, parameters: [String:Any]) -> Future<ChargeInfo, AFError> {
        
        return apiClient.request(route: APIRouter.put(useApi: "base", path: "/recharge/end/charger/\(chargerId)", parameters: parameters))
    }
    
    //MARK: - 충전 비 정상 종료 API 호출
    /// 충전기 사용을 위해 기존에 정상 종료되지 않은 충전 정보를 비정상  종료 처리
    /// - Parameters:
    ///   - chargerId: 충전기 ID
    ///   - parameters:
    ///     - rechargeId: 충전 정보 ID (충전기 BLE 태그 정보 ID)
    ///     - rechargeMinute: 충전기 사용 시간
    ///     - rechargeKwh: 충전 kWh
    /// - Returns: Charge Info Model
    public func requestChargeAbnormalEnd(chargerId: String, parameters: [String:Any]) -> Future<ChargeInfo, AFError> {
        
        return apiClient.request(route: APIRouter.put(useApi: "base", path: "/recharge/end/charger/\(chargerId)/unplanned", parameters: parameters))
    }
    
    //MARK: - 사용자의 충전기 사용 이력 조회 API 호출
    /// 사용자가 사용한 충전기의 사용 이력 조회
    /// - Parameters:
    ///   - userIdNo: 사용자 ID 번호
    ///   - parameters:
    ///     - startDate: 조회 시작일시
    ///     - endDate:  조회 종료일시
    ///     - page: 페이지 번호
    ///     - size: 페이즈 사이즈
    ///     - sort: 정렬
    /// - Returns: Charge Info Model
    public func requestChargeHistory(userIdNo: String, parameters: [String:String]) -> Future<ChargingHistory, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/recharges/users/\(userIdNo)/history", parameters: parameters, contentType: "json"))
    }
    
    //MARK: - 소유주의 충전기 사용 이력 조회 API 호출
    /// 소유주가 사용한 충전기의 사용 이력 조회
    /// - Parameters:
    ///   - userIdNo: 소유주 ID 번호
    ///   - parameters: Charge Info Model
    /// - Returns:
    public func requestOwnerChargeHistory(userIdNo: String, parameters: [String:String]) -> Future<ChargingHistory, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/recharges/owner/\(userIdNo)", parameters: parameters, contentType: "json"))
    }
}
