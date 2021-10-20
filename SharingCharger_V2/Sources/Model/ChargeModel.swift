//
//  ChargeModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/20.
//

import Foundation

//MARK: - 충전 정보
struct ChargeInfo: Codable {
    let id: Int //충전 정보 ID
    let chargerId: Int  //충전기 ID
    let chargerName: String?    //충전기 명
    let username: String?   //사용자 ID
    let reservationId: Int  //예약 ID
    let reservationStartDate: String?   //예약 시작일시
    let reservationEndDate: String? //예약 종료일시
    let reservationPoint: Int?  //예약 차감 포인트
    let startRechargeDate: String?  //충전 시작일시
    let endRechargeDate: String?    //충전 종료일시
    let rechargePoint: Int? //충전 차감 포인트
    let refundPoint: Int?   //환불 포인트
    let ownerPoint: Int?    //소유주 포인트
    let created: String?    //등록일시
    let updated: String?    //수정일시
}

//MARK: - 충전 이력 정보
struct ChargingHistory: Codable {
    let content: [ChargingHistoryContent?]
    let pageable: Pageable
    let totalPages: Int
    let totalElements: Int
    let last: Bool
    let numberOfElements: Int
    let first: Bool
    let sort: Sort
    let size: Int
    let number: Int
    let empty: Bool
}

//MARK: - 충전 이력 정보 내용
struct ChargingHistoryContent: Codable {
    let id: Int //충전 이력 ID
    let chargerId: Int  //충전기 ID
    let chargerName: String //충전기 명
    let username: String    //사용자 ID
    let reservationStartDate: String    //예약 시작일시
    let reservationEndDate: String  //예약 종료일시
    let startRechargeDate: String?  //충전 시작일시
    let endRechargeDate: String?    //충전 종료일시
    let ownerPoint: Int?    //소유주 포인트
    let reservationPoint: Int?  //예약 차감 포인트
    let rechargePoint: Int? //충전 차감 포인트
    let refundPoint: Int?   //환불 포인트
    let created: String //등록일시
    let updated: String //수정일시
}
