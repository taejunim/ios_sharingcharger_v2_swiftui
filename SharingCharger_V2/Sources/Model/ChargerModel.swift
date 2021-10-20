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

//MARK: - 소유주 충전기 정보 목록
struct OwnerChargers: Codable {
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
    let ownChargerCount: Int    //소유주 총 충전기 개수
    let currentChargerCount: Int    //현재 충전기 개수
    let currentPoint: Int   //현재 수익 포인트
    let monthlyReserveCount: Int    //월별 예약 건 수
    let monthlyRechargeCount: Int   //월별 충전 건 수
    let monthlyRechargeKwh: Double  //월별 충전 kWh
    let monthlyChargerErrorCount: Int   //월별 충전기 오류 건 수
    let monthlyCumulativePoint: Int //월별 누적 포인트
}

//MARK: - 충전기 충전 단가 정보
struct ChargerUnitPrice: Codable {
    let id: Int //단가 ID
    let hour: String    //시간 대
    let fee: Int    //가격
}

//MARK: - 충전기 이용시간 정보
struct ChargerUsageTime: Codable {
    let id: Int //이용시간 ID
    let chargerId: Int  //충전기 ID
    let chargerName: String //충전기 명
    let openTime: String    //오픈 시간
    let closeTime: String   //클로즈 시간
    let previousOpenTime: String    //이전 오픈 시간
    let previousCloseTime: String   //이전 클로즈 시간
    let created: String //생성일자
    let updated: String //수정일자
}

//MARK: - 할당된 충전기 정보
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
