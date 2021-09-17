//
//  ChargerSearchViewModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/16.
//

import Foundation
import Combine

///충전기 검색 관련 View Model
class ChargerSearchViewModel: ObservableObject {
    private let chargerAPI = ChargerAPIService()  //충전기 API Service
    private let reservationAPI = ReservationAPIService()    //예약 API Service
    
    //MARK: - 검색조건 관련 변수
    //초기화 여부
    @Published var isReset: Bool = false {
        didSet {
            resetSearchCondition()  //검색조건 초기화 실행
        }
    }
    @Published var searchType: String = "Instant"   //충전 유형 - Instant: 즉시 충전, Scheduled: 예약충전
    @Published var selectTempStartDate: Date?   //선택한 임시 시작일자
    @Published var selectTempStartTime: String = "" //선택한 임시 시작시간
    @Published var chargingStartDate: Date? //충전 시작 일시
    @Published var chargingEndDate: Date?   //충전 종료 일시
    
    //MARK: - 현재 일시 변수
    //현재 일시
    @Published var currentDate: Date = Date() {
        didSet {
            formatCurrentDate(currentDate: currentDate) //현재 일시 String 형식 변환
        }
    }
    @Published var formatCurrentDay: String = ""    //현재 일자 - String
    @Published var formatCurrentHour: String = ""   //현재 시간 - String
    @Published var formatCurrentMinute: String = "" //현재 분 - String
    @Published var formatCurrentSecond: String = "" //현재 초 - String
    
    //MARK: - 텍스트 문구 변수
    @Published var textChargingTime: String = ""    //총 충전 시간 텍스트
    @Published var textStartDay: String = ""    //충전 시작 일자 텍스트
    @Published var textStartTime: String = ""   //충전 시작 시간 텍스트
    @Published var textEndDay: String = ""  //충전 종료 일자 텍스트
    @Published var textEndTime: String = "" //충전 종료 시간 텍스트
    
    //MARK: - Picker 표출 여부 변수
    @Published var showChargingDate: Bool = false   //충전 일시 선택 노출 여부
    @Published var showChargingTime: Bool = false   //충전 시간 선택 노출 여부
    @Published var showRadius: Bool = false //범위 선택 노출 여부
    
    //MARK: - Picker 변수
    //충전 유형 선택 - Instant: 즉시 충전, Schedule: 예약 충전
    @Published var selectChargeType: String = "Instant" {
        didSet {
            changeStartDate()   //충전 시작일자 변경
        }
    }
    //충전 시작일자 선택
    @Published var selectStartDate: Date = Date() {
        didSet {
            changeStartTimeRange()  //시작시간 선택 범위 변경
        }
    }
    //충전 시작시간 선택
    @Published var selectStartTime: String = "0000" {
        didSet {
            changePeriodText()  //충전 기간 텍스트 변경
        }
    }
    //충전 시간 선택 - 최대 10시간(초 단위)
    @Published var selectChargingTime: Int = 14400 {
        didSet {
            changeStartTimeRange()  //시작시간 선택 범위 변경
        }
    }
    @Published var startTimeMinRange: Int = 0   //시작시간 최소범위 - 0초
    @Published var startTimeMaxRange: Int = 86400   //시작시간 최대범위 - 23시 30분(초 단위)
    @Published var selectRadius: String = "3"   //반경범위 선택
    
    //MARK: - 현재 일시(서버 시간 기준) 조회
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
    
    //MARK: - 현재 일시 String 형식 변환
    /// Date 형식의 현재 일시를 String 형식으로 변환
    /// - Parameter currentDate: API 호출한 현재 일시
    func formatCurrentDate(currentDate: Date) {
        formatCurrentDay = "yyyyMMdd".dateFormatter(formatDate: currentDate)    //현재 일자
        formatCurrentHour = "HH".dateFormatter(formatDate: currentDate) //현재 시간
        formatCurrentMinute = "mm".dateFormatter(formatDate: currentDate)   //현재 분
        formatCurrentSecond = "ss".dateFormatter(formatDate: currentDate)   //현재 초
    }
    
