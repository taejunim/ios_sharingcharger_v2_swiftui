//
//  ChargerDetailViewModel.swift
//  SharingCharger_V2
//
//  Created by 조유영 on 2021/09/29.
//

import Foundation
import Combine

class ChargerDetailViewModel: ObservableObject {
    
    private let chargerAPI = ChargerAPIService()  //소유주 충전기 API Service
    private let chargeAPI = ChargeAPIService()   //소유주 충전기 이력 API Service
    
    @Published var viewUtil = ViewUtil() //View Util
    @Published var charger:[String:String] = [:] //조회환 포인트 정보 목록
    
    @Published var chargerId:String = ""
    
    //소유주 충전기 상세 메인화면 / 정보수정
    @Published var chargerName:String = ""
    @Published var address:String = ""
    @Published var detailAddress:String = ""
    @Published var parkingFeeDescription:String = ""
    @Published var parkingFeeFlag:Bool = false
    @Published var cableFlag:Bool = false
    @Published var rangeOfFee:Int = 0
    @Published var gpsX:Double = 0.0
    @Published var gpsY:Double = 0.0
    @Published var description:String = ""
    @Published var chargerType:String = ""
    @Published var sharedType:String = ""
    @Published var bleNumber:String = ""
    @Published var middlewareIp:String = ""
    @Published var currentStatusType:String = ""
    @Published var supplyCapacity:String = ""
    @Published var providerCompanyId:Int = 0
    
    //소유주 이용시간 변경
    @Published var previousOpenTime: Date = Date()
    @Published var previousCloseTime: Date = Date()           //date picker 종료 날짜(현재 날짜)
    @Published var openTime: Date = Date()
    @Published var closeTime: Date = Date()
    
    //소유주 단가변경
    @Published var stringUnitPrice:String = "2,000" {   //선택 변경 금액
        didSet {
            checkIsDirectInput()
        }
    }
    @Published var unitPrice:Int = 2000
    @Published var isDirectlyInput: Bool = false    //직접입력 여부
    
