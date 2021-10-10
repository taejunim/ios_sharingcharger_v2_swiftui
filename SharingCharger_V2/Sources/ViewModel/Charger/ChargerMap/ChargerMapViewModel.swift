//
//  ChargerMapViewModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/09.
//

import Foundation
import Combine

///충전기 지도 View Model
class ChargerMapViewModel: ObservableObject {
    private let chargerAPI = ChargerAPIService()  //충전기 API Service
    private let reservationAPI = ReservationAPIService()    //예약 API Service

    @Published var viewUtil = ViewUtil() //View Util
    @Published var result: String = ""  //조회 결과
    
    //MARK: - 위치 정보 변수
    @Published var location = Location()   //위치 정보 서비스
    @Published var authStatus = Location().getAuthStatus()  //위치 정보 권한 상태
    @Published var latitude: Double = 37.566407799201336    //위도 - 위치 서비스 권한이 없거나 비활성인 경우 기본 값 설정
    @Published var longitude: Double = 126.97787363088995   //경도 - 위치 서비스 권한이 없거나 비활성인 경우 기본 값 설정
    @Published var zoomLevel: Int = 0   //Zoom Level
    @Published var currentAddress: String = ""  //현재 위치 주소 - 지도 중심 위치
    @Published var isCurrentLocation: Bool = false  //현재 위치 이동 여부
    
    //MARK: - 지도 관련 변수
    @Published var mapView = MTMapView(frame: .zero)    //지도 화면
    @Published var isTapOnMap: Bool = false //지도 탭 여부
    @Published var selectChargerId: String = "" //선택한 충전기 ID
    @Published var moveToChargerId: String = "" //해당 충전기의 위치로 이동할 충전기 ID
    
    //MARK: - 충전기 조회 변수
    @Published var isShowSearchModal: Bool = false  //검색조건 Modal 창 호출 여부
    @Published var currentDate: Date = Date()   //현재 일시
    @Published var charger: [String:Any] = [:]  //충전기 정보
    @Published var chargers: [[String:Any]] = []    //충전기 정보 목록
    @Published var markerItem: [String:Any] = [:]   //충전기 마커 정보
    @Published var markerItems: [[String:Any]] = [] //충전기 마커 정보 목록
    @Published var searchStartDate: Date?   //조회 시작일시
    @Published var searchEndDate: Date? //조회 종료일시
    @Published var radius: String = ""  //조회 반경범위
    @Published var isShowChargerList: Bool = false  //충전기 목록 노출 여부
    @Published var searchChargers: [[String:String]] = []  //충전기 검색 목록
    
    //MARK: - 충전기 정보 변수
    @Published var isShowInfoView: Bool = false //충전기 정보 화면 노출 여부
    @Published var chargerId: String = ""   //충전기 ID
    @Published var chargerName: String = "" //충전기 명
    @Published var bleNumber: String = ""   //충전기 BLE 번호
    @Published var chargerAddress: String = ""  //충전기 주소
    @Published var chargerDetailAddress: String = ""    //충전기 상세주소
    @Published var chargerLatitude: Double? //충전기 위도(Y좌표)
    @Published var chargerLongitude: Double?    //충전기 경도(X좌표)
    @Published var chargeUnitPrice: String = ""    //충전 단가
    @Published var chargerStatus: String = ""   //충전기 상태
    @Published var isFavorites: Bool = false    //즐겨찾기 표시 여부
    
    @Published var isShowChargingView: Bool = false   //충전 화면 호출 여부
    @Published var isShowAddressSearchModal: Bool = false    //주소 검색 Modal 창 호출 여부
    
    //MARK: - 현재 일시(서버 시간 기준) 조회
    /// - Parameter completion: Current Date 서버 기준 현재 일시
    func getCurrentDate(completion: @escaping (Date) -> Void) {
        //현재 일시 API 호출
        let request = reservationAPI.requestCurrentDate()
        request.execute(
            //API 호출 성공
            onSuccess: { (currentDate) in
                let formatDate = "yyyy-MM-dd HH:mm:ss".toDateFormatter(formatString: currentDate)!
                
                completion(formatDate)
                self.currentDate = formatDate
            },
            //API 호출 실패
            onFailure: { (error) in
                completion(Date())
            }
        )
    }
    