    //MARK: - 충전 시작일자 변경
    /// 예약 충전인 경우 30분 단위이므로 현재 일시가 23시 30분 이후인 경우 다음 일자로 시작일자 변경
    func changeStartDate() {
        //예약 충전 선택인 경우 충전 시작일자 변경
        if selectChargeType == "Scheduled" {
            //현재 시간이 23시 30분 이후인 경우, 충전 시작일자 다음 날로 변경
            if Int(formatCurrentHour)! >= 23 {
                if Int(formatCurrentMinute)! >= 30 {
                    let stringTomorrow = formatCurrentDay + "000000" //yyyyMMdd000000 설정
                    let tomorrw = "yyyyMMddHHmmss".toDateFormatter(formatString: stringTomorrow)    //Date 형식으로 변경
                    
                    selectStartDate = Calendar.current.date(byAdding: .day, value: 1, to: tomorrw!)!    //충전 시작 일자 다음 날로 변경
                }
            }
            else {
                changePeriodText()  //충전 기간 텍스트 변경
            }
        }
        else {
            changePeriodText()  //충전 기가 텍스트 변경
        }
    }
    
    //MARK: - 충전 시간 텍스트 변경
    /// 충전 시간 선택에 따른 충전 시간 텍스트 변경
    func changeChargingTimeText() {
        let timeHour: Int = selectChargingTime / 3600    //시간 계산
        let timeMinute: Int = selectChargingTime % 3600 / 60   //분 계산
        var timeLabel: String = ""
        
        //시간이 0인 경우
        if timeHour == 0 {
            timeLabel = String(format: "%02d", timeMinute) + "분"
        }
        else {
            //0분인 경우
            if timeMinute == 0 {
                timeLabel = String(timeHour) + "시간"
            }
            else {
                timeLabel = String(timeHour) + "시간 " + String(format: "%02d", timeMinute) + "분"
            }
        }
        
        textChargingTime = timeLabel    //총 충전 시간 텍스트
    }
    
    //MARK: - 충전 기간 텍스트 변경
    /// 충전 시작일자, 시작시간 및 충전 시간에 따라 충전 기간 텍스트 변경
    func changePeriodText() {
        //충전 유형이 '즉시 충전'인 경우
        if selectChargeType == "Instant" {
            showChargingDate = false    //충전 시작일자 선택 비활성화
            
            //현재 시간 호출 후 선택한 충전 시간에 따라 충전 기간 계산 후 충전 기간 텍스트 변경
            getCurrentDate() { (currentDate) in
                self.currentDate = currentDate
                
                let calcDate: Date = Calendar.current.date(byAdding: .second, value: self.selectChargingTime, to: self.currentDate)!    //충전 종료 일시 계산
                
                //충전 시작 일자 + 시작 시간
                self.textStartDay = "MM/dd (E)".dateFormatter(formatDate: self.currentDate)
                self.textStartTime = "HH:mm".dateFormatter(formatDate: self.currentDate)
                //충전 종료 일자 + 종료 시간
                self.textEndDay = "MM/dd (E)".dateFormatter(formatDate: calcDate)
                self.textEndTime = "HH:mm".dateFormatter(formatDate: calcDate)
                
                self.chargingStartDate = self.currentDate   //충전 시작일시
                self.chargingEndDate = calcDate //충전 종료일시
            }
        }
        //충전 유형이 '예약 충전'인 경우 - 선택한 충전 시작일자, 시간, 충전 시간에 따라 충전 기간 계산 후 충전 기간 텍스트 변경
        else if selectChargeType == "Scheduled" {
            let formatStartDate: String = "yyyyMMdd".dateFormatter(formatDate: selectStartDate)
            let fullStartDate: String = formatStartDate + selectStartTime
            let startDate = "yyyyMMddHHmm".toDateFormatter(formatString: fullStartDate)!
            
            let calcDate: Date = Calendar.current.date(byAdding: .second, value: self.selectChargingTime, to: startDate)!   //충전 종료 일시 계산

            self.textStartDay = "MM/dd (E)".dateFormatter(formatDate: startDate)
            self.textStartTime = "HH:mm".dateFormatter(formatDate: startDate)
            self.textEndDay = "MM/dd (E)".dateFormatter(formatDate: calcDate)
            self.textEndTime = "HH:mm".dateFormatter(formatDate: calcDate)
            
            self.chargingStartDate = startDate  //충전 시작일시
            self.chargingEndDate = calcDate //충전 종료일시
        }
    }
    
