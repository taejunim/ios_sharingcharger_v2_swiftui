//
//  ChargerModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/24.
//

import Foundation

//MARK: - 포인트 이력
struct PointHistory: Codable {
    let content: [PointContent?]
    let pageable: PointPageable
    let totalPages, totalElements: Int
    let last: Bool
    let numberOfElements: Int
    let first: Bool
    let sort: PointSort
    let size, number: Int
    let empty: Bool
}

//MARK: - Content
struct PointContent: Codable {
    let id: Int
    let username: String
    let point: Int
    let type, created: String
    let pointTargetId: Int
    let targetName: String
}

//MARK: - Pageable
struct PointPageable: Codable {
    let sort: PointSort
    let pageNumber, pageSize, offset: Int
    let unpaged, paged: Bool
}

//MARK: - Sort
struct PointSort: Codable {
    let sorted, unsorted, empty: Bool
}
