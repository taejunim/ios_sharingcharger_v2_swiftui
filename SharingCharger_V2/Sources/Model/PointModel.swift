//
//  ChargerModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/24.
//

import Foundation

//MARK: - 포인트 이력 정보
struct PointHistory: Codable {
    let content: [PointHistoryContent?]
    let pageable: PointHistoryPageable
    let totalPages: Int
    let totalElements: Int
    let numberOfElements: Int
    let first: Bool
    let last: Bool
    let sort: PointHistorySort
    let size: Int
    let number: Int
    let empty: Bool
}

//MARK: - 포인트 이력 내용 정보
struct PointHistoryContent: Codable {
    let id: Int?
    let username: String?
    let point: Int?
    let type: String?
    let pointTargetId: Int?
    let targetName: String?
    let created: String?
}

//MARK: - 포인트 이력 페이징 정보
struct PointHistoryPageable: Codable {
    let sort: PointHistorySort
    let pageNumber: Int
    let pageSize: Int
    let offset: Int
    let unpaged: Bool
    let paged: Bool
}

//MARK: - 포인트 이력 정렬 정보
struct PointHistorySort: Codable {
    let sorted: Bool
    let unsorted: Bool
    let empty: Bool
}

//MARK: - 월별 수익 포인트 정보
struct ProfitPoint: Codable {
    let day: String
    let point: Int
}

