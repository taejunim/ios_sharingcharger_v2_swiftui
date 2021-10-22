//
//  AddressSearchViewModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/10/08.
//

import Foundation

///주소 검색 관련 View Model
class AddressSearchViewModel: ObservableObject {
    private let commonAPI = CommonAPIService()  //공통 API Service
    
    @Published var viewPath: String = ""    //호출 화면 경로
    
    @Published var location = Location()   //위치 정보 서비스
    @Published var authStatus = Location().getAuthStatus()  //위치 정보 권한 상태
    
    @Published var userLatitude: Double?    //사용자중심 - 위도(사용자 현재 위치)
    @Published var userLongitude: Double?   //사용자중심 - 경도(사용자 현재 위치)
    @Published var mapCenterLatitude: Double?   //지도충심 - 위도
    @Published var mapCenterLongitude: Double?  //지도중심 - 경도
    @Published var selectCenterLocation: String = "user"    //검색 중심위치 선택
    
    @Published var isSearch: Bool = false   //검색 여부
    //검색어
    @Published var searchWord: String = "" {
        didSet {
            //검색어가 공백인 경우
            if searchWord.isEmpty {
                isSearch = false    //검색 여부 초기화
                isLastPage = false  //마지막 페이지 여부 초기화
                totalCount = 0  //총 검색 개수 초기화
                page = 1    //페이지 번호
            }
        }
    }
    @Published var page: Int = 1    //페이지 번호
    @Published var size: Int = 10   //한 페이지당 개수
    @Published var isLastPage: Bool = false    //마지막 페이지 여부
    @Published var totalCount: Int = 0  //총 검색 개수
    @Published var place: [String:String] = [:] //장소 정보
    @Published var places: [[String:String]] = []   //장소 정보 목록
    
    //MARK: - 위치 정보 호출
    func getLoacation() {
        location.getLocation()  //위치 정보 호출
        
        if authStatus == "authorized" || authStatus == "authorizedAlways" || authStatus == "authorizedWhenInUse" {
            userLatitude = location.latitude!    //위도
            userLongitude = location.longitude!  //경도
        }
    }
    
