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
