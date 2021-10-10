//
//  AddressModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/10/09.
//

import Foundation

//MARK: - 주소 정보
struct AddressInfo: Codable {
    let meta: Meta
    let documents: [PlaceDocument?]
}

//MARK: - Meta
struct Meta: Codable {
    let totalCount: Int //검색된 문서 수
    let pageableCount: Int  //totalCount 중 노출 가능 문서 수 (최대값: 45)
    let isEnd: Bool //현재 페이지가 마지막 페이지인지 여부
    let sameName: SameName  //질의어 지역 및 키워드 분석 정보
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case pageableCount = "pageable_count"
        case isEnd = "is_end"
        case sameName = "same_name"
    }
}

//MARK: - SameName
struct SameName: Codable {
    let region: [String?]   //질의어에서 인식된 지역의 리스트
    let keyword: String //질의어에서 지역 정보를 제외한 키워드
    let selectedRegion: String? //인식된 지역 리스트 중, 현재 검색에 사용된 지역 정보
    
    enum CodingKeys: String, CodingKey {
        case region
        case keyword
        case selectedRegion = "selected_region"
    }
}

//MARK: - Document
struct PlaceDocument: Codable {
    let placeId: String  //장소 ID
    let placeName: String   //장소명, 업체명
    let categoryName: String    //카테고리 이름
    let categoryGroupCode: String   //중요 카테고리만 그룹핑한 카테고리 그룹 코드
    let categoryGroupName: String   //중요 카테고리만 그룹핑한 카테고리 그룹명
    let phone: String   //전화번호
    let addressName: String //전체 지번 주소
    let roadAddressName: String //전체 도로명 주소
    let x: String   //X 좌표값, 경위도인 경우 longitude (경도)
    let y: String   //Y 좌표값, 경위도인 경우 latitude(위도)
    let placeURL: String    //장소 상세페이지 URL
    let distance: String    //중심좌표까지의 거리
    
    enum CodingKeys: String, CodingKey {
        case placeId = "id"
        case placeName = "place_name"
        case categoryName = "category_name"
        case categoryGroupCode = "category_group_code"
        case categoryGroupName = "category_group_name"
        case phone
        case addressName = "address_name"
        case roadAddressName = "road_address_name"
        case x
        case y
        case placeURL = "place_url"
        case distance
    }
}