    //MARK: - 위치 정보 호출
    func getLoacation() {
        location.getLocation()  //위치 정보 호출
        
        if authStatus == "authorized" || authStatus == "authorizedAlways" || authStatus == "authorizedWhenInUse" {
            latitude = location.latitude!    //위도
            longitude = location.longitude!  //경도
        }
    }
    
    //MARK: - 현재 위치 이동
    /// - Parameters:
    ///   - searchStartDate: 조회 시작일시
    ///   - searchEndDate: 조회 종료일시
    func currentLocation(_ searchStartDate: Date, _ searchEndDate: Date) {
        isCurrentLocation = true    //현재 위치 이동 여부
        isShowInfoView = false  //충전기 정보 창 비활성
        
        getLoacation()  //현재 위치 정보 호출
        
        //현재 위치 지도 중심으로 이동
        mapView.setMapCenter(
            MTMapPoint(geoCoord: MTMapPointGeo(latitude: latitude, longitude: longitude)),
            animated: true
        )
        
        mapView.setZoomLevel(MTMapZoomLevel(0), animated: true)   //Zoom Level 설정
        
        //충전기 목록 조회
        getChargerList(zoomLevel: 0, latitude: latitude, longitude: longitude, searchStartDate: searchStartDate, searchEndDate: searchEndDate) { _ in }
    }
    