    //소유주 충전이력
    @Published var totalCount: Int = 0  //총 검색 개수
    @Published var histories: [[String:String]] = [] //조회환 소유주 충전기 이력 목록
    @Published var isSearchStart: Bool = true       //조회 시작 여부
    @Published var showSearchModal:Bool = false
    @Published var chooseDate: String = "oneMonth"{     //조회기간 선택
        didSet {
            showSelectMonth()
        }
    }
    @Published var selectMonth: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())! //date picker 시작 날짜(선택 날짜)
    @Published var currentDate: Date = Date()           //date picker 종료 날짜(현재 날짜)
    @Published var page: Int = 1                        //페이지 번호
    @Published var selectSort: String = "DESC"          //정렬
    let pageSize: String = "10"
    
    func requestOwnerCharger(chargerId: String) {
        
        viewUtil.isLoading = true   //로딩 시작
        
        //charger.removeAll()
        var searchCharger:[String:String] = [:]
        
        //소유자 충전기 요약 정보 조회 API 호출
        let request = chargerAPI.requestOwnerCharger(chargerId: chargerId)
        request.execute(
        //API 호출 성공
            onSuccess: { (charger) in
                    
                let name = charger.name
                let bleNumber = charger.bleNumber
                let providerCompanyName = charger.providerCompanyName
                let address = charger.address
                let detailAddress = charger.detailAddress
                var parkingFeeFlag = "무료주차"
                let parkingFeeDescription = charger.parkingFeeDescription
                let description = charger.description
                
                if(charger.parkingFeeFlag!) { parkingFeeFlag = "유료주차" }
                
                searchCharger = [
                    "name": name!,
                    "bleNumber": bleNumber!,
                    "providerCompanyName": providerCompanyName!,
                    "address": address!,
                    "detailAddress": detailAddress!,
                    "parkingFeeFlag": parkingFeeFlag,
                    "parkingFeeDescription": parkingFeeDescription!,
                    "description" : description!
                ]
                
                self.chargerName = name!
                self.address = address!
                self.detailAddress = detailAddress!
                self.parkingFeeDescription = parkingFeeDescription!
                self.parkingFeeFlag = charger.parkingFeeFlag!
                self.cableFlag = charger.cableFlag!
                self.rangeOfFee = Int(charger.rangeOfFee!.replacingOccurrences(of: "p", with: "")) ?? 0
                self.gpsX = charger.gpsX ?? 0.0
                self.gpsY = charger.gpsY ?? 0.0
                self.description = charger.description ?? ""
                self.chargerType = charger.chargerType!
                self.sharedType = charger.sharedType!
                self.bleNumber = charger.bleNumber!
                self.middlewareIp = charger.middlewareIp ?? ""
                self.currentStatusType = charger.currentStatusType!
                self.supplyCapacity = charger.supplyCapacity!
                self.providerCompanyId = charger.providerCompanyId!
                
                self.charger = searchCharger

                self.requestUsageTime(chargerId: chargerId)
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
    
    func requestUpdateCharger(chargerId:String, completion: @escaping (String) -> Void) {
        
        let dialog = UIAlertController(title:"", message : "입력하신 정보로 수정하시겠습니까?", preferredStyle: .alert)
        
        dialog
            .addAction(
                UIAlertAction(title: "취소", style: UIAlertAction.Style.destructive) { (action:UIAlertAction) in
                    return
                }
            )
        dialog
            .addAction(
                UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { (action:UIAlertAction) in
                    
                    let userType:String = UserDefaults.standard.string(forKey: "userType")!   //저장된 사용자 ID 번호
                    let ownerName:String = UserDefaults.standard.string(forKey: "userId")!   //저장된 사용자 ID 번호
                    
                    let parameters = [
                        "address": self.address,
                        "bleNumber": self.bleNumber,
                        "cableFlag": self.cableFlag,
                        "chargerType": self.chargerType,
                        "currentStatusType": self.currentStatusType,
                        "description": self.description,
                        "detailAddress": self.detailAddress,
                        "gpsX": self.gpsX,
                        "gpsY": self.gpsY,
                        "middlewareIp": self.middlewareIp,
                        "name": self.chargerName,
                        "ownerName": ownerName,
                        "ownerType": userType,
                        "parkingFeeDescription": self.parkingFeeDescription,
                        "parkingFeeFlag": self.parkingFeeFlag,
                        "providerCompanyId": self.providerCompanyId,
                        "sharedType": self.sharedType,
                        "supplyCapacity": self.supplyCapacity
                    ] as [String : Any]
                    
                    let request = self.chargerAPI.requestUpdateCharger(chargerId: chargerId, parameters: parameters)
                    request.execute(onSuccess:{(ownerCharger) in
                        completion("success")
                    }, onFailure: { (error) in
                        completion("failure")
                        print(error)
                    })
                }
            )
        
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.rootViewController?.present(dialog, animated: true, completion: nil)
        
        
    }
    
    func requestUpdateUnitPrice(chargerId:String, completion: @escaping (String) -> Void) {
        
        let dialog = UIAlertController(title:"", message : "설정한 단가로 변경하시겠습니까?\n 단가 정보 변경시 기존 예약건에 대해서는 적용되지 않고 신규 예약건에 대해서만 반영됩니다.\n 변경하시겠습니까?", preferredStyle: .alert)
        
        dialog
            .addAction(
                UIAlertAction(title: "취소", style: UIAlertAction.Style.destructive) { (action:UIAlertAction) in
                    return
                }
            )
        dialog
            .addAction(
                UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { (action:UIAlertAction) in
                    
                    let userId:Int = Int(UserDefaults.standard.string(forKey: "userIdNo")!)!   //저장된 사용자 ID 번호
                    let unitPrice:Int = self.unitPrice
                    
                    let parameters = [
                        "price": unitPrice,
                        "userId": userId
                    ]
                    
                    let request = self.chargerAPI.requestUpdateUnitPrice(chargerId: chargerId, parameters: parameters)
                    request.execute(onSuccess:{(chargerUnitPrice) in
                        completion("success")
                        
                    }, onFailure: { (error) in
                        completion("failure")
                        print(error)
                    })
                    
                }
            )
        
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.rootViewController?.present(dialog, animated: true, completion: nil)
        
    }
    
    func requestUpdateUsageTime(chargerId: String, completion: @escaping (String) -> Void) {
        
        
        let dialog = UIAlertController(title:"", message : "충전기 운영 시간 수정시 기존 예약건에 대해서는 적용되지 않고 신규 예약건에 대해서만 반영됩니다.\n수정하시겠습니까?", preferredStyle: .alert)
        
        dialog
            .addAction(
                UIAlertAction(title: "취소", style: UIAlertAction.Style.destructive) { (action:UIAlertAction) in
                    return
                }
            )
        dialog
            .addAction(
                UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { (action:UIAlertAction) in
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm:ss"
        
                    let parameters = [
                        "openTime": dateFormatter.string(from: self.openTime),
                        "closeTime": dateFormatter.string(from: self.closeTime)
                    ]
        
                    let request = self.chargerAPI.requestUpdateUsageTime(chargerId: chargerId, parameters: parameters)
                    request.execute(onSuccess:{(chargerUsageTime) in
                        completion("success")
                        
                    }, onFailure: { (error) in
                        completion("failure")
                        print(error)
                    })
                }
            )
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.rootViewController?.present(dialog, animated: true, completion: nil)
            
    }
    
    func requestUsageTime(chargerId: String){
        
        let request = chargerAPI.requestUsageTime(chargerId: chargerId)
        request.execute(onSuccess:{(chargerUsageTime) in
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            
            self.previousOpenTime = dateFormatter.date(from : chargerUsageTime.previousOpenTime)!
            self.previousCloseTime = dateFormatter.date(from : chargerUsageTime.previousCloseTime)!
            self.openTime = dateFormatter.date(from : chargerUsageTime.previousOpenTime)!
            self.closeTime = dateFormatter.date(from : chargerUsageTime.previousCloseTime)!
            

        }, onFailure: { (error) in
            print(error)
        })
    }
    
    func requestOwnerChargeHistory(chargerId : String) {
        
        let userIdNo:String = UserDefaults.standard.string(forKey: "userIdNo")!   //저장된 사용자 ID 번호
        let userId:String = UserDefaults.standard.string(forKey: "userId")!   //저장된 사용자 ID 번호
        
        let parameters = [
            "chargerId": chargerId,
            "page": String(self.page),
            "size": pageSize,
            "sort": self.selectSort,
            "startDate": "yyyy-MM-dd".dateFormatter(formatDate: self.selectMonth),   //조회 시작일자
            "endDate": "yyyy-MM-dd".dateFormatter(formatDate: self.currentDate)      //조회 종료일자
        ]

        let request = chargeAPI.requestOwnerChargeHistory(userIdNo: userIdNo, parameters: parameters)
        request.execute(onSuccess:{(chargingHistory) in
        
            let histories = chargingHistory.content //충전 이력 목록 추출
            self.totalCount = chargingHistory.totalElements //총 개수
            
            for index in 0..<histories.count {
                    
                let searchHistory = histories[index]
                var history: [String:String] = [:]
                
                ///충전 일시 예외처리 및 포맷팅
                let stringStartRechargeDate = searchHistory!.startRechargeDate ?? ""
                let stringEndRechargeDate = searchHistory!.endRechargeDate ?? ""
                
                ///예약 일시 예외처리 및 포맷팅
                let stringReservationStartDate = searchHistory!.reservationStartDate
                let stringReservationEndDate = searchHistory!.reservationEndDate
                    
                var startDate: Date?
                var endDate: Date?
                
                var formatRechargeStartDate = ""
                var formatRechargeEndDate = ""
                
                var formatReservationStartDate = ""
                var formatReservationEndDate = ""
                    
                let username = searchHistory!.username
                
                if stringStartRechargeDate != "" {
                    startDate = "yyyy-MM-dd HH:mm:ss".toDateFormatter(formatString: stringStartRechargeDate)  //충전 시작일시 Date 형식 변환
                    formatRechargeStartDate = "yyyy-MM-dd HH:mm".dateFormatter(formatDate: startDate!)  //충전 시작일시 String 형식 변환
                }
                    
                if stringEndRechargeDate != "" {
                    endDate = "yyyy-MM-dd HH:mm:ss".toDateFormatter(formatString: stringEndRechargeDate)  //충전 종료일시 Date 형식 변환
                    formatRechargeEndDate = "yyyy-MM-dd HH:mm".dateFormatter(formatDate: endDate!)  //충전 시작일시 String 형식 변환
                }
                
                if stringReservationStartDate != "" {
                    startDate = "yyyy-MM-dd HH:mm:ss".toDateFormatter(formatString: stringReservationStartDate)  //충전 시작일시 Date 형식 변환
                    formatReservationStartDate = "yyyy-MM-dd HH:mm".dateFormatter(formatDate: startDate!)  //충전 시작일시 String 형식 변환
                }
                    
                if stringReservationEndDate != "" {
                    endDate = "yyyy-MM-dd HH:mm:ss".toDateFormatter(formatString: stringReservationEndDate)  //충전 종료일시 Date 형식 변환
                    formatReservationEndDate = "yyyy-MM-dd HH:mm".dateFormatter(formatDate: endDate!)  //충전 시작일시 String 형식 변환
                }
                
                ///포인트 예외처리 및 포맷팅
                var ownerPoint = ""   //실제 차감 포인트
                let searchPoint = searchHistory!.ownerPoint ?? 0
                
                if (searchPoint > 0 && userId != username) {
                    ownerPoint = String(searchHistory!.ownerPoint!).pointFormatter()
                } else if (searchPoint <= 0 && userId == username){
                    ownerPoint = "소유주 본인 충전"
                } else {
                    ownerPoint = "알 수 없음"
                }
                    
                history = [
                    "chargerName": searchHistory!.chargerName,    //충전기 명
                    "id": String(searchHistory!.id),    //충전 ID
                    "rechargePeriod": formatRechargeStartDate + " ~ " + formatRechargeEndDate,   //충전 시작일시
                    "reservationPeriod": formatReservationStartDate + " ~ " + formatReservationEndDate,   //충전 종료일시
                    "ownerPoint": ownerPoint
                ]
                    
                self.histories.append(history)
            }
            

        }, onFailure: { (error) in
            print(error)
        })
    }
    
    func resetSearchCondition() {
        chooseDate = "oneMonth"
        selectSort = "DESC"
        selectMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        currentDate = Date()
    }
    
    //MARK: - 조회기간 선택에 따른 날짜 변화
    func showSelectMonth(){
        if chooseDate == "ownPeriod"{
            selectMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        } else {
            currentDate = Date()
            if chooseDate == "oneMonth"         { selectMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())!}
            else if chooseDate == "threeMonth"  { selectMonth = Calendar.current.date(byAdding: .month, value: -3, to: Date())!}
            else if chooseDate == "sixMonth"    { selectMonth = Calendar.current.date(byAdding: .month, value: -6, to: Date())!}
        }
    }
    
    func checkIsDirectInput() {
        if stringUnitPrice != "2,000" && stringUnitPrice != "1,500" && stringUnitPrice != "1,000"{
            isDirectlyInput = true
        } else {
            unitPrice = Int(stringUnitPrice.replacingOccurrences(of: ",", with: "")) ?? 0
            isDirectlyInput = false
        }
    }
}
