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
    
    @Published var isLoading: Bool = false  //로딩 화면 호출 여부
    @Published var isShowToast: Bool = false    //Toast 팝업 호출 여부
    @Published var showMessage: String = "" //Toast 팝업 메시지
    
    @Published var currentStep: Int = 1
    
    @Published var isShowBLEModal: Bool = false
    @Published var chargerBLEList: [[String:String]] = []
    @Published var selectBLENumber: String = ""
    @Published var tempSelectBLENumber: String = ""
    
    @Published var registChargerId: String = ""
    @Published var chargerName: String = ""
    @Published var chargerDescription: String = ""
    @Published var isShowAddressModal: Bool = false
    @Published var address: String = ""
    @Published var detailAddress: String = ""
    @Published var selectSharedType: String = "PARTIAL_SHARING"
    @Published var selectCableFlag: Bool = true
    @Published var selectSupplyCapacity: String = "STANDARD"
    @Published var selectParkingFeeFlg: Bool = false
    @Published var parkingFeeDescription: String = ""
    @Published var providerId: String = ""
    
    //MARK: - Toast 메시지 팝어
    /// - Parameter message: 메시지(String)
    func toastMessage(message: String) {
        isShowToast = true  //Toast 팝업 호출 여부
        showMessage = message   //보여줄 메시지
    }
    
    func getBLENumberList(getBleNumbers: [String]) {
        chargerBLEList.removeAll()
        selectBLENumber = ""
        tempSelectBLENumber = ""
        
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
                    
                    let charger = assigned.content
                    
                    var chargerId = ""
                    var providerId = ""
                    var isAssigned = "false"
                    
                    if charger.count == 0 {
                        isAssigned = "false"
                    }
                    else {
                        isAssigned = "true"
                        
                        if self.selectBLENumber == "" {
                            self.registChargerId = String(charger[0].id!)
                            self.selectBLENumber = charger[0].bleNumber!
                            self.tempSelectBLENumber = charger[0].bleNumber!
                            self.providerId = String(charger[0].providerCompanyId!)
                        }
                        
                        chargerId = String(charger[0].id!)
                        providerId = String(charger[0].providerCompanyId!)
                    }
                    
                    let chargerBLE = [
                        "chargerId": chargerId,
                        "bleNumber": bleNumber,
                        "providerId": providerId,
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
    
    func checkNextStep() {
        if currentStep == 1 {
            if selectBLENumber == "" {
                toastMessage(message: "등록할 충전기 BLE 번호가 선택되지 않았습니다.\n충전기 검색 후, 등록할 충전기 BLE 번호를 선택 바랍니다.")
            }
            else {
                currentStep += 1
            }
        }
        else if currentStep == 2 {
            if !chargerName.trimmingCharacters(in: .whitespaces).isEmpty {
                currentStep += 1
            }
            else {
                toastMessage(message: "충전기 명을 입력하지 않았습니다.")
            }
        }
    }
    
    func checkRegistStep() -> Bool {
        
        if !address.trimmingCharacters(in: .whitespaces).isEmpty {
            
            if !detailAddress.trimmingCharacters(in: .whitespaces).isEmpty {
                
                if selectParkingFeeFlg {
                    
                    if !parkingFeeDescription.trimmingCharacters(in: .whitespaces).isEmpty {
                        
                        return true
                    }
                    else {
                        toastMessage(message: "주차 요금 설명 항목을 입력하지 않았습니다.")
                        return false
                    }
                }
                else {
                    return true
                }
            }
            else {
                toastMessage(message: "상세주소 항목을 입력하지 않았습니다.")
                return false
            }
        }
        else {
            toastMessage(message: "주소 항목을 입력하지 않았습니다.")
            return false
        }
    }
    
    func registCharger(completion: @escaping (String) -> Void) {
        
        let ownerId: String = UserDefaults.standard.string(forKey: "userId")!
        
        let parameters: [String : Any] = [
            "name": chargerName, //충전기 명
            "chargerType": "BLE",   //충전기 유형
            "bleNumber": selectBLENumber,    //BLE 번호
            "description": chargerDescription,  //충전기 설명
            "address": address,  //주소
            "detailAddress": detailAddress,    //상세주소
            "gpsX": 0,
            "gpsY": 0,
            "sharedType": selectSharedType,   //공유 유형
            "cableFlag": selectCableFlag,    //케이블 유무
            "supplyCapacity": selectSupplyCapacity,   //충전 속도 유형
            "parkingFeeFlag": selectParkingFeeFlg,    //주차 요금 여부
            "parkingFeeDescription": parkingFeeDescription,    //주차 요금 설명
            "ownerType": "Personal",    //소유주 유형
            "ownerName": ownerId,    //소유주 ID (이메일)
            "providerCompanyId": Int(providerId)!,    //충전기 공급 회사 ID
            "currentStatusType": "READY"    //충전기 상태 (기본값: READY)
        ]
        
        print(parameters)
        print(registChargerId)
        
        let request = chargerAPI.requestAssignedCharger(chargerId: registChargerId, parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (result) in
                print(result)
                completion("success")
            },
            //API 호출 실패
            onFailure: { (error) in
                print(error)
                completion("error")
            }
        )
    }
}
