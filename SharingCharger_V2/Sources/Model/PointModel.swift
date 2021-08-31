//
//  ChargerModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/24.
//

import Foundation

//MARK: - 포인트 이력
struct PointHistory: Codable {
    let content: [chargerIDContent?]
    let pageable: chargerIDPageable
    let totalPages, totalElements: Int
    let last: Bool
    let numberOfElements: Int
    let first: Bool
    let sort: chargerIDSort
    let size, number: Int
    let empty: Bool
}

//MARK: - chargerIDContent
struct chargerIDContent: Codable {
    let id: Int
    let username: String
    let point: Int
    let type, created: String
    let pointTargetID: Int
    let targetName: String
}

//MARK: - chargerIDPageable
struct chargerIDPageable: Codable {
    let sort: chargerIDSort
    let pageNumber, pageSize, offset: Int
    let unpaged, paged: Bool
}

//MARK: - chargerIDSort
struct chargerIDSort: Codable {
    let sorted, unsorted, empty: Bool
}
