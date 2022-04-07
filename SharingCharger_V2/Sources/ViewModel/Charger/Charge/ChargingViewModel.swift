//
//  ChargingViewModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/15.
//

import Foundation
import Combine
import CoreBluetooth
import EvzBLEKit

///충전 관련 View Model
class ChargingViewModel: NSObject, ObservableObject {
    private let chargeAPI = ChargeAPIService()  //충전 API Service
    private let reservationAPI = ReservationAPIService()    //예약 API Service
    
    //------------------------------
    //MARK: - [화면 관련 변수]
    //------------------------------
    @Published var isLoading: Bool = false  //로딩 화면 호출 여부
    @Published var isShowToast: Bool = false    //Toast 팝업 호출 여부
    @Published var showMessage: String = "" //Toast 팝업 메시지
    @Published var isShowChargingResult: Bool = false   //충전 결과 팝업 호출 여부
    
    //------------------------------
    //MARK: - [충전기 BLE 변수]
    //------------------------------
    @Published var bleScanList: Array<String> = [] //Bluetooth 스캔 목록
    @Published var bleTagList: [EvzBLETagData] = [] //Bluetooth 태그 목록
    
    //MARK: 충전기 검색 여부
    @Published var isSearch: Bool = false {
        didSet {
            postSearch() //충전 검색 후 실행
        }
    }
    
    //MARK: 충전기 연결 여부
    @Published var isConnect: Bool = false {
        didSet {
            postConnect()   //충전기 연결 후 실행
        }
    }
    
    @Published var isCharging: Bool = false  //충전 여부
    
    //MARK: 충전 시작 여부
    @Published var isChargingStart: Bool = false {
        didSet {
            startCharging() //충전 시작
        }
    }
    
    //MARK: 충전 종료 여부
    @Published var isChargingStop: Bool = false {
        didSet {
            endCharging()   //충전 종료 실행
        }
    }
    
    //MARK: 태그 세팅 여부
    @Published var isSetTag: Bool = false {
        didSet {
            postSetTag()   //태그 설정 후 실행
        }
    }
    
    //MARK: 태그 호출 여부
    @Published var isGetTag: Bool = false {
        didSet {
            postGetTag()   //태그 호출 후 실행
        }
    }
    
    //MARK: 태그 삭제 여부
    @Published var isDeleteTag: Bool = false {
        didSet {
            postDeleteTag() //태그 정보 삭제 후 실행
        }
    }
    
    //------------------------------
    //MARK: - [충전기 BLE 결과 변수]
    //------------------------------
    @Published var searchResult: String = ""    //충전기 검색 결과
    @Published var connectResult: String = ""   //충전기 연결 결과
    @Published var startResult: String = "" //충전 시작 결과
    @Published var stopResult: String = ""  //충전 종료 결과
    @Published var setTagResult: String = ""    //태그 설정 결과
    @Published var getTagResult: String = ""    //태그 호출 결과
    @Published var deleteTagResult: String = "" //태그 삭제 결과
    @Published var deleteTagId: String = "" //삭제 태그 ID
    
    //------------------------------
    //MARK: - [충전 정보 변수]
    //------------------------------
    @Published var userIdNo: String = ""    //사용자 ID 번호
    @Published var reservationId: String = ""   //예약 ID
    @Published var chargeId: String = ""    //충전 정보 ID
    @Published var chargerId: String = ""   //충전기 ID
    @Published var chargerName: String = "" //충전기 명
    @Published var bleNumber: String = ""   //충전기 BLE 번호
    @Published var chargerStatus: String = ""   //충전기 상태
    
    @Published var chargingTime: String = ""    //충전 시간
    @Published var reservationStartDate: Date?  //예약 시작일시
    @Published var reservationEndDate: Date?    //예약 종료일시
    @Published var chargingStartDate: Date = Date() //충전 시작일시
    @Published var chargingEndDate: Date = Date()   //충전 종료일시
    @Published var totalChargingTime: String = ""   //총 충전 시간
    
    @Published var prepaidPoint: Int = 0    //예약 차감 포인트
    @Published var deductionPoint: Int = 0  //차감 포인트
    @Published var refundPoint: Int = 0 //환불 포인트
    
    @Published var endType: String = "" //종료 유형
    
    @Published var isStartTimer: Bool = false   //타이머 시작 여부
    @Published var hoursRemaining: Int = 0    //타이머 시 시간 설정(기본값: 0)
    @Published var minutesRemaining: Int = 0    //타이머 분 시간 설정(기본값: 0)
    @Published var secondsRemaining: Int = 0    //타이머 초 시간 설정(기본값: 0)
    
    //MARK: - Toast 메시지 팝어
    /// - Parameter message: 메시지(String)
    func toastMessage(message: String) {
        isShowToast = true  //Toast 팝업 호출 여부
        showMessage = message   //보여줄 메시지
    }
    
    //------------------------------
    //MARK: - [Function - 블루투스]
    //------------------------------
    
    //MARK: 저장 프로퍼티 초기화
    override init() {
        super.init()
        
        initData()
    }
    
    //MARK: BLE Manager 사용 설정
    private func initData() {
        BleManager.shared.setBleDelegate(delegate: self)
    }
    
    //MARK: 블루투스 사용 권한 여부
    /// - Returns: 권한 유무(Boolean)
    func checkPermission() -> Bool {
        let permission = BleManager.shared.hasPermission()  //블루투스 사용 권한 확인
        
        return permission
    }
    
