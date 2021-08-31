//
//  ChargerModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/24.
//

import Foundation

struct Charger: Codable {
    let id: Int?
    let name: String?
    let address: String?
    let detailAddress: String?
    let gpsX: Double?
    let gpsY: Double?
    let description: String?
    
    let sharedType: String?
    let bleNumber: String?
    let currentStatusType: String?
    let cableFlag: Bool?
    let rangeOfFee: String?
    
    let parkingFeeFlag: Bool?
    let parkingFeeDescription: String?
    
    let ownerType: String?
    let ownerName: String?
    let providerCompanyId: Int?
    
    let searchDateFlag: Bool?
    let created: String?
    let updated: String?
}

// MARK: - Welcome
struct ChargerReservation: Codable {
    let chargerAllowTime: ChargerAllowTime
    let reservations: Reservations
}

// MARK: - ChargerAllowTime
struct ChargerAllowTime: Codable {
    let chargerId: Int
    let todayOpenTime: String
    let todayCloseTime: String
    let tomorrowOpenTime: String
    let tomorrowCloseTime: String
}

// MARK: - Reservations
struct Reservations: Codable {
    let content: [ReservationContent?]
    let pageable: Pageable
    let totalPages: Int?
    let totalElements: Int?
    let last: Bool?
    let numberOfElements: Int?
    let first: Bool?
    let sort: Sort
    let size, number: Int?
    let empty: Bool?
}

// MARK: - Content
struct ReservationContent: Codable {
    let id: Int?
    let userId: Int?
    let username: String?
    let chargerId: Int?
    let chargerName: String?
    let chargerAddress: String?
    let chargerDetailAddress: String?
    let rangeOfFee: String?
    let expectPoint: Int?
    let startDate, endDate: String?
    let cancelDate: String?
    let state: String?
    let created: String?
    let updated: String?
    let gpsX: Double?
    let gpsY: Double?
    let bleNumber: String?
}

// MARK: - Pageable
struct Pageable: Codable {
    let sort: Sort
    let pageNumber: Int?
    let ageSize: Int?
    let offset: Int?
    let unpaged: Bool?
    let paged: Bool?
}

// MARK: - Sort
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
