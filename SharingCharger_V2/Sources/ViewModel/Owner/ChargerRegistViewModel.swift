//
//  ChargerRegistViewModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/27.
//

import Foundation
import CoreBluetooth
import EvzBLEKit

class ChargerRegistViewModel: ObservableObject {
    private let chargerAPI = ChargerAPIService()
    
    @Published var currentStep: Int = 1
    @Published var isFirstStepComplete: Bool = false
    @Published var isSecondStepComplete: Bool = false
    @Published var isThirdStepComplete: Bool = false
    
    @Published var isShowBLEModal: Bool = false
    @Published var chargerBLEList: [[String:String]] = []
    @Published var selectBLENumber: String = ""
    @Published var tempSelectBLENumber: String = ""
    
    func getBLENumberList(getBleNumbers: [String]) {
        
        
//        if bleNumberList != [] {
//            selectBLENumber = bleNumberList[0]["bleNumber"]
//            tempSelectBLENumber = selectBLENumber
//        }
        
        for bleNumber in getBleNumbers {
            print(bleNumber.components(separatedBy: [":"]).joined())
            
            let subBLENumber = bleNumber.components(separatedBy: [":"]).joined()
            
            let parameters = [
                "bleNumber": subBLENumber,
                "page": "1",
                "size": "1",
                "sort": "DESC"
            ]
            
            let request = chargerAPI.requestSearchAssignedCharger(parameters: parameters)
            request.execute(
                //API 호출 성공
                onSuccess: { (assigned) in
                    print(assigned)
                    let charger = assigned.content
                    
                    var isAssigned = "false"
                    
                    if charger.count == 0 {
                        isAssigned = "false"
                    }
                    else {
                        isAssigned = "true"
                    }
                    
                    let chargerBLE = [
                        "bleNumber": bleNumber,
                        "isAssigned": isAssigned
                    ]
                    
                    self.chargerBLEList.append(chargerBLE)
                    
                    
                },
                //API 호출 실패
                onFailure: { (error) in
                    print(error)
                }
            )
        }
    }
}