    //MARK: - 충전기 목록 조회 실행
    /// - Parameters:
    ///   - zoomLevel: Zoom 레벨
    ///   - latitude: 위도
    ///   - longitude: 경도
    ///   - searchStartDate: 조회 시작일시
    ///   - searchEndDate: 조회 종료일시
    func getChargerList(zoomLevel: Int, latitude: Double, longitude: Double, searchStartDate: Date, searchEndDate: Date, completion: @escaping ([Charger]) -> Void) {
        isShowInfoView = false  //충전기 정보 화면 비활성화
        viewUtil.isLoading = true   //로딩 시작
        
        chargers.removeAll()    //조회한 충전기 목록 초기화
        markerItems.removeAll() //조회한 충전기 목록 마커 정보 초기화
        searchChargers.removeAll()  //조회한 하단 충전기 목록 초기화

        let startDate: String = "yyyy-MM-dd'T'HH:mm:ss".dateFormatter(formatDate: searchStartDate)  //조회 시작일시
        let endDate: String = "yyyy-MM-dd'T'HH:mm:ss".dateFormatter(formatDate: searchEndDate)  //조회 종료일시

        //조회 조건 Parameters
        let parameters = [
            "gpsX": String(longitude),  //X좌표(경도)
            "gpsY": String(latitude),   //Y좌표(위도)
            "startDate": startDate, //조회 시작일시
            "endDate": endDate, //조회 종료일시
            "distance": radius  //조회 반경범위
        ]
        
        var searchCharger: [String:String] = [:]    //조회한 충전기 정보
        var searchChargers: [[String:String]] = []  //조회환 충전기 정보 목록

        //충전기 목록 API 호출
        let request = chargerAPI.requestChargerList(parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (getChargers) in
                self.viewUtil.isLoading = false //로딩 종료
                self.result = "success"
                
                for index in 0..<getChargers.count {
                    let getCharger = getChargers[index]
                    
                    self.charger.updateValue(getCharger.id!, forKey: "chargerId")   //충전기 ID
                    self.charger.updateValue(getCharger.name!, forKey: "chargerName")   //충전기 명
                    self.charger.updateValue(getCharger.bleNumber!, forKey: "bleNumber")    //BLE 번호
                    self.charger.updateValue(getCharger.address!, forKey: "address")    //충전기 주소
                    self.charger.updateValue(getCharger.detailAddress!, forKey: "detailAddress")    //충전기 상세주소
                    self.charger.updateValue(getCharger.gpsX!, forKey: "longitude") //X좌표(경도)
                    self.charger.updateValue(getCharger.gpsY!, forKey: "latitude")  //Y좌표(위도)
                    self.charger.updateValue(getCharger.currentStatusType!, forKey: "chargerStatus")    //충전기 상태
                    self.charger.updateValue(getCharger.searchDateFlag!, forKey: "isSearchDate")    //조회일자 여부
                    
                    self.chargers.append(self.charger)  //충전기 목록에 충전기 정보 추가
                    
                    searchCharger = [
                        "chargerId": String(getCharger.id!),    //충전기 ID
                        "chargerName": getCharger.name!,    //충전기 명
                        "bleNumber": getCharger.bleNumber!, //BLE 번호
                        "address": getCharger.address!, //충전기 주소
                        "detailAddress": getCharger.detailAddress! == "" ? "-" : getCharger.detailAddress!, //충전기 상세주소
                        "longitude": String(getCharger.gpsX!),  //X좌표(경도)
                        "latitude": String(getCharger.gpsY!),   //Y좌표(위도)
                        "chargerStatus": getCharger.currentStatusType!  //충전기 상태
                    ]
                    
                    searchChargers.append(searchCharger)    //조회 충전기 목록 추가
                }
                
                self.setChargerMarker(chargers: self.chargers)  //지도에 표시될 충전기 마커 설정
                self.searchChargers.append(contentsOf: searchChargers)  //조회 충전기 목록 추가
                self.isCurrentLocation = false  //현재 위치 이동 여부
                
                completion(getChargers)
            },
            //API 호출 실패
            onFailure: { (error) in
                self.viewUtil.isLoading = false //로딩 종료
                self.result = "error"
                self.chargers = []  //충전기 목록 초기화
                self.isCurrentLocation = false  //현재 위치 이동 여부
            }
        )
    }
    
    //MARK: - 충전기 마커 세팅
    /// - Parameter chargers: 충전기 정보 목록
    func setChargerMarker(chargers: [[String:Any]]) {
        
        for index in 0..<chargers.count {
            let charger = chargers[index]   //충전기 정보
            let status = charger["chargerStatus"] as! String //충전기 상태
            
            var markgerImage: String = ""   //충전기 마커 이미지
            var markgerSelectImage: String = ""  //충전기 마커 선택 이미지
            
            //충전기 상태 - 충전 대기 상태
            if status == "READY" {
                markgerImage = "Map-Pin-Blue.png"
                markgerSelectImage = "Map-Pin-Blue-Select.png"
            }
            //충전기 상태 - 예약 상태
            else if status == "RESERVATION" {
                markgerImage = "Map-Pin-Red.png"
                markgerSelectImage = "Map-Pin-Red-Select.png"
            }
            //충전기 상태 -
            else if status == "CHARGING" {
                markgerImage = "Map-Pin-Red.png"
                markgerSelectImage = "Map-Pin-Red-Select.png"
            }
            else {
                markgerImage = "Map-Pin-Red.png"
                markgerSelectImage = "Map-Pin-Red-Select.png"
            }
            
            //충전기 마커 정보
            markerItem = [
                "markerId": charger["chargerId"]!,  //Marker ID
                "markerName": charger["chargerName"]!,  //마커 명
                "address": charger["address"]!, //마커 주소
                "latitude": charger["latitude"]!,   //위도
                "longitude": charger["longitude"]!, //경도
                "markerImage": markgerImage,    //마커 이미지
                "markerSelectImage": markgerSelectImage //마커 선택 이미지
            ]
            
            markerItems.append(markerItem)  //마커 목록에 추가
        }
        
        addPOIItems(markerItems: markerItems)   //지도에 생성한 마커 추가
    }
    
    //MARK: - 지도 POIItem(마커) 추가
    /// - Parameter markerItems: 마커 정보 목록
    func addPOIItems(markerItems: [[String:Any]]) {
        mapView.removeAllPOIItems() //지도에 표시된 마커 전체삭제
        
        var poiItem: MTMapPOIItem?  //POI Item
        var poiItems: [MTMapPOIItem] = []   //POI Item 목록
        var mapPoint: MTMapPoint?   //마커 위치

        //POI Item 생성
        for index in 0..<markerItems.count {
            let markerItem = markerItems[index]

            let latitude = markerItem["latitude"] as? Double    //위도
            let longitude = markerItem["longitude"] as? Double  //경도
            mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: latitude!, longitude: longitude!))  //마커 위치

            poiItem = MTMapPOIItem()
            poiItem?.tag = markerItem["markerId"] as! Int   //마커 태그 - ID
            poiItem?.itemName = markerItem["markerName"] as? String //마커 명
            poiItem?.mapPoint = mapPoint    //마커 위치
            poiItem?.markerType = .customImage  //마커 이미지 타입 - 커스텀 이미지
            poiItem?.customImage = UIImage(named: markerItem["markerImage"] as! String)?.resize(width: 40)  //마커 이미지 - 이미지 사이즈 설정
            poiItem?.markerSelectedType = .customImage  //마커 선택 이미지 타입 - 커스텀 이미지
            poiItem?.customSelectedImage = UIImage(named: markerItem["markerSelectImage"] as! String)?.resize(width: 40)    //마커 선택 이미지
            poiItem?.customImageAnchorPointOffset = .init(offsetX: 40, offsetY: 0)  //마커 이미지 Offset 설정
            poiItem?.showDisclosureButtonOnCalloutBalloon = false   //마커 선택 시 노출되는 말풍선의 이미지 비활성

            poiItems.append(poiItem!)
        }

        mapView.addPOIItems(poiItems)   //지도에 POIItems(마커) 추가
    }
    
    //MARK: - 선택한 충전기로 지도 이동 및 마커 선택 표시
    /// 하단 조회된 충전기 목록에서 충전기 선택 시, 해당 충전기로 지도 이동 및 충전기 마커 선택 표시 처리
    /// - Parameter chargerId: 선택한 충전기 ID
    func moveToSelectedCharger(chargerId: String) {
        //현재 위치 지도 중심으로 이동
        mapView.setMapCenter(
            MTMapPoint(geoCoord: MTMapPointGeo(latitude: latitude, longitude: longitude)),
            animated: true
        )
        
        mapView.setZoomLevel(MTMapZoomLevel(0), animated: true)   //Zoom Level 설정
        
        mapView.select(mapView.findPOIItem(byTag: Int(chargerId)!), animated: true)   //마커 선택 표시 처리
    }
    
    //MARK: - 예약한 충전기로 이동
    func moveToReservedCharger(chargerId: String, latitude: Double, longitude: Double) {
        //충전기 위치 지도 중심으로 이동
        mapView.setMapCenter(
            MTMapPoint(geoCoord: MTMapPointGeo(latitude: latitude, longitude: longitude)),
            animated: true
        )
        
        mapView.setZoomLevel(MTMapZoomLevel(0), animated: true)   //Zoom Level 설정
        
        //충전기 목록 조회
        getChargerList(zoomLevel: 0, latitude: latitude, longitude: longitude, searchStartDate: currentDate, searchEndDate: currentDate) { _ in
            self.mapView.select(self.mapView.findPOIItem(byTag: Int(chargerId)!), animated: true)   //마커 선택 표시 처리
        }
    }
    
    //MARK: - 충전기 선택 해제
    /// 지도에서 선택한 충전기의 선택 해제 처리
    /// - Parameter chargerId: 선택된 충전기 ID
    func deselectedCharger(chargerId: String) {
        if chargerId != "" {
            mapView.deselect(mapView.findPOIItem(byTag: Int(chargerId)!))   //선택 해제 처리
        }
    }
    
    //MARK: - 선택된 충전기
    /// 지도에서 충전기 마커 선택 시, 실행
    /// - Parameter chargerId: 선택한 충전기 ID
    func selectedCharger(chargerId: Int) {
        self.selectChargerId = String(chargerId)
        
        //Background Thread - 지도 이벤트 발생 시, 느려지는 현상으로 추가
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                self.isShowInfoView = true  //충전기 정보 창 호출
                self.isFavorites = false    //충전기 즐겨찾기 표시 여부
                
                self.getCharger(chargerId: self.selectChargerId)  //충전기 정보 호출
                self.getChargerReservation(chargerId: self.selectChargerId)   //충전기 예약 현황 호출
            }
        }
    }
    
    //MARK: - 충전기 정보 호출
    /// 충전기 선택 시 충전기의 정보 API 호출
    /// - Parameter chargerId: 선택한 충전기 ID
    func getCharger(chargerId: String) {
        //충전기 정보 API 호출
        let request = chargerAPI.requestCharger(chargerId: chargerId)
        request.execute(
            //API 호출 성공
            onSuccess: { (charger) in
                self.chargerId = String(charger.id!) //충전기 ID
                self.chargerName = charger.name!    //충전기 명
                self.bleNumber = charger.bleNumber! //BLE 번호
                self.chargerAddress = charger.address!  //충전기 주소
                self.chargerDetailAddress = charger.detailAddress! == "" ? "-" : charger.detailAddress!   //충전기 상세주소
                self.chargerLongitude = charger.gpsX!   //X좌표(경도)
                self.chargerLatitude = charger.gpsY!    //Y좌표(위도)
                self.chargeUnitPrice = charger.rangeOfFee!  //충전 단가
            },
            //API 호출 실패
            onFailure: { (error) in
                self.result = "error"
            }
        )
    }
    
    //MARK: - 충전기 예약 현황 호출
    /// 충전기 선택 시, 해당 충전기의 예약 현황
    /// - Parameter chargerId: 선택한 충전기 ID
    func getChargerReservation(chargerId: String) {
        //충전기 예약 현황 조회 Parameters
        let parameters = [
            "page": "1",
            "size": "100",
            "sort": "ASC"
        ]
        
        //충전기 예약 현황 API 호출
        let request = reservationAPI.requestChargerReservation(chargerId: chargerId, parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (charger) in
                self.getAvailableTime(availableTime: charger.chargerAllowTime)
            },
            //API 호출 실패
            onFailure: { (error) in
                print(error)
                self.result = "error"
            }
        )
    }
    
    //MARK: - 이용 가능 시간
    /// 조회한 충전기 예약 현황 정보에 따른 충전기 이용 가능 시간 생성
    /// - Parameter availableTime: 이용 가능 시간
    func getAvailableTime(availableTime: ChargerAllowTime) {
        //print(availableTime)
        
        let getOpenTime = availableTime.todayOpenTime
        let openTime = "HH:mm:ss".toDateFormatter(formatString: getOpenTime)
        //print(openTime)
        
        //print("HHmmss".dateFormatter(formatDate: openTime!))
        
        if "2021-08-27T16:53:00" < ("2021-08-27T" + getOpenTime) {
            //print("tq")
        }
        else {
            //print("ttttttttq")
        }
    }
    
    func launchNavigation() {
        var kakaoMap = "kakaomap://"
        let appCheckURL = URL(string: kakaoMap)
        
        //카카오맵 설치된 경우
        if UIApplication.shared.canOpenURL(appCheckURL!) {
            kakaoMap.append("route?by=CAR")
            kakaoMap.append("&sp=" + String(self.latitude) + "," + String(self.longitude))
            kakaoMap.append("&ep=" + String(self.chargerLatitude!) + "," + String(self.chargerLongitude!))
            
            let navigationUrl = URL(string: kakaoMap)
            
            UIApplication.shared.open(navigationUrl!, options: [:] , completionHandler: nil)
        }
        //카카오맵 설치되지 않은 경우 App Store 이동
        else {
            let dialog = UIAlertController(title:"", message : "카카오맵이 설치되어있지 않습니다.\n설치를 위해 App Store로 이동하시겠습니까?", preferredStyle: .alert)
            
            dialog
                .addAction(
                    UIAlertAction(title: "취소", style: UIAlertAction.Style.destructive) { (action:UIAlertAction) in
                        return
                    }
                )
            dialog
                .addAction(
                    UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { (action:UIAlertAction) in
                        let appStoreUrl = URL(string: "https://apps.apple.com/kr/app/id304608425")
                        
                        if UIApplication.shared.canOpenURL(appStoreUrl!) {
                            UIApplication.shared.open(appStoreUrl!, options: [:], completionHandler: nil)
                        }
                    }
                )
            
            UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.rootViewController?.present(dialog, animated: true, completion: nil)
        }
    }
}
