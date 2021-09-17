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
    
    @Published var showChargingAlert: Bool = false
    @Published var showChargingPointAlert: Bool = false
    @Published var showCancelAlert: Bool = false
    
    @Published var userIdNo: String = "" //UserDefaults.standard.string(forKey: "userIdNo")! //사용자 ID 번호
    @Published var isUserReservation: Bool = false  //사용자 예약 여부
    @Published var reservationId: String = ""   //예약 ID
    @Published var reservationType: String = ""  //충전 예약 유형
    @Published var reservedChargerId: String = ""  //예약 충전기 번호
    @Published var chargerLatitude: Double? //충전기 위도(Y좌표)
    @Published var chargerLongitude: Double?    //충전기 경도(X좌표)
    
    @Published var reservationStartDate: Date?  //예약 시작일시
    @Published var reservationEndDate: Date?    //예약 종료일시
    
    @Published var textChargingTime: String = ""    //총 충전 시간 텍스트
    @Published var textStartDay: String = ""    //충전 시작 일자 텍스트
    @Published var textStartTime: String = ""   //충전 시작 시간 텍스트
    @Published var textEndDay: String = ""  //충전 종료 일자 텍스트
    @Published var textEndTime: String = "" //충전 종료 시간 텍스트
    @Published var textExpectedPoint: String = ""   //예상 차감포인트 텍스트
    
    @Published var textUserPoint: String = ""
    @Published var textNeedPoint: String = ""
    
    //MARK: - 사용자의 현재 예약 정보 조회
    func getUserReservation() {
        //사용자의 충전기 예약 정보 호출
        let request = reservationAPI.requesUserReservation(userIdNo: userIdNo)
        request.execute(
            //API 호출 성공
            onSuccess: { (reservation) in
                self.isUserReservation = true   //사용자 예약 여부
                
                self.reservationId = String(reservation.id) //예약 ID
                self.reservedChargerId = String(reservation.chargerId)  //예약 충전기 ID
                
                let formatStartDate = "yyyy-MM-dd'T'HH:mm:ss".toDateFormatter(formatString: reservation.startDate!) //충전 시작일시 - Date 형식으로 변환
                let formatEndDate = "yyyy-MM-dd'T'HH:mm:ss".toDateFormatter(formatString: reservation.endDate!) //충전 종료일시 - Date 형식으로 변환

                self.reservationStartDate = formatStartDate
                self.reservationEndDate = formatEndDate
                
                self.setReservationInfo()
                self.textExpectedPoint = String(reservation.expectPoint!)
            },
            //API 호출 실패
            onFailure: { (error) in
                print(error)
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
    }
    
    func checkChargingPoint(chargerId: String, _ chargingStartDate: Date, _ chargingEndDate: Date, completion: @escaping (Bool) -> Void) {
        getUserPoint() { (userPoint) in
            print(userPoint)
            self.gerExpectedPoint(chargerId: chargerId, chargingStartDate, chargingEndDate) { (expectedPoint) in
                
                let remainingPoint = Int(userPoint)! - Int(expectedPoint)!
                
                print(expectedPoint)
                print(remainingPoint)
                
                if remainingPoint >= 0 {
                    completion(true)
                }
                else {
                    self.textNeedPoint = String(remainingPoint)
                    completion(false)
                }
            }
        }
    }
    
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
    func reservation(chargerId: String, _ chargingStartDate: Date, _ chargingEndDate: Date, completion: @escaping (UserReservation) -> Void) {
        
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
                onSuccess: { [self] (reservation) in
                    UserDefaults.standard.set(self.reservationType, forKey: "reservationType") //충전 예약 유형 - 사용자 정보 저장
                    completion(reservation)
                    
                    self.getUserReservation()   //사용자 예약 정보 호출
                },
                //API 호출 실패
                onFailure: { (error) in
                    switch error {
                    case .responseSerializationFailed:
                        print(error)
                    //일시적인 서버 오류 및 네트워크 오류
                    default:
                        self.viewUtil.showToast(isShow: true, message: "server.error".message())
                        break
                    }
                }
            )
        }
    }
    
    //MARK: - 즉시 충전 취소
    func cancelInstantCharge(completion: @escaping (UserReservation) -> Void) {
        let request = reservationAPI.requestCancelInstantCharge(reservationId: self.reservationId)
        request.execute(
            //API 호출 성공
            onSuccess: { (cancel) in
                completion(cancel)
                self.viewUtil.showToast(isShow: true, message: "해당 예약 건이 정상적으로 취소되었습니다.")
            },
            //API 호출 실패
            onFailure: { (error) in
                switch error {
                case .responseSerializationFailed:
                    print(error)
                    self.viewUtil.showToast(isShow: true, message: "해당 예약 건의 취소가 실패하였습니다.\n즉시 충전 건은 10분 이내에만 취소 가능하며, 자세한 사항은 관리자에게 문의 바랍니다.")
                //일시적인 서버 오류 및 네트워크 오류
                default:
                    self.viewUtil.showToast(isShow: true, message: "server.error".message())
                    break
                }
            }
        )
    }
}
