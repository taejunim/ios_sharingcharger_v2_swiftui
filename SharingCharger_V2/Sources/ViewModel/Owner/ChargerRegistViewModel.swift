//
//  ChargerRegistViewModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/27.
//

import Foundation
import CoreBluetooth
import EvzBLEKit

///충전기 등록 View Model
class ChargerRegistViewModel: ObservableObject {
    private let chargerAPI = ChargerAPIService()    //충전기 API Service
    
    @Published var isLoading: Bool = false  //로딩 화면 호출 여부
    @Published var isShowToast: Bool = false    //Toast 팝업 호출 여부
    @Published var showMessage: String = "" //Toast 팝업 메시지
    
    @Published var currentStep: Int = 1 //현재 등록 진행 단계
    
    @Published var isShowBLEModal: Bool = false //충전기 BLE 모달창 호출 여부
    @Published var chargerBLEList: [[String:String]] = []   //충전기 BLE 목록
    @Published var selectBLENumber: String = "" //선택 BLE 번호
    @Published var tempSelectBLENumber: String = "" //임시 선택 BLE 번호
    
    @Published var registChargerId: String = "" //등록 충전기 ID
    @Published var chargerName: String = "" //충전기 명
    @Published var chargerDescription: String = ""  //충전기 설명
    @Published var isShowAddressModal: Bool = false //주소 검색 모달창 호출 여부
    @Published var address: String = "" //주소
    @Published var detailAddress: String = ""   //상세 주소
    @Published var selectSharedType: String = "PARTIAL_SHARING" //선택 운영 여부
    @Published var selectCableFlag: Bool = true //선택 케이블 유무
    @Published var selectSupplyCapacity: String = "STANDARD"    //선택 충전 타입
    @Published var selectParkingFeeFlg: Bool = false    //선택 주차 요금 여부
    @Published var parkingFeeDescription: String = ""   //주차 요금 설명
    @Published var providerId: String = ""  //충전기 제공업체 ID
    
    //MARK: - Toast 메시지 팝어
    /// - Parameter message: 메시지(String)
    func toastMessage(message: String) {
        isShowToast = true  //Toast 팝업 호출 여부
        showMessage = message   //보여줄 메시지
    }
    
    //MARK: - 충전기 BLE 번호 목록 조회
    func getBLENumberList(getBleNumbers: [String]) {
        
        selectBLENumber = ""
        tempSelectBLENumber = ""
        chargerBLEList.removeAll()
        
        //조회된 BLE 번호를 등록 가능한 BLE 번호인지 API 조회를 통해 판별
        for bleNumber in getBleNumbers {
            let subBLENumber = bleNumber.components(separatedBy: [":"]).joined()    //':' 제거
            
            let parameters = [
                "bleNumber": subBLENumber,
                "page": "1",
                "size": "1",
                "sort": "DESC"
            ]
            
            //BLE 번호 조회 API
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
    
    //MARK: - 다음 단계 진행 확인
    func checkNextStep() {
        //1단계 진행 확인
        if currentStep == 1 {
            //BLE 번호 선택 확인
            if selectBLENumber != "" {
                currentStep += 1
            }
            else {
                toastMessage(message: "등록할 충전기 BLE 번호가 선택되지 않았습니다.\n충전기 검색 후, 등록할 충전기 BLE 번호를 선택 바랍니다.")
            }
        }
        //2단계 진행 확인
        else if currentStep == 2 {
            //충전기 명 입력 확인
            if !chargerName.trimmingCharacters(in: .whitespaces).isEmpty {
                currentStep += 1
            }
            else {
                toastMessage(message: "충전기 명을 입력하지 않았습니다.")
            }
        }
    }
    
    //MARK: - 등록 진행 단계(3단계 진행) 확인
    func checkRegistStep() -> Bool {
        //주소 입력 확인
        if !address.trimmingCharacters(in: .whitespaces).isEmpty {
            //상세 주소 입력 확인
            if !detailAddress.trimmingCharacters(in: .whitespaces).isEmpty {
                return true
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
    
    //MARK: - 충전기 등록 실행
    func registCharger(completion: @escaping (String) -> Void) {
        
        let ownerId: String = UserDefaults.standard.string(forKey: "userId")!
        
        let parameters: [String : Any] = [
            "name": chargerName, //충전기 명
            "chargerType": "BLE",   //충전기 유형
            "bleNumber": selectBLENumber,    //BLE 번호
            "description": chargerDescription,  //충전기 설명
            "address": address,  //주소
            "detailAddress": detailAddress,    //상세주소
            "gpsX": 0,  //X 좌표 - 기본값: 0
            "gpsY": 0,  //Y 좌표 - 기본값: 0
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
        
        //충전기 등록 API 호출
        let request = chargerAPI.requestAssignedCharger(chargerId: registChargerId, parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (result) in
                completion("success")
            },
            //API 호출 실패
            onFailure: { (error) in
                completion("error")
            }
        )
    }
}
