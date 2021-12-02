//
//  ChargerModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/24.
//

import Foundation

//MARK: - 전자지갑 포인트 정보
struct WalletPoint: Codable {
    let point: Int  //총합 포인트
    let cashPoint: Int  //구매 포인트(결재 포인트)
    let systemPoint: Int    //시스템 포인트(지급 포인트)
}

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
    let id: Int?    //포인트 이력 ID
    let username: String?   //사용자 ID
    let point: Int? //포인트
    let type: String?   //포인트 이력 유형
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

