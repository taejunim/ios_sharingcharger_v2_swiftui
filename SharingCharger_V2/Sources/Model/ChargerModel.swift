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
    
    let chargerType: String?    //충전기 종류
    let sharedType: String? //공유 유형
    let bleNumber: String?  //BLE 번호
    let middlewareIp: String? //모뎀 IP
    
    let currentStatusType: String?  //현재 충전기 상태
    let cableFlag: Bool?    //케이블 유무
    let rangeOfFee: String? //충전 단가
    let supplyCapacity: String?
    
    let parkingFeeFlag: Bool?   //주차 요금 유무
    let parkingFeeDescription: String?  //주차 요금 설명
    
    let ownerType: String?  //소유자 유형
    let ownerName: String?  //소유자 명
    let providerCompanyId: Int? //충전기 업체 ID
    
    let searchDateFlag: Bool?
    let created: String?    //등록 일자
    let updated: String?    //수정 일자
}

//MARK: - 소유자 충전기 정보
struct OwnerCharger: Codable {
    let id: Int?    //충전기 ID
    let name: String?   //충전기 명
    let address: String?    //충전기 주소
    let detailAddress: String?  //충전기 상세주소
    let gpsX: Double?   //X좌표(경도)
    let gpsY: Double?   //Y좌표(위도)
    let description: String?    //설명
    
    let chargerType: String?    //충전기 종류
    let sharedType: String? //공유 유형
    let bleNumber: String?  //BLE 번호
    let middlewareIp: String? //모뎀 IP

    let currentStatusType: String?  //현재 충전기 상태
    let cableFlag: Bool?    //케이블 유무
    let rangeOfFee: String? //충전 단가
    let supplyCapacity: String?
    
    let parkingFeeFlag: Bool?   //주차 요금 유무
    let parkingFeeDescription: String?  //주차 요금 설명
    
    let ownerType: String?  //소유자 유형
    let ownerName: String?  //소유자 명
    let providerCompanyId: Int? //충전기 업체 ID
    let providerCompanyName: String?    //충전기 업체 명

    let created: String?    //등록 일자
    let updated: String?    //수정 일자
}

//MARK: - 소유주 충전기 요약 정보
struct OwnerChargerSummary: Codable {
    let ownChargerCount: Int
    let currentChargerCount: Int
    let currentPoint: Int
    let monthlyReserveCount: Int
    let monthlyRechargeCount: Int
    let monthlyRechargeKwh: Int
    let monthlyChargerErrorCount: Int
    let monthlyCumulativePoint: Int
}

//MARK: - 충전기 충전 단가 정보
struct ChargerUnitPrice: Codable {
    let id: Int
    let hour: String
    let fee: Int
}

//MARK: - 충전기 이용시간 정보
struct ChargerUsageTime: Codable {
    let id: Int
    let chargerId: Int
    let chargerName: String
    let openTime: String
    let closeTime: String
    let previousOpenTime: String
    let previousCloseTime: String
    let created: String
    let updated: String
}

struct AssignedCharger: Codable {
    let content: [OwnerCharger]
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
