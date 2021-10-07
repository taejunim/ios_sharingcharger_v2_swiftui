//
//  OwnerChargerViewModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/27.
//

import Foundation

class OwnerChargerViewModel: ObservableObject {
    
    private let chargerAPI = ChargerAPIService()  //사용자 API Service
    private let pointAPIService = PointAPIService()  //포인트 API Service
    
    let ownerIdNo:String = UserDefaults.standard.string(forKey: "userIdNo") ?? ""   //저장된 사용자 ID 번호
    
    @Published var viewUtil = ViewUtil() //View Util
    @Published var showRegistView: Bool = false
    @Published var showProfitPointsView: Bool = false
    @Published var ownChargerCount: Int = 0
    @Published var monthlyCumulativePoint: Int = 0

    @Published var chargers: [[String:String]] = [] //조회환 충전기 정보 목록
    @Published var isShowYearPopupView: Bool = false //년도 팝업 flag
    @Published var searchYear: String = "" //년도
    
    @Published var searchPoints: [[String:String]] = [] //조회환 포인트 정보 목록
    
    func requestOwnerChargerList() {

        viewUtil.isLoading = true   //로딩 시작
        chargers.removeAll()    //조회한 포인트 목록 마커 정보 초기화
        
        let ownerType:String = UserDefaults.standard.string(forKey: "userType") ?? ""
        
        var searchCharger:[String:String] = [:]  
        var searchChargers:[[String:String]] = []
        
        //사용자 포인트 이력 조회 API 호출
        let request = chargerAPI.requestOwnerChargerList(ownerIdNo: ownerIdNo, ownerType: ownerType)
        request.execute(
        //API 호출 성공
            onSuccess: { (charger) in
                    
                for index in 0..<charger.count {
                    
                    let charger = charger[index]
                    let id = charger.id
                    let name = charger.name
                    let address = charger.address
                    let description = charger.description
                    let currentStatusType = charger.currentStatusType
                    let bleNumber = charger.bleNumber
                    var type: String = ""
                    var typeColor: String = ""

                    //포인트 유형
                    if currentStatusType == "READY"{
                        type = "대기중"
                        typeColor = "#3498DB"
                    }
                    else {
                        typeColor = "#8E44AD"
                        
                        if(currentStatusType == "RESERVATION")   { type = "예약중" }
                        else if(currentStatusType == "CHARGING") { type = "충전중" }
                        else if(currentStatusType == "TROUBLE")  { type = "점검중" }
                        else if(currentStatusType == "CLOSE")    { type = "마감" }
                    }
                    
                    
                    //포인트 이력 정보
                    searchCharger = [
                        "id": String(id!),
                        "name": name!,                           //충전기 명
                        "address": address!,                     //주소
                        "description": description!,             //설명
                        "bleNumber": bleNumber!,                 //ble번호
                        "currentStatusType": type,               //현재 충전기 상태
                        "typeColor": typeColor,                  //type에 따른 color
                        "index": String(index + 1)
                    ]
                 
                    searchChargers.append(searchCharger)
                }
                self.chargers.append(contentsOf: searchChargers)
                },
                //API 호출 실패
                onFailure: { (error) in
                    switch error {
                    case .responseSerializationFailed:
                        print(error)
                    //일시적인 서버 오류 및 네트워크 오류
                    default:
                        print(error)
                        break
                    }
                }
            )
        }
    
    func requestOwnerSummaryInfo() {
        
        //소유자 충전기 요약 정보 조회 API 호출
        let request = chargerAPI.requestOwnerSummaryInfo(ownerIdNo: ownerIdNo)
        request.execute(
        //API 호출 성공
            onSuccess: { (ownerChargerSummary) in
                
                self.ownChargerCount = ownerChargerSummary.ownChargerCount
                self.monthlyCumulativePoint = ownerChargerSummary.monthlyCumulativePoint
                
                },
                //API 호출 실패
                onFailure: { (error) in
                    switch error {
                    case .responseSerializationFailed:
                        print(error)
                    //일시적인 서버 오류 및 네트워크 오류
                    default:
                        print(error)
                        break
                    }
                }
            )
    }
    
    //월별 수익 포인트
    func requestProfitPoints() {
        
        let userIdNo:String = UserDefaults.standard.string(forKey: "userIdNo") ?? ""   //저장된 사용자 ID 번호
        
        let parameters = [
            "searchType": "MONTH",
            "searchMonth": "12",
            "searchYear": searchYear
        ]
        
        var searchPoint: [String:String] = [:]    //조회한 포인트 정보
        var searchPoints: [[String:String]] = []  //조회환 포인트 정보 목록
        
        //소유자 충전기 요약 정보 조회 API 호출
        let request = pointAPIService.requestProfitPoints(userIdNo: userIdNo, parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (profitPoint) in
                self.searchPoints.removeAll()

                let currentDate = Date()
                
                for profitPointObject in profitPoint.reversed() {
                    print("month : \(profitPointObject.day)")
                    print("point : \(profitPointObject.point)")
                    
                    if currentDate >= "yyyy-MM".toDateFormatter(formatString: profitPointObject.day)! {
                        //포인트 이력 정보
                        searchPoint = [
                            "month": profitPointObject.day,
                            "point": String(profitPointObject.point)
                        ]
                        searchPoints.append(searchPoint)    //조회 포인트 목록 추가
                    }
                }
                
                self.searchPoints.append(contentsOf: searchPoints)  //조회 포인트 목록 추가
                
                },
            //API 호출 실패
            onFailure: { (error) in
                switch error {
                case .responseSerializationFailed:
                    print(error)
                //일시적인 서버 오류 및 네트워크 오류
                default:
                    print(error)
                    break
                }
            }
        )
    }
}
