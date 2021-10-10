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

    //----------------------------
    //MARK: - [충전기 API]
    //----------------------------
    
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
    
    
    //----------------------------
    //MARK: - [소유주 충전기 조회 API]
    //----------------------------
    
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
    
    //MARK: - 소유주 충전기별 충전 단가 조회 API 호출
    /// 소유주의 충전기 이용시간 조회
    /// - Parameter chargerId: 충전기 ID 번호
    /// - Returns: Charger Unit Price Model
    public func requestUnitPrice(chargerId: String) -> Future<[ChargerUnitPrice], AFError> {
    
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/chargers/\(chargerId)/prices", parameters: [:], contentType: "json"))
    }
    
    //MARK: - 소유주 충전기별 이용시간 조회 API 호출
    /// 소유주의 충전기 이용시간 조회
    /// - Parameter chargerId: 충전기 ID 번호
    /// - Returns: Charger Usage Time Model
    public func requestUsageTime(chargerId: String) -> Future<ChargerUsageTime, AFError> {
    
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/chargers/\(chargerId)/allowTime", parameters: [:], contentType: "json"))
    }
    
    
    //----------------------------
    //MARK: - [소유주 충전기 할당 API]
    //----------------------------
    
    //MARK: - BLE 번호로 소유주 충전기 조회 API 호출
    /// 소유주에게 할당된 충전기를 BLE 번호로 조회
    /// - Parameter parameters:
    ///   - bleNumber: BLE 번호
    ///   - page: 페이지 번호
    ///   - size: 한 페이지당 개수
    ///   - sort: 정렬
    /// - Returns: Owner Charger Model
    public func requestSearchAssignedCharger(parameters: [String:String]) -> Future<[OwnerCharger], AFError> {
    
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/chargers/ble-number", parameters: parameters, contentType: "json"))
    }
    
    //MARK: - 소유주 충전기 할당 API 호출
    /// BLE 번호 조회 후, 해당 충전기의 할당 요청
    /// - Parameters:
    ///   - chargerId: 충전기 ID 번호
    ///   - parameters:
    ///     - name: 충전기 명
    ///     - chargerType: 충전기 유형
    ///       - BLE: Bluetooth Low Energy
    ///       - MODEM: 모뎀
    ///     - bleNumber: BLE 번호
    ///     - description: 충전기 설명
    ///     - address:  주소
    ///     - detailAddress: 상세주소
    ///     - sharedType: 공유 유형
    ///       - SHARING: 전체 공유
    ///       - PARTIAL_SHARING: 부분 공유
    ///     - cableFlag: 케이블 유무
    ///     - supplyCapacity: 충전 속도 유형
    ///       - QUICK:  급속
    ///       - STANDARD: 완속
    ///       - SLOW: 저속
    ///     - parkingFeeFlg: 주차 요금 여부
    ///     - parkingFeeDescription: 주차 요금 설명
    ///     - ownerType: 소유주 유형
    ///       - Personal: 개인
    ///       - Company: 회사
    ///     - ownerName: 소유주 ID (이메일)
    ///     - providerCompanyId: 충전기 공급 회사 ID
    ///     - currentStatusType: 충전기 상태 (기본값: READY)
    /// - Returns: Owner Charger Model
    public func requestAssignedCharger(chargerId: String, parameters: [String:Any]) -> Future<OwnerCharger, AFError> {
        
        return apiClient.request(route: APIRouter.put(useApi: "base", path: "/chargers/app/\(chargerId)/assign", parameters: parameters))
    }
    
    
    //----------------------------
    //MARK: - [소유주 충전기 수정 API]
    //----------------------------
    
    //MARK: - 소유주 충전기별 정보 수정 API 호출
    /// 충전기의 정보 수정
    /// - Parameters:
    ///   - chargerId: 충전기 ID 번호
    ///   - parameters:
    ///     - name: 충전기 명
    ///     - chargerType: 충전기 유형
    ///       - BLE: Bluetooth Low Energy
    ///       - MODEM: 모뎀
    ///     - bleNumber: BLE 번호
    ///     - description: 충전기 설명
    ///     - address:  주소
    ///     - detailAddress: 상세주소
    ///     - sharedType: 공유 유형
    ///       - SHARING: 전체 공유
    ///       - PARTIAL_SHARING: 부분 공유
    ///     - cableFlag: 케이블 유무
    ///     - supplyCapacity: 충전 속도 유형
    ///       - QUICK:  급속
    ///       - STANDARD: 완속
    ///       - SLOW: 저속
    ///     - parkingFeeFlg: 주차 요금 여부
    ///     - parkingFeeDescription: 주차 요금 설명
    ///     - ownerType: 소유주 유형
    ///       - Personal: 개인
    ///       - Company: 회사
    ///     - ownerName: 소유주 ID (이메일)
    ///     - providerCompanyId: 충전기 공급 회사 ID
    /// - Returns: Owner Charger Model
    public func requestUpdateCharger(chargerId: String, parameters: [String:Any]) -> Future<OwnerCharger, AFError> {
        
        return apiClient.request(route: APIRouter.put(useApi: "base", path: "/chargers/\(chargerId)", parameters: parameters))
    }
    
    //MARK: - 소유주 충전기별 충전 단가 수정 API 호출
    /// 충전기의 충전 단가 수정
    /// - Parameters:
    ///   - chargerId: 충전기 ID 번호
    ///   - parameters:
    ///     - userId: 소유주 ID 번호
    ///     - price: 변경할 충전 단가
    /// - Returns: Charger Unit Price Model
    public func requestUpdateUnitPrice(chargerId: String, parameters: [String:Any]) -> Future<[ChargerUnitPrice], AFError> {
        
        return apiClient.request(route: APIRouter.put(useApi: "base", path: "/chargers/\(chargerId)/prices", parameters: parameters))
    }
    
    //MARK: - 소유주 충전기별 이용시간 수정 API 호출
    /// 충전기의 이용시간 수정
    /// - Parameters:
    ///   - chargerId: 충전기 ID 번호
    ///   - parameters:
    ///     - openTime: 이용 시작시간
    ///     - closeTime: 이용 종료시간
    /// - Returns: Charger Usage Time Model
    public func requestUpdateUsageTime(chargerId: String, parameters: [String:Any]) -> Future<ChargerUsageTime, AFError> {
        
        return apiClient.request(route: APIRouter.put(useApi: "base", path: "/chargers/\(chargerId)/allowTime", parameters: parameters))
    }
}
