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
    
    @Published var currentPoint: String = ""
    @Published var selectPointType: String = "ALL"
    @Published var selectSort: String = "ASC"
    
    //MARK: - 현재 사용자 포인트 조회
    func getCurrentPoint() {
        let userIdNo: String = UserDefaults.standard.string(forKey: "userIdNo") ?? ""   //저장된 사용자 ID 번호
        //현재 사용자 포인트 API 호출
        let request = pointAPI.requestCurrentDate(userIdNo: userIdNo)
        request.execute(
            //API 호출 성공
            onSuccess: { (point) in
                self.currentPoint = point
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
        
        let parameters = [
            "startDate": "2021-07-01",  //조회 시작일자
            "endDate": "2021-09-30",    //조회 종료일자
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
