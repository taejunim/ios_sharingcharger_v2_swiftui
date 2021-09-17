//
//  ReservationAPIService.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/17.
//
//  - API Serivce 분할
//

import Alamofire
import PromisedFuture

// MARK: - [충전기 예약 관련 API]
class ReservationAPIService {
    let apiClient = APIClient() //API Client - 공통 API 호출

    //MARK: - 현재 일시 API 호출
    /// 현재 서버  기준 일시
    /// - Returns: 현재 일시 ("yyyy-MM-dd'T'HH:mm:ss" - String 형식)
    public func requestCurrentDate() -> Future<String, AFError> {

        return apiClient.requestText(route: APIRouter.get(useApi: "base", path: "/reservation/current/time", parameters: [:], contentType: "text"))
    }
    
    // MARK: - 충전기별 예약 현황 API 호출
    /// 검색조건에 따른 해당 충전기의 예약 현황 조회 APi
    /// - Parameters:
    ///   - chargerId: 충전기 ID 번호
    ///   - parameters:
    ///     - page: 페이지 번호
    ///     - size: 조회 개수
    ///     - sort: 정렬 방식(ASC, DESC)
    /// - Returns: Charger Reservation Model
    public func requestChargerReservation(chargerId: String, parameters: [String:String]) -> Future<ChargerReservation, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/reservations/chargers/\(chargerId)", parameters: parameters, contentType: "json"))
    }
    
    // MARK: - 사용자의 현재 충전기 예약 정보 API 호출
    /// 사용자의 현재 충전기 예약 정보 조회 API
    /// - Parameter userIdNo: 사용자 ID 번호
    /// - Returns: User Reservation Model
    public func requesUserReservation(userIdNo: String) -> Future<UserReservation, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/reservation/user/\(userIdNo)/currently", parameters: [:], contentType: "json"))
    }
    
    //MARK: - 충전기 예약 API 호출
    /// 사용자가 선택한 충전기의 예약 진행 API
    /// - Parameter parameters:
    ///   - userId: 사용자 ID
    ///   - chargerId: 충전기 ID
    ///   - reservationType: 예약 유형
    ///   - expectPoint: 예상 포인트
    ///   - startDate: 충전 시작일시
    ///   - endDate: 충전 종료일시
    ///   - cancelDate: 충전 예약 취소일시
    /// - Returns: User Reservation Model
    public func requestReservation(parameters: [String:Any]) -> Future<UserReservation, AFError> {
        
        return apiClient.request(route: APIRouter.post(useApi: "base", path: "/reservation", parameters: parameters))
    }
    
    //MARK: - 충전기 예약 취소 API 호출
    /// 사용자가 예약한 충전기 예약 건의 취소 진행 API
    /// - Parameter reservationId: 충전기 예약 ID (예약 번호)
    /// - Returns: User Reservation Model
    public func requestCancelReservation(reservationId: String) -> Future<UserReservation, AFError> {
        
        return apiClient.request(route: APIRouter.put(useApi: "base", path: "/reservations/\(reservationId)/cancel", parameters: [:]))
    }
    
    //MARK: - 충전기 즉시 충전 예약 취소 API 호출
    /// 사용자가 즉시 충전하기 위해 예약된 예약 건의 취소 진행 API
    /// - Parameter reservationId: 충전기 예약 ID (예약 번호)
    /// - Returns: User Reservation Model
    public func requestCancelInstantCharge(reservationId: String) -> Future<UserReservation, AFError> {
        
        return apiClient.request(route: APIRouter.put(useApi: "base", path: "/reservations/\(reservationId)/cancel/immediateCharging", parameters: [:]))
    }
}