    //MARK: 블루투스 전원 ON/OFF 여부
    /// - Returns: 전원 상태(Boolean)
    func checkBluetoothPower() -> Bool {
        let isPowerOn = BleManager.shared.isOnBluetooth()   //블루투스 전원 확인
        
        return isPowerOn
    }
    
    //MARK: 블루투스 스캔 시작
    func startBluetoothScan() {
        BleManager.shared.bleScan() //블루투스 스캔 실행
    }
    
    //MARK: 블루투스 스캔 종료
    func stopBluetoothScan() {
        BleManager.shared.bleScanStop() //블루투스 스캔 종료 실행
    }
    
    
    //------------------------------
    //MARK: - [Function - 충전기 제어]
    //------------------------------
    
    //MARK: 충전기 BLE 검색 실행
    /// 블루투스 사용 권한과  블루투스 전원 상태 확인 후, 블루투스 검색 실행
    func searchChargerBLE() {
        isLoading = true
        
        //블루투스 사용 권한 확인 - 권한 있음
        if checkPermission() {
            
            //블루투스 전원 확인 - Power ON
            if checkBluetoothPower() {
                startBluetoothScan()    //블루투스 스캔 시작
            }
            //블루투스 전원 확인 - Power OFF
            else {
                isLoading = false
                toastMessage(message: "블루투스 전원이 꺼져 있습니다.\n블루투스 전원을 확인해주세요.")    //블루투스 전원 확인 메시지
            }
        }
        //블루투스 사용 권한 확인 - 권한 없음
        else {
            isLoading = false
            toastMessage(message: "블루투스 사용 권한이 없습니다.\n블루투스 권한 설정을 확인해주세요.") //블루투스 사용 권한 확인 메시지
        }
    }
    
    //MARK: 충전기 BLE 검색 후 실행
    /// 충전기 BLE 검색한 후, 검색 여부에 따라 기능 수행
    func postSearch() {
        isLoading = false   //로딩 화면 종료
        
        //충전기 BLE 검색된 경우
        if isSearch {
            toastMessage(message: "충전기 검색이 완료되었습니다.")   //충전기 BLE 검색 완료 메시지
        }
        //충전기 BLE 검색되지 않은 경우
        else {
            //충전기 BLE 검색 실패
            if searchResult == "fail" {
                toastMessage(message: "충전기 검색이 실패하였습니다.\n다시 시도 바랍니다.")   //충전기 BLE 검색 실패 메시지
            }
            //근처 충전기 BLE 비존재
            else if searchResult == "none" {
                toastMessage(message: "근처에 사용 가능한 충전기가 없습니다.\n충전기 근처로 이동 후 다시 시도 바랍니다.") //충전기 BLE 비존재 메시지
            }
        }
    }
    
    //MARK: 충전기 BLE 연결
    /// 검색한 충전기 BLE 목록에서 예약한 충전기 BLE 번호와 일치하는 충전기 BLE와 연결
    /// - Parameter bleNumber: BLE 번호(String)
    func connectChargerBLE(bleNumber: String) {
        isLoading = true

        let isOnList = bleScanList.contains(bleNumber)    //스캔한 BLE 목록 중 예약한 충전기 BLE 존재 유무 확인

        //일치하는 BLE 존재, 충전기 BLE 연결
        if isOnList {
            BleManager.shared.bleConnect(bleID: bleNumber)  //Bluetooth 연결
        }
        //일치하는 BLE 비존재, 메시지 출력
        else {
            isLoading = false   //로딩 종료
            isSearch = false    //충전기 BLE 검색 초기화
            toastMessage(message: "예약한 충전기와 일치하는 충전기가 없습니다.\n예약한 충전기의 위치를 확인 후 다시 시도 바랍니다.\n문제가 지속될 시, 고객 센터에 문의 바랍니다.")
        }
    }
    
