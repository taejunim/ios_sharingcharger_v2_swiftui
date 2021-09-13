//
//  ChargerAPIService.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/19.
//

import Alamofire
import PromisedFuture

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
    /// - Parameter chargerId: 충전기 ID
    /// - Returns: Charger Model
    public func requestCharger(chargerId: String) -> Future<Charger, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/app/chargers/\(chargerId)", parameters: [:], contentType: "json"))
    }
    
    //MARK: - 현재 일시 API 호출
    /// 현재 서버  기준 일시
    /// - Returns: "yyyy-MM-dd'T'HH:mm:ss" - String 형식
    public func requestCurrentDate() -> Future<String, AFError> {

        return apiClient.requestText(route: APIRouter.get(useApi: "base", path: "/reservation/current/time", parameters: [:], contentType: "text"))
    }
    
    //MARK: - 충전기별 예약 현황 API 호출
    /// 검색조건에 따른 해당 충전기의 예약 현황 조회 APi
    /// - Parameters:
    ///   - chargerId: 충전기 ID
    ///   - parameters:
    ///     - page: 페이지 번호
    ///     - size: 조회 개수
    ///     - sort: 정렬 방식(ASC, DESC)
    /// - Returns: Charger Reservation Model
    public func requestChargerReservation(chargerId: String, parameters: [String:String]) -> Future<ChargerReservation, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/reservations/chargers/\(chargerId)", parameters: parameters, contentType: "json"))
    }
}
