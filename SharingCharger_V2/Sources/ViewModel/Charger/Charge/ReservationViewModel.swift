//
//  ReservationViewModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/13.
//

import Foundation
import Combine

///예약 View Model
class ReservationViewModel: ObservableObject {
    private let reservationAPI = ReservationAPIService()    //예약 API Service
    private let pointAPI = PointAPIService()  //포인트 API Service
    
    @Published var viewUtil = ViewUtil() //View Util
    
    @Published var isShowChargingAlert: Bool = false    //충전 진행 알림창 호출 여부
    @Published var isShowConfirmAlert: Bool = false //예약 확인 알림창 호출 여부
    @Published var isShowCancelAlert: Bool = false  //예약 취소 알림창 호출 여부
    
    @Published var userIdNo: String = ""    //사용자 ID 번호
    @Published var isUserReservation: Bool = false  //사용자 예약 여부
    @Published var isReservable: Bool = false   //예약 가능 여부
    @Published var isReservationResult: Bool = false
    
    @Published var reservationId: String = ""   //예약 ID 번호
    @Published var reservationType: String = ""  //충전 예약 유형
    @Published var reservedChargerId: String = ""  //예약 충전기 번호
    @Published var reservedChargerName: String = ""     //예약 충전기 명
    @Published var reservedchargerBLENumber: String = ""    //예약 충전기 BLE 번호
    @Published var chargerLatitude: Double? //충전기 위도(Y좌표)
    @Published var chargerLongitude: Double?    //충전기 경도(X좌표)
    @Published var reservationStartDate: Date?  //예약 시작일시
    @Published var reservationEndDate: Date?    //예약 종료일시
    @Published var reservationStatus: String = ""   //예약 상태
    
    @Published var textChargingTime: String = ""    //총 충전 시간 텍스트
    @Published var textStartDay: String = ""    //충전 시작 일자 텍스트
    @Published var textStartTime: String = ""   //충전 시작 시간 텍스트
    @Published var textEndDay: String = ""  //충전 종료 일자 텍스트
    @Published var textEndTime: String = "" //충전 종료 시간 텍스트
    @Published var textExpectedPoint: String = ""   //예상 차감포인트 텍스트
    @Published var textReservationStatus: String = ""   //예약 상태 텍스트
    @Published var textReservationDate: String = "" //예약 일자 텍스트
    @Published var textUserPoint: String = ""   //사용자 보유 포인트 텍스트
    @Published var textRemainingPoint: String = ""  //예약 후 잔여 포인트
    @Published var textNeedPoint: String = ""   //필요 포인트(부족 포인트) 텍스트
    
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
    
    //MARK: - 사용자의 현재 예약 정보 조회
    func getUserReservation() {
        //사용자의 충전기 예약 정보 호출
        let request = reservationAPI.requesUserReservation(userIdNo: userIdNo)
        request.execute(
            //API 호출 성공
            onSuccess: { (reservation) in
                let formatStartDate = "yyyy-MM-dd'T'HH:mm:ss".toDateFormatter(formatString: reservation.startDate!) //예약 시작일시 - Date 형식으로 변환
                let formatEndDate = "yyyy-MM-dd'T'HH:mm:ss".toDateFormatter(formatString: reservation.endDate!) //예약 종료일시 - Date 형식으로 변환

                self.getCurrentDate() { (currentDate) in
                    //현재 일시가 예약 종료 일시를 지나지 않은 경우에만 사용자 예약 정보 노출
                    if currentDate < formatEndDate! {
                        self.isUserReservation = true   //사용자 예약 여부
                        
                        self.reservationId = String(reservation.id) //예약 ID
                        self.reservedChargerId = String(reservation.chargerId)  //예약 충전기 ID
                        self.reservedChargerName = reservation.chargerName!  //예약 충전기 명
                        self.reservedchargerBLENumber = reservation.bleNumber!  //예약 충전기 BLE 번호
                        self.chargerLatitude = reservation.gpxY //충전기 위도
                        self.chargerLongitude = reservation.gpsX    //충전기 경도
                        
                        self.reservationStartDate = formatStartDate //예약 시작일시
                        self.reservationEndDate = formatEndDate //예약 종료일시
                        self.reservationStatus = reservation.state! //예약 상태
                        
                        self.setReservationInfo()   //예약 정보 텍스트 설정
                        self.textExpectedPoint = String(reservation.expectPoint!)   //예상 차감 포인트 텍스트
                    }
                    else {
                        self.isUserReservation = false
                    }
                }
            },
            //API 호출 실패
            onFailure: { (error) in
                switch error {
                case .responseSerializationFailed:
                    self.isUserReservation = false  //사용자 예약 여부
                //일시적인 서버 오류 및 네트워크 오류
                default:
                    self.viewUtil.showToast(isShow: true, message: "server.error".message())
                    break
                }
            }
        )
    }
    
    //MARK: - 예약 정보 텍스트 설정
    func setReservationInfo() {
        let totalChargingTime = Int((reservationEndDate?.timeIntervalSince(reservationStartDate!))!)
        
        let timeHour: Int = totalChargingTime / 3600    //시간 계산
        let timeMinute: Int = totalChargingTime % 3600 / 60   //분 계산
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
        
        textStartDay = "MM/dd (E)".dateFormatter(formatDate: reservationStartDate!) //예약 시작일자
        textStartTime = "HH:mm".dateFormatter(formatDate: reservationStartDate!)    //예약 시작시간
        textEndDay = "MM/dd (E)".dateFormatter(formatDate: reservationEndDate!) //예약 종료일자
        textEndTime = "HH:mm".dateFormatter(formatDate: reservationEndDate!)    //예약 종료시간
        
        textReservationDate = "yyyy년 MM월 dd일 HH시 mm분".dateFormatter(formatDate: reservationStartDate!)
        
        //예약 상태 텍스트 - RESERVE(예약)
        if reservationStatus == "RESERVE" {
            textReservationStatus = "예약"
        }
        //KEEP(예약 지킴) - 충전중
        else if reservationStatus == "KEEP" {
            textReservationStatus = "충전중"
        }
    }
    