    //MARK: 충전 시작시간 선택 범위 변경
    /// - 현재 일자 선택: 현재 시간 기준  이전 선택 불가 처리
    /// - 다음 일자 선택: 최대 선택 가능한 시간에서 선택한 충전 시간만큼 차감하여 선택 불가 처리
    func changeStartTimeRange() {
        //현재 일시 호출 후 실행
        getCurrentDate() { (currentDate) in
            //검색한 조건의 충전 유형이 '예약 충전'이 아닌 경우 현재 일시 반영
            if self.searchType != "Scheduled" {
                self.currentDate = currentDate
            }
            
            let currentDay = Int(self.formatCurrentDay)!    //현재 일자
            let currentHour = Int(self.formatCurrentHour)!  //현재 시간
            let currentMinute = Int(self.formatCurrentMinute)!  //현재 분
    
            let selectDay = Int("yyyyMMdd".dateFormatter(formatDate: self.selectStartDate))!    //선택 충전 시작일자
            
            let days = selectDay - currentDay   //선택한 충전 시작일자와 현재 일자의 일 수 계산
            
            //일 수 차이가 0인 경우
            if days == 0 {
                //30분 이전
                if currentMinute < 30 {
                    self.startTimeMinRange = 0 + (currentHour * 3600) + 1800    //30분(1800초) 추가
                }
                //59분 이전
                else if currentMinute <= 59 {
                    self.startTimeMinRange = 0 + (currentHour * 3600) + 3600    //1시간(3600초) 추가
                }
                
                let timeHour: Int = self.startTimeMinRange / 3600    //시간 계산
                let timeMinute: Int = self.startTimeMinRange % 3600 / 60   //분 계산

                let time: String = String(format: "%02d", timeHour) + String(format: "%02d", timeMinute)    //HHmm
                
                //검색한 조건의 충전 유형이 '예약 충전'이 아닌 경우 선택 시작시간 변경
                if self.searchType != "Scheduled" {
                    self.selectStartTime = time
                }
            }
            else {
                //일 수 차이가 1인 경우
                if days == 1 {
                    //23시 30분 이후
                    if currentHour >= 23 {
                        if currentMinute >= 30 {
                            self.startTimeMaxRange = 86400  //최대 선택 시간 - 23시 30분
                        }
                    }
                    //23시 30분 이전
                    else {
                        self.startTimeMaxRange = 86400 - self.selectChargingTime    //최대 선택 시간 - 선택한 충전 시간 차감
                    }
                }
                else {
                    self.startTimeMaxRange = 86400 - self.selectChargingTime    //최대 선택 시간 - 선택한 충전 시간 차감
                }
                
                //검색한 조건의 충전 유형이 '예약 충전'이 아닌 경우 선택 시작시간 변경
                if self.searchType != "Scheduled" {
                    self.selectStartTime = "0000"   //HHmm - 00분 00초
                }
            }
            
            self.changeChargingTimeText()   //충전 시간 텍스트 변경
            self.changePeriodText() //충전 기간 텍스트 변경
        }
    }
    
    //MARK: - 검색조건 설정
    ///선택한 검색조건 설정 저장 후 충전기 목록 검색 실행
    /// - Returns:
    ///   - startDate: 조회 시작일자
    ///   - endDate: 조회 종료일자
    ///   - radius: 조회 반경범위
    func setSearchCondition() -> (startDate: Date, endDate: Date, radius: String) {
        searchType = selectChargeType   //검색 유형 - 충전유형
        selectTempStartDate = selectStartDate   //충전 시작일자 임시 저장
        selectTempStartTime = selectStartTime   //충전 시작시간 임시 저장
        
        let searchStartDate: Date = chargingStartDate!  //검색 시작일자
        let searchEndDate: Date = chargingEndDate!  //검색 종료일자
        
        return (startDate: searchStartDate, endDate: searchEndDate, radius: selectRadius)
    }
    
    //MARK: - 검색조건 설정 초기화
    func resetSearchCondition() {
        showChargingDate = false    //충전 시작일시 선택 항목 닫기
        showChargingTime = false    //충전 시간 선택 항목 닫기
        showRadius = false  //반경범위 선택 항목 닫기
        
        //현재 일시 호출
        getCurrentDate() { (currentDate) in
            self.currentDate = currentDate  //현재 일시
            self.selectStartDate = currentDate  //선택 일자
        }
        
        selectChargeType = "Instant"    //충전 유형 - 즉시 충전
        selectChargingTime = 14400  //충전 시간 선택 - '4시간'으로 설정(초 단위 기준)
        selectRadius = "3"  //반경범위 - 3km
        selectTempStartDate = nil   //선택 시작일자 임시 저장 초기화
        selectTempStartTime = ""    //선택 시작시간 임시 저장 초기화
        
        searchType = selectChargeType   //검색 유형 초기화
        
        changeStartTimeRange()  //충전 시작시간 선택 범위 변경
    }
}
