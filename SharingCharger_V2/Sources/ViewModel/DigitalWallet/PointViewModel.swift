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
    
    @Published var viewUtil = ViewUtil() //View Util
    
    @Published var showSearchModal: Bool = false    //검색조건 Modal 활성 여부
    @Published var isSearchReset: Bool = false{ //검색조건 초기화 여부
        didSet {
            resetPointSearchCondition()  //검색조건 초기화 실행
        }
    }
    //MARK: - 포인트 이력 파라미터
    @Published var currentPoint: Int = 0                //현재 잔여 포인트
    @Published var chooseDate: String = "oneMonth"{     //조회기간 선택
        didSet {
            showSelectMonth()
        }
    }
    @Published var selectMonth: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())! //date picker 시작 날짜(선택 날짜)
    @Published var currentDate: Date = Date()           //date picker 종료 날짜(현재 날짜)
    @Published var selectPointType: String = "ALL"      //포인트 유형
    @Published var selectSort: String = "DESC"          //포인트 정렬
    
    //MARK: - 포인트 이력
    @Published var point: [String:Any] = [:]
    
    @Published var searchPoints: [[String:String]] = [] //조회환 포인트 정보 목록
    
//    var ageArr = [String]()
//    var nameArr = [String]()
//    var employedArr = [String]()
    
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
        viewUtil.isLoading = true   //로딩 시작
        searchPoints.removeAll()    //조회한 포인트 목록 마커 정보 초기화
        
        let userIdNo: String = UserDefaults.standard.string(forKey: "userIdNo") ?? ""   //저장된 사용자 ID 번호
        
        let endDate: String = "yyyy-MM-dd".dateFormatter(formatDate: currentDate)   // 종료일자
        
        let parameters = [
            "startDate": "yyyy-MM-dd".dateFormatter(formatDate: selectMonth),   //조회 시작일자
            "endDate": endDate,                                                 //조회 종료일자
            "pointUsedType": selectPointType,                                   //포인트 구분
            "page": "1",                                                        //페이지 번호
            "size": "10",                                                       //페이지 사이즈
            "sort": selectSort                                                  //정렬
        ]
        
        var searchPoint: [String:String] = [:]    //조회한 포인트 정보
        var searchPoints: [[String:String]] = []  //조회환 포인트 정보 목록
        
        //사용자 포인트 이력 조회 API 호출
        let request = pointAPI.requestWalletPointHistory(userIdNo: userIdNo, parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (history) in
                
                for index in 0..<history.content.count {
                    
                    let getPoint = history.content[index]!
                    let pointStatus = getPoint.type!
                    
                    var type: String = ""
                    var typeColor: String = ""
                    
                    //포인트 유형
                    if pointStatus == "PURCHASE"{
                        type = "구매"
                        typeColor = "#3498DB"
                    }
                    else if pointStatus == "PURCHASE_CANCEL" {
                        type = "구매 취소"
                        typeColor = "#E74C3C"
                    }
                    else if pointStatus == "EXCHANGE" {
                        type = "포인트 환전"
                        typeColor = "#E74C3C"
                    }
                    else if pointStatus == "GIVE" {
                        type = "포인트 지급"
                        typeColor = "#3498DB"
                    }
                    else if pointStatus == "WITHDRAW" {
                        type = "포인트 회수"
                        typeColor = "#E74C3C"
                    }
                    
                    //포인트 이력 정보
                    searchPoint = [
                        "chargerId": String(getPoint.id!),                  //충전기 ID
                        "username": getPoint.username!,                     //사용자 명
                        "point": String(getPoint.point!),                   //포인트
                        "type": type,                                       //유형
                        "pointTargetId": String(getPoint.pointTargetId!),
                        "targetName": String(getPoint.targetName ?? "" ),
                        "created": String(getPoint.created!),               //날짜
                        "typeColor": typeColor,                             //type에 따른 text color
                        "typeCode": pointStatus
                    ]
                    searchPoints.append(searchPoint)    //조회 포인트 목록 추가
                }
                
                self.searchPoints.append(contentsOf: searchPoints)  //조회 포인트 목록 추가
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
    //MARK: - 검색조건 설정 초기화
    
    func resetPointSearchCondition() {
        chooseDate = "oneMonth"
        selectPointType = "ALL"
        selectSort = "DESC"
        selectMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())! 
        currentDate = Date()
    }
    //MARK: - 조회기간 선택에 따른 날짜 변화
    func showSelectMonth(){
        if chooseDate == "ownPeriod"{
            selectMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        }
        else if chooseDate == "oneMonth"{
            selectMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        }
        else if chooseDate == "threeMonth"{
            selectMonth = Calendar.current.date(byAdding: .month, value: -3, to: Date())!
        }
        else if chooseDate == "sixMonth"{
            selectMonth = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
            
        }
        
    }
    
}