    //MARK: 충전기 BLE 연결 후 실행
    /// 충전기 BEL 연결 후, 연결 여부에 따라 기능 수행
    func postConnect() {
        
        //충전기 연결 여부 - 연결
        if isConnect {
            getTag()    //태그 정보 호출
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                //충전기 BLE에 기존에 설정된 태그 정보가 없는 경우
                if !self.isGetTag && self.getTagResult == "" {
                    self.isLoading = false   //로딩 화면 종료
                    self.toastMessage(message: "충전기와 정상적으로 연결되었습니다.\n충전 시작을 진행할 수 있습니다.")
                }
            }
        }
        //충전기 연결 여부 - 비연결
        else {
            isLoading = false   //로딩 화면 종료
            
            //충전 중이지만 충전기와 연결되지 않은 경우
            if isCharging {
                isStartTimer = false    //타이머 정지
            }
            
            //연결 실패
            if connectResult == "fail" {
                toastMessage(message: "충전기와 연결이 실패하였습니다.\n다시 시도 바랍니다.\n문제가 지속될 시, 고객 센터에 문의 바랍니다.")
            }
            //비연결 상태
            else if connectResult == "notConnect" {
                toastMessage(message: "충전기와 연결이 되어있지 않습니다.\n충전기와 연결 후, 다시 시도 바랍니다.")
            }
            //연결 해제
            else if connectResult == "disconnect" {
                toastMessage(message: "충전기와 연결이 종료되었습니다.")
            }
            //OTP 오류
            else if connectResult == "createFail" || connectResult == "authFail" || connectResult == "authAgain" || connectResult == "accessFail" {
                toastMessage(message: "충전기와 연결 중에 인증 문제가 발생하였습니다.\n다시 시도 바랍니다.\n문제가 지속될 시, 고객 센터에 문의 바랍니다.")
            }
        }
    }
    
    //MARK: 충전기 BLE 연결 해제
    func disconnetChargerBLE() {
        BleManager.shared.bleDisConnect()   //블루투스 연결 해제 실행
    }
    
    //MARK: 충전 시작 요청
    /// 충전 시작 버튼 클릭 시, 충전기 사용 인증 API 호출 후 인증 여부에 따라 충전 시작 진행
    func requestStartCharging() {
        
        //충전기 사용 인증
        authChargerUse() { (result, currentDate)  in
            print("충전 시작 진행: 인증 시작")
            
            let chargingSeconds: String = self.setChargingTime(currentDate: currentDate)    //충전 시간 - 시간 단위
            let chargingMinutes: String = String(Int(chargingSeconds)! / 60)    //충전 시간 - 분 단위
            
            self.chargingTime = chargingSeconds //충전 시간
            
            //사용 인증 성공
            if result == "success" {
                BleManager.shared.bleChargerStart(useTime: chargingMinutes)    //충전기 BLE에 충전 시작 요청
                print("충전 시작 진행: 인증 성공")
            }
            else {
                self.isLoading = false  //로딩 화면 종료
                self.isConnect = false  //충전기 연결 해제
                self.connectResult = "" //충전기 연결 결과 초기화
                
                //사용 인증 실패
                if result == "fail" {
                    self.toastMessage(message: "충전을 위한 사용자 인증이 실패하였습니다.\n문제가 지속될 시, 고객 센터에 문의 바랍니다.")
                }
                else if result == "none" {
                    self.toastMessage(message: "일치하는 충전 예약이 없습니다.\n자세한 사항은 고객 센터에 문의 바랍니다.")
                }
                //서버 및 네트워크 오류
                else if result == "error" {
                    self.toastMessage(message: "server.error".message())
                }
                
                print("충전 시작 진행: 인증 실패")
            }
        }
    }
    
    //MARK: 충전 시작
    /// 충전기 BLE에 충전 시작 요청 후 응답 상태에 따라 충전 시작 정보 API 호출
    func startCharging() {
        
        //충전기 BLE - 충전 시작 성공
        if isChargingStart {
            print("충전 시작 진행: 시작 성공")
            //충전 시작 정보 호출
            getChargingStartInfo() { (result, chargeInfo) in
                print("충전 시작 진행: 충전 정보 호출")
                //충전 정보 호출 성공
                if result == "success" {
                    self.chargeId = String(format: "%013d", Int(chargeInfo["chargeId"]!)!)  //충전 정보 ID
                    UserDefaults.standard.set(self.chargeId, forKey: "chargeId")
                    
                    self.setTag(tagId: self.chargeId) //태그 정보 설정
                    print("충전 시작 진행: 충전 정보 호출 성공")
                }
                else {
                    self.isLoading = false  //로딩 화면 종료
                    self.endType = "startFailure"   //충전 종료 유형 - 충전 시작 실패
                    BleManager.shared.bleChargerStop()  //충전기 BLE에 충전 종료 요청
                    
                    //일치하는 충전 예약 정보 비존재
                    if result == "fail" {
                        self.toastMessage(message: "일치하는 충전 정보가 없습니다.\n자세한 사항은 고객 센터에 문의 바랍니다.")
                    }
                    //서버 및 네트워크 오류
                    else if result == "error" {
                        self.toastMessage(message: "server.error".message())
                    }
                    
                    print("충전 시작 진행: 충전 정보 호출 실패")
                }
            }
        }
        else {
            //충전기 BLE - 충전 시작 실패
            if startResult == "fail" {
                toastMessage(message: "충전 시작 진행에 실패하였습니다.\n다시 시도 바랍니다.\n문제가 지속될 시, 고객 센터에 문의 바랍니다.")
            }
            //충전기 BLE - 충전 시작 실패 : 플러그 비연결
            else if startResult == "unplug" {
                BleManager.shared.bleDisConnect()   //차후 문제 발생 여지로 블루투스 연결 해제 처리
                toastMessage(message: "충전기 플러그가 연결되지 않았습니다.\n플러그 연결 확인 후, 다시 시도 바랍니다.")
            }
            
            print("충전 시작 진행: 시작 실패")
        }
    }
    
    //MARK: 충전 종료 요청
    func requestEndCharging() {
        isLoading = true    //로딩 시작
        BleManager.shared.bleChargerStop()  //충전 종료 실행
    }
    
    //MARK: 충전 종료
    func endCharging() {
        print("충전 종료 진행: 충전 종료 시작")
        //충전기 BLE에 충전 종료 요청 성공
        if isChargingStop {
            getTag()    //태그 정보 호출
            print("충전 종료 진행: 충전 종료 요청 성공")
        }
        //충전기 BLE에 충전 종료 요청 실패
        else {
            if endType == "normal" {
                toastMessage(message: "충전 종료 진행에 실패하였습니다.\n다시 시도 바랍니다.\n문제가 지속될 시, 고객 센터에 문의 바랍니다.")
            }
            
            print("충전 종료 진행: 충전 종료 요청 실패")
        }
    }

    
    //------------------------------
    //MARK: - [Function - 태그 정보]
    //------------------------------
    
    //MARK: 태그 정보 설정
    /// 충전기 BLE의 태그 정보에 '충전 정보 ID'를 추가 설정
    /// - Parameter chargeId: 충전 정보 ID(String)
    func setTag(tagId: String) {
        BleManager.shared.bleSetTag(tag: tagId) //태그 정보 설정 실행
    }
    
    //MARK: 태그 정보 설정 후 실행
    /// 태그 정보 설정 후, 태그 정보 설정 성공 여부에 따라 기능 실행
    func postSetTag() {
        //태그 설정 성공
        if isSetTag {
            isLoading = false   //로딩 종료
            isCharging = true   //충전 상태 변경
            isStartTimer = true //타이머 시작
            
            toastMessage(message: "정상적으로 충전이 시작되었습니다.\n충전을 진행하는 동안 플러그를 분리하지 마세요.")
            print("충전 시작 진행: 충전 시작 완료")
        }
        //태그 설정 실패
        else {
            isConnect = false   //충전기 연결 해제
            connectResult = ""  //충전기 연결 결과 초기화
            isChargingStart = false //충전 시작 상태 초기화
        
            BleManager.shared.bleChargerStop()  //충전기 BLE에 충전 종료 요청
            
            toastMessage(message: "충전 시작 진행 중에 문제가 발생하였습니다.\n다시 시도 바랍니다.\n문제가 지속될 시, 고객 센터에 문의 바랍니다.")
            print("충전 시작 진행: 충전 시작 실패")
        }
    }
    
    //MARK: 태그 정보 호출
    func getTag() {
        BleManager.shared.bleGetTag()   //태그 정보 호출 실행
    }
    
    //MARK: 태그 정보 호출 후 실행
    /// 태그 정보 호출 후, 태그 정보 호출 여부에 따라
    func postGetTag() {
        //태그 정보 호출 성공
        if isGetTag {
            print("충전 종료 진행: 태그 정보 호출 성공")
            //충전기 태그 정보가 0개 이상인 경우
            if bleTagList.count > 0 {
                //충전기 BLE 태그 목록만큼 반복
                for tag: EvzBLETagData in bleTagList {
                    let tagId = tag.tagNumber   //태그 ID
                    let tagChargingTime = tag.useTime   //충전 시간 태그 - 분 단위
                    let tagChargingkWh = tag.kwh    //충전 kWh 태그
                    
                    let tagInfo: [String:Any] = [
                        "tagId": Int(tagId)!,
                        "chargingTime": Int(tagChargingTime)!,
                        "chargingkWh": Double(tagChargingkWh)!
                    ]
                    
                    //충전 중인 상태
                    if isCharging {
                        //충전 종료한 경우
                        if isChargingStop {
                            //충전 정보와 태그 정보가 일치할 경우 충전 정상 종료 처리
                            if chargeId == tagId {
                                self.endType = "normal" //충전 종료 유형 - 정상 종료
                                
                                //충전 정상 종료 API 호출
                                putChargingEndInfo(tagInfo: tagInfo) { (result, endInfo) in
                                    print("충전 종료 진행: 충전 종료 정보 호출")
                                    
                                    //충전 종료 성공
                                    if result == "success" {
                                        let reservationStartDate = endInfo["reservationStartDate"]! //예약 시작일시 추출
                                        let reservationEndDate = endInfo["reservationEndDate"]! //예약 종료일시 추출
                                        let chargingStartDate = endInfo["chargingStartDate"]!   //충전 시작일시 추출
                                        let chargingEndDate = endInfo["chargingEndDate"]!   //충전 종료일시 추출
                                        
                                        self.reservationStartDate = "yyyy-MM-dd HH:mm:ss".toDateFormatter(formatString: reservationStartDate)  //예약 시작 일시
                                        self.reservationEndDate = "yyyy-MM-dd HH:mm:ss".toDateFormatter(formatString: reservationEndDate)  //예약 종료일시
                                        self.chargingStartDate = "yyyy-MM-dd HH:mm:ss".toDateFormatter(formatString: chargingStartDate)!   //충전 시작일시
                                        self.chargingEndDate = "yyyy-MM-dd HH:mm:ss".toDateFormatter(formatString: chargingEndDate)!   //충전 종료일시
                                        
                                        self.prepaidPoint = Int(endInfo["prepaidPoint"]!)!  //선불 차감 포인트
                                        self.deductionPoint = Int(endInfo["deductionPoint"]!)!  //차감 포인트
                                        self.refundPoint = Int(endInfo["refundPoint"]!)!    //환불 포인트
                                        
                                        let totalTime: Int = Int(self.chargingEndDate.timeIntervalSince(self.chargingStartDate))    //총 충전 시간
                                        let chargingHour = Int(totalTime / (60 * 60))   //충전 시간 시 단위
                                        let chargingMinute = (totalTime - (chargingHour * 60 * 60)) / 60   //충전 시간 분 단위
                                        
                                        self.totalChargingTime = "\(String(format: "%02d", chargingHour)):\(String(format: "%02d", chargingMinute))"    //총 충전 시간
                                        
                                        self.deleteTag(chargeId: tagId) //해당 충전 정보의 태그 정보 삭제
                                        
                                        print("충전 종료 진행: 충전 종료 정보 호출 성공")
                                    }
                                    //충전 종료 실패
                                    else {
                                        self.isLoading = false  //로딩 종료
                                        self.isChargingStop = false //충잔 종료 여부
                                        
                                        if result == "fail" {
                                            self.toastMessage(message: "충전 종료 진행에 실패하였습니다.\n다시 시도 바랍니다.\n문제가 지속될 시, 고객 센터에 문의 바랍니다.")
                                        }
                                        else if result == "error" {
                                            self.toastMessage(message: "server.error".message())
                                        }
                                        
                                        print("충전 종료 진행: 충전 종료 정보 호출 실패")
                                    }
                                }
                            }
                        }
                        //충전 종료 상태가 아닌 경우
                        else {
                            self.isLoading = false  //로딩 종료
                            
                            //현재 시간 조회 후 타이머 세팅
                            self.getCurrentDate() { (currentDate) in
                                self.chargingTime = self.setChargingTime(currentDate: currentDate)  //충전 시간
                                self.isStartTimer = true    //타이머 시작
                            }
                            
                            toastMessage(message: "충전기와 정상적으로 연결되었습니다.")
                        }
                    }
                    //충전 중이 아닌 상태
                    else if !isCharging {
                        //충전 정보와 태그 정보가 불일치할 경우 충전 비정상 종료 처리
                        if chargeId != tagId {
                            //충전 비정상 종료 API 호출
                            putChargingAbnormalEndInfo(tagInfo: tagInfo) { (result) in
                                
                                self.endType = "abnormal"   //충전 종료 유형 - 비정상 종료
                                
                                //충전 비정상 종료 성공
                                if result == "success" {
                                    self.deleteTag(chargeId: tagId) //기존 충전 정보의 태그 정보 삭제
                                }
                                else {
                                    self.isLoading = false  //로딩 종료
                                    self.isConnect = false  //충전기 연결 초기화
                                    self.connectResult = "" //충전기 연결 결과 초기화
                                    
                                    //충전 비정상 종료 실해
                                    if result == "fail" {
                                        self.toastMessage(message: "충전기 설정 진행 중에 문제가 발생하였습니다.\n다시 시도 바랍니다.\n문제가 지속될 시, 고객 센터에 문의 바랍니다.")
                                    }
                                    //충전 비정상 종료 오류
                                    else if result == "error" {
                                        self.toastMessage(message: "server.error".message())
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        //태그 정보 호출 실패
        else {
            isConnect = false   //충전기 연결 초기화
            self.connectResult = "" //충전기 연결 결과 초기화
            
            toastMessage(message: "충전기 설정 진행 중에 문제가 발생하였습니다.\n다시 시도 바랍니다.\n문제가 지속될 시, 고객 센터에 문의 바랍니다.")
        }
    }
    
    //MARK: 태그 정보 삭제
    /// - Parameter chargeId: 충전 정보 ID
    func deleteTag(chargeId: String) {
        deleteTagId = chargeId  //삭제할 태그 정보 ID
        BleManager.shared.bleDeleteTargetTag(tag: chargeId) //충전기 BLEdp 태그 삭제 요청
    }
    
    //MARK: 태그 정보 삭제 후 실행
    func postDeleteTag() {
        //태그 정보 삭제 성공
        if isDeleteTag {
            print("충전 종료 진행: 태그 정보 삭제 성공")
            bleTagList.remove(at: bleTagList.firstIndex(where: { $0.tagNumber == deleteTagId})!)    //호출한 태그 목록에서 삭제된 태그 정보 삭제
            
            //태그 목록이 0인 경우
            if bleTagList.count == 0 {
                isLoading = false   //로딩 종료
                getTagResult = ""   //태그 정보 호출 결과 초기화
                
                //충전 종료 상태가 아닌 경우
                if !isChargingStop {
                    toastMessage(message: "충전기와 정상적으로 연결되었습니다.\n충전 시작을 진행할 수 있습니다.")
                }
                //충전 종료 상태인 경우
                else {
                    isStartTimer = false    //충전 타이머 종료
                    disconnetChargerBLE()   //충전기 BLE 연결 해제
                    isShowChargingResult = true //충전 결과 팝업 창 호출
                    
                    print("충전 종료 진행: 충전 종료 완료")
                }
            }
        }
        //태그 정보 삭제 실패
        else {
            getTag()    //태그 정보 재호출
            print("충전 종료 진행: 태그 정보 삭제 실패")
        }
    }
    
    
    //------------------------------
    //MARK: - [Function - 충전 관련]
    //------------------------------
    
    //MARK: 현재 일시(서버 시간 기준) 조회
    func getCurrentDate(completion: @escaping (Date) -> Void) {
        //현재 일시 API 호출
        let request = reservationAPI.requestCurrentDate()
        request.execute(
            //API 호출 성공
            onSuccess: { (currentDate) in
                let formatDate = "yyyy-MM-dd HH:mm:ss".toDateFormatter(formatString: currentDate)!
                completion(formatDate)
            },
            //API 호출 실패
            onFailure: { (error) in
                completion(Date())
            }
        )
    }
    
    //MARK: 충전 시간 설정
    /// 충전 시간 = 충전 예약 종료일시 - 실제 충전 시작 일시
    /// - Parameter currentDate: 실제 충전 시작 일시(= 현재 일시)
    /// - Returns: 충전 시간(String)
    func setChargingTime(currentDate: Date) -> String {
        let startDate: Date = currentDate   //충전 시작일시
        let endDate: Date = reservationEndDate! //예약 종료일시
        
        let chargingTime: Int = Int(endDate.timeIntervalSince(startDate))   //충전 시간 - Integer
        
        return String(chargingTime)
    }
    
    //MARK: 충전 타이머
    /// 충전 시작일시부터 충전 예약 종료일시까지의 남은 충전 시간  타이머 실행
    func chargingTimer() {
        let chargingTime = Int(self.chargingTime)!  //충전 시간
        
        let hours = chargingTime / (60 * 60)    //시간
        let minutes = (chargingTime - (hours * (60 * 60))) / 60 //분
        let seconds = chargingTime - (hours * (60 * 60)) - (minutes * 60)   //초
        
        hoursRemaining = hours  //남은 시간
        minutesRemaining = minutes  //남은 분
        secondsRemaining = seconds  //남은 초
        
        self.chargingTime = String(chargingTime - 1)    //충전 시간 1초씩 감소
    }
    
    //MARK: 충전기 사용 인증
    /// 해당 충전기의 사용이 가능한지 충전기 사용 인증 API 호출
    /// - Parameter completion:
    ///   - result: 충전기 사용 인증 API 호출 결과
    ///   - startDate: 충전 시작일시
    func authChargerUse(completion: @escaping (_ result: String, _ startDate: Date) -> Void) {

        //현재 시간 호출 - 서버 시간 기준
        getCurrentDate() { (currentDate) in
            self.chargingStartDate = currentDate    //충전 시작일시 - 현재 시간으로 설정
            UserDefaults.standard.set(self.chargingStartDate, forKey: "chargingStartDate")  //충전 시작일시 사용자 정보에 저장
            let chargingStartDate = "yyyy-MM-dd'T'HH:mm:ss.sss'Z'".dateFormatter(formatDate: self.chargingStartDate)    //충전 시작일시 String 형식으로 변경

            let parameters: [String:Any] = [
                "userId": Int(self.userIdNo)!,  //사용자 ID번호
                "reservationId": Int(self.reservationId)!,  //예약 ID번호
                "rechargeStartDate": chargingStartDate    //충전 시작일시
            ]
            
            //충전기 사용 인증 API 호출
            let request = self.chargeAPI.requestChargerUseAuth(chargerId: self.chargerId, parameters: parameters)
            request.execute(
                //API 호출 성공
                onSuccess: { (auth) in
                    //사용 가능
                    if auth == "true" {
                        completion("success", currentDate)
                    }
                    //사용 불가능
                    else {
                        completion("none", currentDate)
                    }
                },
                //API 호출 실패
                onFailure: { (error) in
                    switch error {
                    case .responseSerializationFailed:
                        completion("fail", currentDate)
                    //일시적인 서버 오류 및 네트워크 오류
                    default:
                        completion("error", currentDate)
                        break
                    }
                }
            )
        }
    }
    
    //MARK: 충전 시작 정보 호출
    /// 충전 시작 시, 충전 정보 API 호출
    /// - Parameter completion:
    ///   - result: 충전 시작 정보 API 호출 결과
    ///   - chargeInfo: 충전 정보
    func getChargingStartInfo(completion: @escaping (_ result: String, _ chargeInfo: [String:String]) -> Void) {
        
        var chargeInfo: [String:String] = [:]   //충전 정보
        
        //Parameters
        let parameters: [String:Any] = [
            "userId": Int(self.userIdNo)!,  //사용자 ID번호
            "reservationId": Int(self.reservationId)!,  //예약 ID번호
            "rechargeStartDate": "yyyy-MM-dd'T'HH:mm:ss.sss'Z'".dateFormatter(formatDate: chargingStartDate)    //충전 시작일시
        ]
    
        //충전 시작 API 호출
        let request = self.chargeAPI.requestChargeStart(chargerId: self.chargerId, parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (startInfo) in
                chargeInfo.updateValue(String(startInfo.id), forKey: "chargeId")    //충전 ID
                chargeInfo.updateValue(String(startInfo.chargerId), forKey: "chargerId")    //충전기 ID
                chargeInfo.updateValue(startInfo.chargerName!, forKey: "chargerName")   //충전기 명
                chargeInfo.updateValue(startInfo.reservationStartDate!, forKey: "reservationStartDate") //예약 시작일시
                chargeInfo.updateValue(startInfo.reservationEndDate!, forKey: "reservationEndDate") //예약 종료일시
                chargeInfo.updateValue(startInfo.startRechargeDate!, forKey: "chargingStartDate")   //충전 시작일시
                
                completion("success", chargeInfo)
            },
            //API 호출 실패
            onFailure: { (error) in
                switch error {
                case .responseSerializationFailed:
                    completion("fail", chargeInfo)
                //일시적인 서버 오류 및 네트워크 오류
                default:
                    completion("error", chargeInfo)
                    break
                }
            }
        )
    }
    
    //MARK: 충전 정상 종료 처리 호출
    /// 충전 정상 종료 시, 충전 정상 종료 API 호출
    /// - Parameters:
    ///   - tagInfo: 충전기 BLE에서 충전 종료 요청 후, 호출한 태그 정보
    ///   - completion:
    ///     - result:  API 호출 결과
    ///     - chargeInfo: 충전 정보
    func putChargingEndInfo(tagInfo: [String:Any], completion: @escaping (_ result: String, _ chargeInfo: [String:String]) -> Void) {
        
        var chargeInfo: [String:String] = [:]   //충전 정보
        
        let parameters: [String:Any] = [
            "rechargeId": tagInfo["tagId"]!,    //태그 ID
            "rechargeMinute": tagInfo["chargingTime"]!, //충전기 사용 시간
            "rechargeKwh": tagInfo["chargingkWh"]!  //충전 kWh
        ]
        
        let request = self.chargeAPI.requestChargeEnd(chargerId: self.chargerId, parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (endInfo) in
                chargeInfo.updateValue(String(endInfo.id), forKey: "chargeId")    //충전 ID
                chargeInfo.updateValue(String(endInfo.chargerId), forKey: "chargerId")    //충전기 ID
                chargeInfo.updateValue(endInfo.chargerName!, forKey: "chargerName")   //충전기 명
                chargeInfo.updateValue(endInfo.reservationStartDate!, forKey: "reservationStartDate") //예약 시작일시
                chargeInfo.updateValue(endInfo.reservationEndDate!, forKey: "reservationEndDate") //예약 종료일시
                chargeInfo.updateValue(endInfo.startRechargeDate!, forKey: "chargingStartDate")   //충전 시작일시
                chargeInfo.updateValue(endInfo.endRechargeDate!, forKey: "chargingEndDate")   //충전 시작일시
                chargeInfo.updateValue(String(endInfo.reservationPoint ?? 0), forKey: "prepaidPoint")   //선불 차감 포인트
                chargeInfo.updateValue(String(endInfo.rechargePoint ?? 0), forKey: "deductionPoint")    //차감 포인트
                chargeInfo.updateValue(String(endInfo.refundPoint ?? 0), forKey: "refundPoint") //환불 포인트
                
                completion("success", chargeInfo)
            },
            //API 호출 실패
            onFailure: { (error) in
                switch error {
                case .responseSerializationFailed:
                    completion("fail", [:])
                //일시적인 서버 오류 및 네트워크 오류
                default:
                    completion("error", [:])
                    break
                }
            }
        )
    }
    
    //MARK: 충전 비정상 종료 처리 호출
    /// 충전 비정상 종료 시, 충전 비정상 종료 API 호출
    /// - Parameters:
    ///   - tagInfo: 충전기 BLE에서 충전 종료 요청 후, 호출한 태그 정보
    ///   - completion:
    ///     - result:  API 호출 결과
    func putChargingAbnormalEndInfo(tagInfo: [String:Any], completion: @escaping (_ result: String) -> Void) {
        
        let parameters: [String:Any] = [
            "rechargeId": tagInfo["tagId"]!,    //태그 ID
            "rechargeMinute": tagInfo["chargingTime"]!, //충전기 사용 시간
            "rechargeKwh": tagInfo["chargingkWh"]!  //충전 kWh
        ]
        
        let request = self.chargeAPI.requestChargeAbnormalEnd(chargerId: self.chargerId, parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (endInfo) in
                completion("success")
            },
            //API 호출 실패
            onFailure: { (error) in
                switch error {
                case .responseSerializationFailed:
                    completion("fail")
                //일시적인 서버 오류 및 네트워크 오류
                default:
                    completion("error")
                    break
                }
            }
        )
    }
}

//MARK: - BLE Delegate
extension ChargingViewModel: BleDelegate {
    func bleResult(code: BleResultCode, result: Any?) {
        switch code {
            //MARK: Bluetooth 권한
            case .BleAuthorized:    //블루투스 권한 있음
                print("Bluetooth Autorized.")
                break
                
            case .BleUnAuthorized:  //블루투스 권한 없음
                print("No Bluetooth Autorized.")
                break
                
            //MARK: Bluetooth 전원
            case .BleOff:   //블루투스 전원 OFF
                print("Bluetooth Power OFF.")
                break
                
            //MARK: Bluetooth 지원
            case .BleUnSupport: //블루투스 지원 안함
                print("Bluetooth Not Supported.")
                break
                
            //MARK: Bluetooth 스캔
            case .BleScan:  //블루투스 스캔 시작
                print("Bluetooth Scan Start.")
        
                //BLE 목록
                if let scanData = result as? [String] {
                    bleScanList = scanData  //BLE 스캔 목록
                    isSearch = true //충전기 BLE 검색 여부
                    searchResult = "success"    //충전기 BLE 검색 결과 - 성공
                    
                    //BLE 번호
                    for bleNumber: String in self.bleScanList {
                        print("Bluetooth Number: \(bleNumber)")
                    }
                }
                break
                
            case .BleScanFail:  //블루투스 스캔 실패
                isSearch = false    //충전기 BLE 검색 여부
                searchResult = "fail"   //충전기 BLE 검색 결과 - 실패
                
                print("Bluetooth Scan Failed.")
                break
                
            case .BleNotScanList:   //주변에 블루투스 없음
                isSearch = false    //충전기 BLE 검색 여부
                searchResult = "none"   //충전기 BLE 검색 결과 - 없음
                
                print("No Bluetooth Scan List.")
                break
                
            //MARK: Bluetooth 연결
            case .BleConnect:   //블르투스 연결 성공
                guard let bleNumber = result as? String else {
                    return
                }
                
                isConnect = true    //BLE 연결 여부
                connectResult = "connect"   //BLE 연결 결과 - 연결
                
                print("Bluetooth Connection. BLE Number: \(bleNumber).")
                break
                
            case .BleConnectFail:   //블루투스 연결 실패
                isConnect = false   //BLE 연결 여부
                connectResult = "fail"  //BLE 연결 결과 - 실패
                
                print("Bluetooth Connection Failed.")
                break
            
            //MARK: Bluetooth 연결 해제
            case .BleDisconnect:
                isConnect = false   //BLE 연결 여부
                connectResult = "disconnect"    //BLE 연결 결과 - 연결 해제
                
                print("Bluetooth Disconnection.")
                break

            //MARK: Bluetooth 오류
            case .BleNotConnect:    //블루투스 비연결
                isConnect = false   //BLE 연결 여부
                connectResult = "notConnect"    //BLE 연결 결과 - 비연결 상태
                
                print("Bluetooth Not Connected")
                break
                
            case .BleUnknownError:  //알 수 없는 오류
                isConnect = false   //BLE 연결 여부
                connectResult = "error" //BLE 연결 결과 - 오류
                
                print("Unknown Error.")
                break
                
                
            //MARK: 충전 시작
            case .BleChargeStart:   //충전 시작 성공
                isChargingStart = true  //충전 시작 여부
                startResult = "start"   //충전 시작 결과 - 시작
                
                print("Charging Start Success.")
                break
                
            case .BleChargeStartFail:   //충전 시작 실패
                isChargingStart = false //충전 시작 여부
                startResult = "fail"    //충전 시작 결과 - 실패
                
                print("Charging Start Failed.")
                break
                
            case .BleUnPlug:    //충전 시작 실패 - 플러그 비연결
                isChargingStart = false //충전 시작 여부
                startResult = "unplug"  //충전 시작 결과 - 플러그 비연겨
                
                print("Charging Start Failed. Reason: Charger Unplug.")
                break
                
            //MARK: 충전 종료
            case .BleChargeStop:    //충전 종료 성공
                isChargingStop = true   //충전 종료 여부
                stopResult = "stop" //충전 종료 결과 - 종료
                
                print("Charging Stop Success.")
                break
                
            case .BleChargeStopFail:    //충전 종료 실패
                isChargingStop = false  //충전 종료 여부
                stopResult = "fail" //충전 종료 결과 - 실패
                
                print("Charging Stop Failed.")
                break
            
            //MARK: Tag 정보 설정
            case .BleSetTag:    //태그 설정 성공
                isSetTag = true //태그 정보 설졍 여부
                setTagResult = "success"    //태그 정보 설정 결과 - 성공
                
                print("Tag Setting Success.")
                break
                
            case .BleSetTagFail:    //태그 설정 실패
                isSetTag = false    //태그 정보 설정 여부
                setTagResult = "fail"   //태그 정보 설정 결과 - 실패
                
                print("Tag Setting Failed.")
                break
                
            case .BleWrongTagLength:    //태그 길이 초과 - 13자 이상
                isSetTag = false    //태그 정보 설정 여부
                setTagResult = "wrongLength"    //태그 정보 설정 결과 - 잘못된 태그 길이
                
                print("Tag Length Wrong. Reason: More than 13 Characters.")
                break
                
            //MARK: Tag 정보 호출
            case .BleGetTag:    //태그 정보 호출 성공
                print("Tag Information Call Success.")
                
                //태그 정보 목록
                if let tags = result as? [EvzBLETagData] {
                    bleTagList = tags   //태그 목록
                    isGetTag = true //태그 정보 호출 여부
                    getTagResult = "success"    //태그 정보 호출 결과 - 성공
                    
                    //태그 정보
                    for tag: EvzBLETagData in bleTagList {
                        print("Tag Data: \(tag.toString())")
                    }
                }
                
                break
                
            case .BleGetTagFail:    //태그 정보 호출 실패
                isGetTag = false    //태그 정보 호출 여부
                getTagResult = "fail"   //태그 정보 호출 결과 - 실패
                
                print("Tag Information Call Failed.")
                break
            
            //MARK: Tag 정보 삭제
            case .BleAllDeleteTag:  //태그 전체 삭제
                isDeleteTag = true  //태그 전체 삭제 여부
                deleteTagResult = "allSuccess"  //태그 전체 삭제 결과 - 전체 삭제 성공
                
                print("Delete All Tags Success.")
                break
                
            case .BleAllDeleteTagFail:  //태그 전체 삭제 실패
                isDeleteTag = false //태그 전체 삭제 여부
                deleteTagResult = "fail"    //태그 전체 삭제 결과 - 실패
                
                print("Delete All Tags Failed.")
                break
                
            case .BleDeleteTag: //태그 삭제
                isDeleteTag = true  //태그 정보 삭제 여부
                deleteTagResult = "success" //태그 정보 삭제 결과 - 성공
                
                print("Delete Tag Success.")
                break
                
            case .BleDeleteTagFail: //태그 삭제 실패
                isDeleteTag = false //태그 정보 삭제 여부
                deleteTagResult = "fail"    //태그 정보 삭제 결과 - 실패
                
                print("Delete Tag Failed.")
                break
                
            //MARK: OTP 인증
            case .BleOtpCreateFail: //OTP 생성 실패
                isConnect = false   //BLE 연결 해제
                connectResult = "createFail"    //BLE 연결 결과 - OTP 생성 실패
                
                print("OTP Creation Failed.")
                break
                
            case .BleOtpAuthFail:   //OTP 인증 실패
                isConnect = false   //BLE 연결 해제
                connectResult = "authFail"  //BLE 연결 결과 - OTP 인증 실패
                
                print("OTP Authentication Failed.")
                break
                
            case .BleAgainOtpAtuh:  //OTP 인증 재시도
                isConnect = false   //BLE 연결 해제
                connectResult = "authAgain" //BLE 연결 결과 - OTP 인증 재시도
                
                print("Charging Start Failed. Reason: OTP Authentication Again.")
                break
                
            case .BleAccessServiceFail: //서비스 인증정보 접근 실패
                isConnect = false   //BLE 연결 해제
                connectResult = "accessFail"    //BLE 연결 결과 - 서비스 접근 실패
                
                print("Service Access Failed.")
                break
                
            default:
                break
        }
    }
}
