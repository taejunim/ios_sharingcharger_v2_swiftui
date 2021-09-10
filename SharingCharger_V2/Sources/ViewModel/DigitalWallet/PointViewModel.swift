//
//  PointViewModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/19.
//

import Foundation
import Combine

class PointViewModel: ObservableObject {
    public var didChange = PassthroughSubject<PointViewModel, Never>()
    
    private let pointAPI = PointAPIService()  //포인트 API Service
    
    //MARK: - 포인트 이력 파라미터
    @Published var currentPoint: Int = 0
    @Published var selectPointType: String = "ALL"
    @Published var selectSort: String = "ASC"
    @Published var currentDate: Date = Date()
    
    //MARK: - 포인트 이력
    @Published var point: [String:Any] = [:]
    
    
    
    //MARK: - 현재 사용자 포인트 조회
    func getCurrentPoint() {
        let userIdNo: String = UserDefaults.standard.string(forKey: "userIdNo") ?? ""   //저장된 사용자 ID 번호
        //현재 사용자 포인트 API 호출
        let request = pointAPI.requestCurrentDate(userIdNo: userIdNo)
        request.execute(
            //API 호출 성공
            onSuccess: { (point) in
                self.currentPoint = Int(point) ?? 0
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
    
    
    //MARK: - 사용자 포인트 이력 조회
    func getPointHistory() {
        let userIdNo: String = UserDefaults.standard.string(forKey: "userIdNo") ?? ""   //저장된 사용자 ID 번호
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) //시작일자
        
        let dateFormatter: DateFormatter = {                                        //시작일자 날짜 형식 변경
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            return dateFormatter
        }()
        let endDate: String = "yyyy-MM-dd".dateFormatter(formatDate: currentDate)   // 종료일자
        
      
        let parameters = [
            "startDate": dateFormatter.string(from:startDate!),  //조회 시작일자(종료일자 한달 전)
            "endDate": endDate,    //조회 종료일자
            "pointUsedType": selectPointType,    //포인트 구분
            "page": "1",    //페이지 번호
            "size": "10",   //페이지 사이즈
            "sort": selectSort  //정렬
        ]
        
        //사용자 포인트 이력 조회 API 호출
        let request = pointAPI.requestPointHistory(userIdNo: userIdNo, parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (history) in
                
            print(history)
         
                
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
