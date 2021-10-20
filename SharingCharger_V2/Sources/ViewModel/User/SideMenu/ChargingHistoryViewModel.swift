//
//  ChargingHistoryViewModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/24.
//

import Foundation

///충전 이력 View Model
class ChargingHistoryViewModel: ObservableObject {
    private let chargeAPI = ChargeAPIService()  //충전 API Service
    private let reservationAPI = ReservationAPIService()    //예약 API Service
    
    @Published var history: [String:String] = [:]
    @Published var histories: [[String:String]] = []
    
    @Published var isSearch: Bool = false
    @Published var isReset: Bool = false
    @Published var isShowSearchModal: Bool = false
    @Published var isDirectlySelect: Bool = false
    
    @Published var currentDate: Date = Date()
    @Published var searchStartDate: Date = Date()
    @Published var searchEndDate: Date = Date()
    @Published var page: Int = 1
    @Published var size: Int = 10
    @Published var selectSort: String = "DESC"
    @Published var totalCount: Int = 0  //총 검색 개수
    @Published var totalPages: Int = 0
    @Published var searchPeriod: Int = -30
    @Published var selectPeriod: String = "oneMonth" {
        didSet {
            setSearchPeriod()   //검색 기간 설정
        }
    }
    
    //MARK: - 현재 일자 호출
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
    
    //MARK: - 검색 일자 설정
    func setSearchDate(endDate: Date) {
        let calcDate: Date = Calendar.current.date(byAdding: .day, value: searchPeriod, to: endDate)!
        
        searchStartDate = calcDate
        searchEndDate = endDate
    }
    
    //MARK: - 검색 기간 설정
    func setSearchPeriod() {
        isDirectlySelect = false
        
        //1개월
        if selectPeriod == "oneMonth" {
            searchPeriod = -30
        }
        //3개월
        else if selectPeriod == "threeMonths" {
            searchPeriod = -90
        }
        //6개월
        else if selectPeriod == "sixMonths" {
            searchPeriod = -180
        }
        //직접 선택
        else if selectPeriod == "directly" {
            isDirectlySelect = true
        }
        
        //직접 선택이 아닌 경우 현재 일자 호출 후 재설정
        if !isDirectlySelect {
            self.getCurrentDate() { currentDate in
                self.setSearchDate(endDate: currentDate)
            }
        }
    }
    
    //MARK: - 충전 이력 조회
    func getChargingHistory() {
        //조회 페이지가 1인 경우 실행
        if page == 1 {
            history.removeAll()
            histories.removeAll()
        }
        
        let userIdNo = UserDefaults.standard.string(forKey: "userIdNo")!    //사용자 ID 번호
        
        let parameters = [
            "startDate": "yyyy-MM-dd".dateFormatter(formatDate: searchStartDate),  //조회 시작일자
            "endDate": "yyyy-MM-dd".dateFormatter(formatDate: searchEndDate),  //조회 종료일자
            "page": String(page),   //페이지
            "size": String(size),   //한 페이지당 수
            "sort": selectSort    //정렬
        ]
        
        //충전 이력 조회 API
        let request = chargeAPI.requestChargeHistory(userIdNo: userIdNo, parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (chargingHistory) in
                self.isSearch = true    //검색 여부
                self.totalCount = chargingHistory.totalElements //총 개수
                self.totalPages = chargingHistory.totalPages    //총 페이지 수
                
                let histories = chargingHistory.content //충전 이력 목록 추출
                
                for history in histories {
                    
                    ///충전 일시 예외처리 및 포맷팅
                    let stringStartDate = history!.startRechargeDate ?? ""
                    let stringEndDate = history!.endRechargeDate ?? ""
                    
                    var startDate: Date?
                    var endDate: Date?
                    var formatStartDate = ""
                    var formatEndDate = ""
                    
                    if stringStartDate != "" {
                        startDate = "yyyy-MM-dd'T'HH:mm:ss".toDateFormatter(formatString: stringStartDate)  //충전 시작일시 Date 형식 변환
                        formatStartDate = "yyyy-MM-dd HH:mm".dateFormatter(formatDate: startDate!)  //충전 시작일시 String 형식 변환
                    }
                    
                    if stringEndDate != "" {
                        endDate = "yyyy-MM-dd'T'HH:mm:ss".toDateFormatter(formatString: stringEndDate)  //충전 종료일시 Date 형식 변환
                        formatEndDate = "yyyy-MM-dd HH:mm".dateFormatter(formatDate: endDate!)  //충전 시작일시 String 형식 변환
                    }
                
                    ///포인트 예외처리 및 포맷팅
                    var deductionPoint = "0".pointFormatter()   //실제 차감 포인트
                    var refundPoint = "0".pointFormatter()  //환불 포인트
                    
                    //차감 포인트가 0보다 큰 경우 '-' 기호 추가
                    if history!.rechargePoint ?? 0 > 0 {
                        deductionPoint = "-" + String(history!.rechargePoint!).pointFormatter()
                    }
                    
                    //환불 포인트가 0보다 큰 경우 '+' 기호 추가
                    if history!.refundPoint ?? 0 > 0 {
                        refundPoint = "+" + String(history!.refundPoint!).pointFormatter()
                    }
                    
                    self.history = [
                        "chargerName": history!.chargerName,    //충전기 명
                        "chargeId": String(history!.id),    //충전 ID
                        "startDate": formatStartDate,   //충전 시작일시
                        "endDate": formatEndDate,   //충전 종료일시
                        "prepaidPoint": String(history!.reservationPoint!).pointFormatter(),    //예약 차감 포인트
                        "deductionPoint": deductionPoint,   //충전 사용 포인트
                        "refundPoint": refundPoint  //환불 포인트
                    ]
                    
                    self.histories.append(self.history)
                }
            },
            //API 호출 실패
            onFailure: { (error) in
                print(error)
                
                //API 호출 실패 시, 초기화
                self.isSearch = false
                self.page = 1
                self.totalCount = 0
                self.totalPages = 0
                
                self.history.removeAll()
                self.histories.removeAll()
            }
        )
    }
    
    //MARK: - 초기화
    func reset() {
        isSearch = false    //검색 여부
        page = 1    //페이지 번호
        totalCount = 0  //총 개수
        totalPages = 0  //총 페이지 수
        selectPeriod = "oneMonth"   //검색 기간 선택 - 1개월
        selectSort = "DESC" //정렬 선택 - 최신순
    }
}
