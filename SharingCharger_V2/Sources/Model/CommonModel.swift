//
//  CommonModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/10/10.
//

import Foundation

// MARK: - 페이징 정보
struct Pageable: Codable {
    let sort: Sort
    let pageNumber: Int?
    let pageSize: Int?
    let offset: Int?
    let unpaged: Bool?
    let paged: Bool?
}

// MARK: - 정렬 정보
struct Sort: Codable {
    let sorted: Bool?
    let unsorted: Bool?
    let empty: Bool?
}
