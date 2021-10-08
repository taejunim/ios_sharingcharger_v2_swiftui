//
//  ChargerDetailViewModel.swift
//  SharingCharger_V2
//
//  Created by 조유영 on 2021/09/29.
//

import Foundation

class ChargerDetailViewModel: ObservableObject {
    
    private let chargerAPI = ChargerAPIService()  //소유주 충전기 API Service
    
    @Published var viewUtil = ViewUtil() //View Util
    @Published var charger: [String:String] = [:] //조회환 포인트 정보 목록
    
    @Published var chargerId:String = ""
    
    @Published var chargerName:String = ""
    @Published var address:String = ""
    @Published var detailAddresss:String = ""
    @Published var parkingFeeDescription:String = ""
    @Published var parkingFeeFlag:Bool = false
    @Published var cableFlag:Bool = false
    @Published var rangeOfFee:String = ""
   
    
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
                
                print(charger)
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
}
