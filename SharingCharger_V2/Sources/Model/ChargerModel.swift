//
//  ChargerModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/24.
//

import Foundation

//MARK: - 충전기 정보
struct Charger: Codable {
    let id: Int?    //충전기 ID
    let name: String?   //충전기 명
    let address: String?    //충전기 주소
    let detailAddress: String?  //충전기 상세주소
    let gpsX: Double?   //X좌표(경도)
    let gpsY: Double?   //Y좌표(위도)
    let description: String?    //설명
    
    let sharedType: String? //공유 유형
    let bleNumber: String?  //BLE 번호
    let currentStatusType: String?  //현재 충전기 상태
    let cableFlag: Bool?    //케이블 유무
    let rangeOfFee: String? //충전 단가
    
    let parkingFeeFlag: Bool?   //주차 요금 유무
    let parkingFeeDescription: String?  //주차 요금 설명
    
    let ownerType: String?  //소유자 유형
    let ownerName: String?  //소유자 명
    let providerCompanyId: Int? //충전기 업체 ID
    
    let searchDateFlag: Bool?
    let created: String?    //등록 일자
    let updated: String?    //수정 일자
}

//MARK: - 충전기 예약 정보
struct ChargerReservation: Codable {
    let chargerAllowTime: ChargerAllowTime  //충전기 이용 가능 시간
    let reservations: Reservations  //예약 정보
}

//MARK: - 충전기 이용 가능 시간
struct ChargerAllowTime: Codable {
    let chargerId: Int  //충전기 ID
    let todayOpenTime: String   //당일 오픈 시간
    let todayCloseTime: String  //당일 클로즈 시간
    let tomorrowOpenTime: String    //명일 오픈 시간
    let tomorrowCloseTime: String   //명일 클로즈 시간
}

//MARK: - 예약 정보
struct Reservations: Codable {
    let content: [ReservationContent?]  //예약 정보 내용
    let pageable: Pageable  //페이징 정보
    let totalPages: Int?    //총 페이지 수
    let totalElements: Int? //총 예약 수
    let numberOfElements: Int?  //예약 번호
    let first: Bool?
    let last: Bool?
    let sort: Sort
    let size: Int?
    let number: Int?
    let empty: Bool?
}

//MARK: - 예약 정보 내용
struct ReservationContent: Codable {
    let id: Int?    //예약 ID
    let userId: Int?    //사용자 ID
    let username: String?   //사용자 명
    let chargerId: Int? //충전기 ID
    let chargerName: String?    //충전기 명
    let bleNumber: String?  //BLE 번호
    let chargerAddress: String? //충전기 주소
    let chargerDetailAddress: String?   //충전기 상세주소
    let gpsX: Double?   //X좌표(경도)
    let gpsY: Double?   //Y좌표(위도)
    let rangeOfFee: String? //충전 단가
    let expectPoint: Int?   //예상 포인트
    let startDate: String?  //시작 일자
    let endDate: String?    //종료 일자
    let cancelDate: String? //취소 일자
    let state: String?  //상태
    let created: String?    //등록 일자
    let updated: String?    //수정 일자
}

// MARK: - 페이징 정보
struct Pageable: Codable {
    let sort: Sort
    let pageNumber: Int?
    let ageSize: Int?
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

struct ChargerModel: Identifiable, Codable{
    let id: String
    let markerId: Int
    let longitude: Double   //경도
    let latitude: Double    //위도
    let markerName: String  //충전기 이름
    let address: String     //주소
    
    
    init(id: String = UUID().uuidString, markerId: Int, longitude: Double, latitude: Double, markerName: String, address: String){
        self.id = id
        self.markerId = markerId
        self.longitude = longitude
        self.latitude = latitude
        self.markerName = markerName
        self.address = address
    }
    
    func updateCompletion() -> ChargerModel{
        return ChargerModel(id: id, markerId: markerId, longitude: longitude, latitude: latitude , markerName: markerName, address: address)
    }
}
