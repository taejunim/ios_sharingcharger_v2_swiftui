//
//  ChargeModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/20.
//

import Foundation

//MARK: - 충전 정보
struct ChargeInfo: Codable {
    let id: Int
    let chargerId: Int
    let chargerName: String?
    let username: String?
    let reservationId: Int
    let reservationStartDate: String?
    let reservationEndDate: String?
    let reservationPoint: Int?
    let startRechargeDate: String?
    let endRechargeDate: String?
    let rechargePoint: Int?
    let refundPoint: Int?
    let ownerPoint: Int?
    let created: String?
    let updated: String?
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
    let id: Int
    let chargerId: Int
    let chargerName: String
    let username: String
    let reservationStartDate: String
    let reservationEndDate: String
    let startRechargeDate: String?
    let endRechargeDate: String?
    let reservationPoint: Int?
    let rechargePoint: Int?
    let refundPoint: Int?
    let created: String
    let updated: String
}
