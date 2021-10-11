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
    
    @Published var viewUtil = ViewUtil() //View Util
    @Published var charger:[String:String] = [:] //조회환 포인트 정보 목록
    
    @Published var chargerId:String = ""
    
    @Published var chargerName:String = ""
    @Published var address:String = ""
    @Published var detailAddresss:String = ""
    @Published var parkingFeeDescription:String = ""
    @Published var parkingFeeFlag:Bool = false
    @Published var cableFlag:Bool = false
    @Published var rangeOfFee:String = ""
   
    //소유주 단가변경
    @Published var unitPrice:String = "2,000"   //선택 변경 금액
    
    //소유주 충전이력
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
                    "parkingFeeFlag": parkingFeeFlag,
                    "parkingFeeDescription": parkingFeeDescription!,
                    "description" : description!
                ]
                
                self.chargerName = name!
                self.address = address!
                self.detailAddresss = detailAddress!
                self.parkingFeeDescription = parkingFeeDescription!
                self.parkingFeeFlag = charger.parkingFeeFlag!
                self.cableFlag = charger.cableFlag!
                self.rangeOfFee = charger.rangeOfFee!.replacingOccurrences(of: "p", with: "")
                
                self.charger = searchCharger

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
    
    func requestUpdateCharger() {
        
    }
    
    func requestUpdateUnitPrice(chargerId:String, completion: @escaping (String) -> Void) {
        
        let dialog = UIAlertController(title:"", message : "설정한 단가로 변경하시겠습니까?\n 단가 정보 변경시 기존 예약건에 대해서는 적용되지 않고 신규 예약건에 대해서만 반영됩니다.\n 변경하시겠습니까? ", preferredStyle: .alert)
        
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
                    let unitPrice:Int = Int(self.unitPrice.replacingOccurrences(of: ",", with: ""))!
                    
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
    
    func requestUpdateUsageTime() {
        
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
}