    //MARK: - 충전 포인트 확인
    /// 사용자의 현재 보유 포인트와 예상 차감 포인트를 확인 후 충전이 가능한지 여부 확인
    /// - Parameters:
    ///   - chargerId: 충전기 ID
    ///   - chargingStartDate: 충전 시작일시
    ///   - chargingEndDate: 충전 종료일시
    ///   - completion: 충전 가능 여부(Bool)
    func checkChargingPoint(chargerId: String, _ chargingStartDate: Date, _ chargingEndDate: Date, completion: @escaping (Bool) -> Void) {
        //사용자 포인트 API 호출
        getUserPoint() { (userPoint) in
            //예상 차감 포인트 API 호출
            self.gerExpectedPoint(chargerId: chargerId, chargingStartDate, chargingEndDate) { (expectedPoint) in

                let remainingPoint = Int(userPoint)! - Int(expectedPoint)!  //차감 후 잔여 포인트
                
                //차감 후 잔여 포인트가 0 이상인 경우
                if remainingPoint >= 0 {
                    self.textRemainingPoint = String(remainingPoint)    //차감 후, 잔여 포인트
                    completion(true)    //충전 가능
                }
                //차감 후 잔여 포인트가 0미만인 경우
                else {
                    self.textNeedPoint = String(remainingPoint) //필요 포인트
                    completion(false)   //충전 불가
                }
            }
        }
    }
    
    //MARK: - 사용자 포인트 호출
    func getUserPoint(completion: @escaping (String) -> Void) {
        let request = pointAPI.requestCurrentDate(userIdNo: userIdNo)
        request.execute(
            onSuccess: { (point) in
                self.textUserPoint = point
                completion(point)
            }
        )
    }
    
    //MARK: - 예상 차감 포인트 조회
    /// <#Description#>
    /// - Parameters:
    ///   - chargerId: <#chargerId description#>
    ///   - chargingStartDate: <#chargingStartDate description#>
    ///   - chargingEndDate: <#chargingEndDate description#>
    ///   - completion: <#completion description#>
    func gerExpectedPoint(chargerId: String, _ chargingStartDate: Date, _ chargingEndDate: Date, completion: @escaping (String) -> Void) {
        let startDate = "yyyy-MM-dd'T'HH:mm:ss".dateFormatter(formatDate: chargingStartDate) //충전 시작일시 변환
        let endDate = "yyyy-MM-dd'T'HH:mm:ss".dateFormatter(formatDate: chargingEndDate) //충전 종료일시 변환
        
        let parameters = [
            "startDate": startDate,
            "endDate": endDate
        ]

        //예상 차감 포인트 API 호출
        let request = pointAPI.requestExpectedPoint(chargerId: chargerId, parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (point) in
                self.textExpectedPoint = point
                completion(point)
            }
        )
    }
    
    //MARK: - 충전 예약 실행
    func reservation(chargerId: String, _ chargingStartDate: Date, _ chargingEndDate: Date, completion: @escaping (String, UserReservation?) -> Void) {
        
        let startDate = "yyyy-MM-dd'T'HH:mm:ss.sss'Z'".dateFormatter(formatDate: chargingStartDate) //충전 시작일시 변환
        let endDate = "yyyy-MM-dd'T'HH:mm:ss.sss'Z'".dateFormatter(formatDate: chargingEndDate) //충전 종료일시 변환
        
        gerExpectedPoint(chargerId: chargerId, chargingStartDate, chargingEndDate) { (point) in
            let expectedPoint = Int(point)!
            
            let parameters: [String : Any] = [
                "userId": Int(self.userIdNo)!, //사용자 ID 번호
                "chargerId": Int(chargerId)!, //충전기 ID
                "reservationType": "RESERVE",   //예약 유형 - RESERVE(예약)
                "expectPoint": expectedPoint,  //예상 차감 포인트
                "startDate": startDate, //충전 시작일시
                "endDate": endDate  //충전 종료일시
            ]
            
            let request = self.reservationAPI.requestReservation(parameters: parameters)
            request.execute(
                //API 호출 성공
                onSuccess: { (reservation) in
                    UserDefaults.standard.set(self.reservationType, forKey: "reservationType") //충전 예약 유형 - 사용자 정보 저장
                    completion("success", reservation)
                    
                    //self.getUserReservation()   //사용자 예약 정보 호출
                },
                //API 호출 실패
                onFailure: { (error) in
                    switch error {
                    case .responseSerializationFailed:
                        completion("fail", nil)
                    //일시적인 서버 오류 및 네트워크 오류
                    default:
                        completion("error", nil)
                        self.viewUtil.showToast(isShow: true, message: "server.error".message())
                        break
                    }
                }
            )
        }
    }
    
    //MARK: - 즉시 충전 취소
    func cancelInstantCharge(completion: @escaping (String) -> Void) {
        let request = reservationAPI.requestCancelInstantCharge(reservationId: self.reservationId)
        request.execute(
            //API 호출 성공
            onSuccess: { (result) in
                self.textReservationDate = ""
                self.reservedChargerName = ""
                
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
    
    //MARK: - 충전기 예약 취소
    func cancelReservation(completion: @escaping (String) -> Void) {
        let request = reservationAPI.requestCancelReservation(reservationId: self.reservationId)
        request.execute(
            //API 호출 성공
            onSuccess: { (result) in
                self.textReservationDate = ""
                self.reservedChargerName = ""
                
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
