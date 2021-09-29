//
//  ChargerAPIService.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/19.
//

import Alamofire
import PromisedFuture

// MARK: - [충전기 정보 조회 관련 API]
class ChargerAPIService {
    let apiClient = APIClient() //API Client - 공통 API 호출

    //MARK: - 충전기 목록 조회 API 호출
    /// 검색조건에 따른 충전 및 예약 가능한 충전기 목록 조회
    /// - Parameter parameters:
    ///   - gpxX: X 좌표(경도)
    ///   - gpxY: Y 좌표(위도)
    ///   - startDate: 조회 시작 일자
    ///   - endDate: 조회 종료 일자
    ///   - distance: 반경 범위
    /// - Returns: Charger Model Array
    public func requestChargerList(parameters: [String:String]) -> Future<[Charger], AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/app/chargers", parameters: parameters, contentType: "json"))
    }
    
    //MARK: - 충전기별 상세 조회 API 호출
    /// 충전기 ID를 통한 충전기 개별 조회
    /// - Parameter chargerId: 충전기 ID 번호
    /// - Returns: Charger Model
    public func requestCharger(chargerId: String) -> Future<Charger, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/app/chargers/\(chargerId)", parameters: [:], contentType: "json"))
    }
    
    //MARK: - 소유자 충전기 요약 정보 조회 API 호출
    /// 소유자가 보유한 충전기의 요약 정보 조회
    /// - Parameter ownerIdNo: 소유자 ID 번호(= 사용자 ID 번호)
    /// - Returns: Owner Charger Summary Model
    public func requestOwnerSummaryInfo(ownerIdNo: String) -> Future<OwnerChargerSummary, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/dashboard/personal/\(ownerIdNo)/card", parameters: [:], contentType: "json"))
    }
    
    //MARK: - 소유자 충전기 목록 조회 API 호출
    /// 소유자가 등록한 충전기 목록 조회
    /// - Parameters:
    ///   - ownerIdNo: 소유자 ID 번호(= 사용자 ID 번호)
    ///   - ownerType: 소유자 유형
    /// - Returns: Owner Charger Model Array
    public func requestOwnerChargerList(ownerIdNo: String, ownerType: String) -> Future<[OwnerCharger], AFError> {
    
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/chargers/owner/dashboard/\(ownerIdNo)/\(ownerType)", parameters: [:], contentType: "json"))
    }
    
    //MARK: - 소유자 충전기별 상세 조회 API 호출
    /// 소유자의 충전기 개별 조회
    /// - Parameter chargerId: 충전기 ID 번호
    /// - Returns: Owner Charger Model
    public func requestOwnerCharger(chargerId: String) -> Future<OwnerCharger, AFError> {
    
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/chargers/\(chargerId)", parameters: [:], contentType: "json"))
    }
}
