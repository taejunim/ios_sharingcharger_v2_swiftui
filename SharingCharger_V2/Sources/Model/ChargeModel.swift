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