    //MARK: - 주소 검색 목록 호출
    func getAddressList() {
        self.place.removeAll()  //검색항목 삭제
        self.places.removeAll() //검색목록 삭제
        
        var latitude: String = ""
        var longitude: String = ""
        
        //내 위치중심 선택한 경우 위경도 설정
        if selectCenterLocation == "user" {
            latitude = String(userLatitude!)
            longitude = String(userLongitude!)
        }
        //지도중심 선택한 경우 위경도 설정
        else if selectCenterLocation == "map" {
            latitude = String(mapCenterLatitude!)
            longitude = String(mapCenterLongitude!)
        }
        
        let parameters: [String:String] = [
            "query": searchWord,    //검색을 원하는 질의어
            "x": longitude,    //중심 좌표의 X값 혹은 longitude
            "y": latitude,    //중심 좌표의 Y값 혹은 latitude
            //"radius": "20000",    //중심 좌표부터의 반경거리. 특정 지역을 중심으로 검색 - 0m~20000m
            "page": String(page),    //결과 페이지 번호 - 1~45 (기본값: 1)
            "size": String(size),   //한 페이지에 보여질 문서의 개수 - 1~15 (기본값: 15)
            "sort": "distance"  //결과 정렬 순서 - distance 또는 accuracy (기본값: accuracy)
        ]
            
        //주소 검색 API 호출
        let request = commonAPI.requestAddressSearch(parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (address) in
                self.totalCount = address.meta.totalCount
                self.isLastPage = address.meta.isEnd
                
                let places = address.documents  //검색 조건에 맞는 장소 목록
                
                for place in places {
                    let getCategory = place!.categoryName   //카테고리 추출
                    var category = ""   //카테고리
                    
                    //하위 카테고리 여부 확인
                    if getCategory.contains(">") {
                        category = getCategory[getCategory.lastIndex(of: ">")!...].trimmingCharacters(in: [">"]).trimmingCharacters(in: .whitespaces)
                    }
                    else {
                        category = getCategory
                    }
                    
                    let getDistance = place!.distance   //조회한 중심 위치와의 거리 추출
                    var distance = ""   //조회 위치와의 거리
                    
                    //1000m 이상인 경우 km 단위로 변환
                    if Double(getDistance)! >= 1000 {
                        distance = String(ceil(Double(getDistance)! / 1000 * 10) / 10) + "km"
                    }
                    else {
                        distance = getDistance + "m"
                    }
                    
                    self.place = [
                        "placeName": place!.placeName,  //장소명
                        "category": category,   //카테고리
                        "distance": distance,   //거리
                        "roadAddress": place!.roadAddressName,  //도로명 주소
                        "address": place!.addressName,  //지번 주소
                        "phone": place!.phone,  //전화번호
                        "latitude": place!.y,   //위도
                        "longitude": place!.x   //경도
                    ]
                    
                    self.places.append(self.place)
                }
            },
            //API 호출 실패
            onFailure: { (error) in
                print(error)
            }
        )
    }
    
    //MARK: - 다음 주소 목록 추가
    func addNextAddressList() {
        var latitude: String = ""
        var longitude: String = ""
        
        //내 위치중심 선택한 경우 위경도 설정
        if selectCenterLocation == "user" {
            latitude = String(userLatitude!)
            longitude = String(userLongitude!)
        }
        //지도중심 선택한 경우 위경도 설정
        else if selectCenterLocation == "map" {
            latitude = String(mapCenterLatitude!)
            longitude = String(mapCenterLongitude!)
        }
        
        let parameters: [String:String] = [
            "query": searchWord,    //검색을 원하는 질의어
            "x": longitude,    //중심 좌표의 X값 혹은 longitude
            "y": latitude,    //중심 좌표의 Y값 혹은 latitude
            //"radius": "20000",    //중심 좌표부터의 반경거리. 특정 지역을 중심으로 검색 - 0m~20000m
            "page": String(page),    //결과 페이지 번호 - 1~45 (기본값: 1)
            "size": String(size),   //한 페이지에 보여질 문서의 개수 - 1~15 (기본값: 15)
            "sort": "distance"  //결과 정렬 순서 - distance 또는 accuracy (기본값: accuracy)
        ]
            
        //주소 검색 API 호출
        let request = commonAPI.requestAddressSearch(parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (address) in
                self.totalCount = address.meta.totalCount
                self.isLastPage = address.meta.isEnd
                
                let places = address.documents  //검색 조건에 맞는 장소 목록
                
                for place in places {
                    let getCategory = place!.categoryName   //카테고리 추출
                    var category = ""   //카테고리
                    
                    //하위 카테고리 여부 확인
                    if getCategory.contains(">") {
                        category = getCategory[getCategory.lastIndex(of: ">")!...].trimmingCharacters(in: [">"]).trimmingCharacters(in: .whitespaces)
                    }
                    else {
                        category = getCategory
                    }
                    
                    let getDistance = place!.distance   //조회한 중심 위치와의 거리 추출
                    var distance = ""   //조회 위치와의 거리
                    
                    //1000m 이상인 경우 km 단위로 변환
                    if Double(getDistance)! >= 1000 {
                        distance = String(ceil(Double(getDistance)! / 1000 * 10) / 10) + "km"
                    }
                    else {
                        distance = getDistance + "m"
                    }
                    
                    self.place = [
                        "placeName": place!.placeName,  //장소명
                        "category": category,   //카테고리
                        "distance": distance,   //거리
                        "roadAddress": place!.roadAddressName,  //도로명 주소
                        "address": place!.addressName,  //지번 주소
                        "phone": place!.phone,  //전화번호
                        "latitude": place!.y,   //위도
                        "longitude": place!.x   //경도
                    ]
                    
                    self.places.append(self.place)
                }
            },
            //API 호출 실패
            onFailure: { (error) in
                print(error)
                self.page = self.page - 1   //API 호출 실패 시, 추가한 페이지 감소
            }
        )
    }
}
