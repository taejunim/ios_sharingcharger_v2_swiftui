//
//  ChargerMapViewModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/09.
//

import Foundation
import Combine

class ChargerMapViewModel: ObservableObject {
    public var didChange = PassthroughSubject<ChargerMapViewModel, Never>()
    
    private let chargerAPI = ChargerAPIService()  //충전기 API Service
    @Published var viewUtil = ViewUtil() //View Util
    
    @Published var result: String = ""
    
    //MARK: - 위치 정보 변수
    @Published var location = Location()   //위치 정보 서비스
    @Published var authStatus = Location().getAuthStatus()
    @Published var latitude: Double = 37.566407799201336    //위도 - 위치 서비스 권한이 없거나 비활성인 경우 기본 값 설정
    @Published var longitude: Double = 126.97787363088995   //경도 - 위치 서비스 권한이 없거나 비활성인 경우 기본 값 설정
    @Published var zoomLevel: Int = 1
    @Published var currentAddress: String = ""  //현재 위치 주소 - 지도 중심 위치
    
    //MARK: - 지도 관련 변수
    @Published var mapView = MTMapView(frame: .zero)
    @Published var isTapOnMap: Bool = false
    
    //MARK: - 충전기 조회 변수
    @Published var charger: [String:Any] = [:]
    @Published var chargers: [[String:Any]] = []
    @Published var markerItem: [String:Any] = [:]
    @Published var markerItems: [[String:Any]] = []
    
    //MARK: - 충전기 정보 변수
    @Published var isShowInfoView: Bool = false
    @Published var chargerName: String = ""
    @Published var chargerAddress: String = ""
    @Published var chargerUnitPrice: String = ""
    @Published var isFavorites: Bool = false
    
    //MARK: - 검색 조건 변수
    @Published var isShowSearchModal: Bool = false
    @Published var isRefresh: Bool = false {
        didSet {
            if isRefresh {
                resetSearchCondition()
            }
        }
    }
    
    @Published var showChargingDate: Bool = false
    @Published var showChargingTime: Bool = false
    @Published var showRadius: Bool = false
    
    @Published var selectChargeType: String = "Instant" {
        didSet {
            showChargingDate = false
            changedChareType()
        }
    }

    @Published var selectChargingTime: Int = 240 {
        didSet {
            changedChargingTime()
        }
    }
    
    @Published var startDay: String = ""
    @Published var startTime: String = ""
    @Published var endDay: String = ""
    @Published var endTime: String = ""
    @Published var textChargingTime: String = ""

    @Published var currentDate: Date = Date()
    @Published var setHour: String = "HH".dateFormatter(formatDate: Date())
    @Published var setMinute: String = "mm".dateFormatter(formatDate: Date())
    
    @Published var startSelectionTime: Int = 0
    @Published var maxSelectionTime: Int = 1410
    @Published var setTime: Int = 0
    @Published var selectDay: Date = Date() {
        didSet {
            if selectChargeType == "Scheduled" {
                changeSelectDay()
            }
        }
    }
    @Published var selectTempDay: Date?
    @Published var selectTime: Int = 0 {
        didSet {
            if selectChargeType == "Scheduled" {
            }
        }
    }
    @Published var searchStartDate: Date?
    @Published var searchEndDate: Date?
    
    @Published var selectRadius: String = "3"
    
    func getCurrentDate(completion: @escaping (Date) -> Void) {
        let request = chargerAPI.requestCurrentDate()
        request.execute(
            onSuccess: { (currentDate) in
                let formatDate = "yyyy-MM-dd HH:mm:ss".toDateFormatter(formatString: currentDate)!
                
                completion(formatDate)
                self.currentDate = formatDate
            },
            //API 호출 실패
            onFailure: { (error) in
                self.result = "error"
                completion(Date())
            }
        )
    }
    
    func setTotalChargingTime() {
        if selectChargingTime >= 60 {
            if selectChargingTime % 60 == 0 {
                textChargingTime = String(selectChargingTime / 60) + "시간"
            }
            else {
                textChargingTime = String(selectChargingTime / 60) + "시간 " + String(selectChargingTime % 60) + "분"
            }
        }
        else {
            textChargingTime = String(selectChargingTime) + "분"
        }
    }
    
    func setSearchDate() {
        let calcDate: Date?
        
        var textStartDay: String = ""
        var textStartTime: String = ""
        var textEndDay: String = ""
        var textEndTime: String = ""
        
        //충전 유형 - 즉시 충전
        if selectChargeType == "Instant" {
            calcDate = Calendar.current.date(byAdding: .minute, value: selectChargingTime, to: currentDate)!
            
            textStartDay = "MM/dd (E)".dateFormatter(formatDate: currentDate)
            textStartTime = "HH:mm".dateFormatter(formatDate: currentDate)
            textEndDay = "MM/dd (E)".dateFormatter(formatDate: calcDate!)
            textEndTime = "HH:mm".dateFormatter(formatDate: calcDate!)
        }
        //충전 유형 - 예약 충전
        else if selectChargeType == "Scheduled" {
            setReservationSearchDate()
            
            calcDate = Calendar.current.date(byAdding: .minute, value: selectChargingTime, to: selectDay)!

            textStartDay = "MM/dd (E)".dateFormatter(formatDate: selectDay)
            textStartTime = "HH:mm".dateFormatter(formatDate: selectDay)
            textEndDay = "MM/dd (E)".dateFormatter(formatDate: selectDay)
            textEndTime = "HH:mm".dateFormatter(formatDate: calcDate!)
        }
        
        startDay = textStartDay
        startTime = textStartTime
        endDay = textEndDay
        endTime = textEndTime
    }
    
    func setReservationSearchDate() {
        getCurrentDate() { (currentDate) in
            self.currentDate = currentDate
            
            let currentDate: String = "yyyyMMdd".dateFormatter(formatDate: self.currentDate)
            var currentHour: Int = Int("HH".dateFormatter(formatDate: self.currentDate))!
            var currentMinute: Int = Int("mm".dateFormatter(formatDate: self.currentDate))!
            
            if currentMinute >= 0 && currentMinute < 30 {
                currentMinute = 30
            }
            else if currentMinute >= 30 && currentMinute < 59 {
                currentHour = currentHour + 1
                currentMinute = 0
            }
            
            let totalMinutesTime = (currentHour * 60) + currentMinute
            
            self.startSelectionTime = totalMinutesTime
            self.maxSelectionTime = 1410
            self.maxSelectionTime = self.maxSelectionTime - (self.selectChargingTime - 30)
            self.selectTime = totalMinutesTime
            
            let stringSearchDate = currentDate + String(format: "%02d", currentHour) + String(format: "%02d", currentMinute) + "00"
            
            let searchDate = "yyyyMMddHHmmss".toDateFormatter(formatString: stringSearchDate)!
            
            self.selectTempDay = searchDate
        }
    }
    
    func changedChareType() {
        setTotalChargingTime()
        
        getCurrentDate() { (currentDate) in
            self.currentDate = currentDate
            
            var calcDate: Date?
            
            var textStartDay: String = ""
            var textStartTime: String = ""
            var textEndDay: String = ""
            var textEndTime: String = ""
            
            //충전 유형 - 즉시 충전
            if self.selectChargeType == "Instant" {
                self.selectDay = self.currentDate
                
                calcDate = Calendar.current.date(byAdding: .minute, value: self.selectChargingTime, to: self.currentDate)!
                
                textStartDay = "MM/dd (E)".dateFormatter(formatDate: self.currentDate)
                textStartTime = "HH:mm".dateFormatter(formatDate: self.currentDate)
                textEndDay = "MM/dd (E)".dateFormatter(formatDate: calcDate!)
                textEndTime = "HH:mm".dateFormatter(formatDate: calcDate!)
            }
            //충전 유형 - 예약 충전
            else if self.selectChargeType == "Scheduled" {
                self.currentDate = currentDate
                
                let currentDate: String = "yyyyMMdd".dateFormatter(formatDate: self.currentDate)
                var currentHour: Int = Int("HH".dateFormatter(formatDate: self.currentDate))!
                var currentMinute: Int = Int("mm".dateFormatter(formatDate: self.currentDate))!
                
                if currentMinute >= 0 && currentMinute < 30 {
                    currentMinute = 30
                }
                else if currentMinute >= 30 && currentMinute < 59 {
                    currentHour = currentHour + 1
                    currentMinute = 0
                }
                
                let totalMinutesTime = (currentHour * 60) + currentMinute
                
                self.startSelectionTime = totalMinutesTime
                self.maxSelectionTime = 1410
                self.maxSelectionTime = self.maxSelectionTime - (self.selectChargingTime - 30)
                self.selectTime = totalMinutesTime
                
                let stringSearchDate = currentDate + String(format: "%02d", currentHour) + String(format: "%02d", currentMinute) + "00"
                
                let searchDate = "yyyyMMddHHmmss".toDateFormatter(formatString: stringSearchDate)!
                
                self.selectTempDay = searchDate
                
                calcDate = Calendar.current.date(byAdding: .minute, value: self.selectChargingTime, to: self.selectTempDay!)!

                textStartDay = "MM/dd (E)".dateFormatter(formatDate: self.selectTempDay!)
                textStartTime = "HH:mm".dateFormatter(formatDate: self.selectTempDay!)
                textEndDay = "MM/dd (E)".dateFormatter(formatDate: self.selectTempDay!)
                textEndTime = "HH:mm".dateFormatter(formatDate: calcDate!)
            }
            
            self.startDay = textStartDay
            self.startTime = textStartTime
            self.endDay = textEndDay
            self.endTime = textEndTime
        }
    }
    
    func changeSelectDay() {
        getCurrentDate() { (currentDate) in
            self.currentDate = currentDate
            
            let currentDay = "yyyyMMdd".dateFormatter(formatDate: currentDate)
            let selectedDay = "yyyyMMdd".dateFormatter(formatDate: self.selectDay)
            
            let calcDate: Date?
            
            var textStartDay: String = ""
            var textStartTime: String = ""
            var textEndDay: String = ""
            var textEndTime: String = ""

            if currentDay == selectedDay {
                let currentDate: String = "yyyyMMdd".dateFormatter(formatDate: self.currentDate)
                var currentHour: Int = Int("HH".dateFormatter(formatDate: self.currentDate))!
                var currentMinute: Int = Int("mm".dateFormatter(formatDate: self.currentDate))!
                
                if currentMinute >= 0 && currentMinute < 30 {
                    currentMinute = 30
                }
                else if currentMinute >= 30 && currentMinute < 59 {
                    currentHour = currentHour + 1
                    currentMinute = 0
                }
                
                let totalMinutesTime = (currentHour * 60) + currentMinute
                
                self.startSelectionTime = totalMinutesTime
                self.selectTime = totalMinutesTime
                
                let stringSearchDate = currentDate + String(format: "%02d", currentHour) + String(format: "%02d", currentMinute) + "00"
                
                let searchDate = "yyyyMMddHHmmss".toDateFormatter(formatString: stringSearchDate)!
                
                self.selectTempDay = searchDate
            }
            else {
                self.selectTempDay = "yyyyMMddHHmmss".toDateFormatter(formatString: selectedDay + "000000")!
                self.selectTime = 0
                self.startSelectionTime = 0
            }
            
            calcDate = Calendar.current.date(byAdding: .minute, value: self.selectChargingTime, to: self.selectTempDay!)!

            textStartDay = "MM/dd (E)".dateFormatter(formatDate: self.selectTempDay!)
            textStartTime = "HH:mm".dateFormatter(formatDate: self.selectTempDay!)
            textEndDay = "MM/dd (E)".dateFormatter(formatDate: self.selectTempDay!)
            textEndTime = "HH:mm".dateFormatter(formatDate: calcDate!)
            
            self.startDay = textStartDay
            self.startTime = textStartTime
            self.endDay = textEndDay
            self.endTime = textEndTime
            
            self.maxSelectionTime = 1410
            self.maxSelectionTime = self.maxSelectionTime - (self.selectChargingTime - 30)
        }
    }
    
    func changedSelectTime() {
        
    }
    
    func changedChargingTime() {
        setTotalChargingTime()
        
        let calcDate: Date?
        
        var textStartDay: String = ""
        var textStartTime: String = ""
        var textEndDay: String = ""
        var textEndTime: String = ""
        
        //충전 유형 - 즉시 충전
        if selectChargeType == "Instant" {
            calcDate = Calendar.current.date(byAdding: .minute, value: selectChargingTime, to: currentDate)!
            
            textStartDay = "MM/dd (E)".dateFormatter(formatDate: currentDate)
            textStartTime = "HH:mm".dateFormatter(formatDate: currentDate)
            textEndDay = "MM/dd (E)".dateFormatter(formatDate: calcDate!)
            textEndTime = "HH:mm".dateFormatter(formatDate: calcDate!)
        }
        //충전 유형 - 예약 충전
        else if selectChargeType == "Scheduled" {
            calcDate = Calendar.current.date(byAdding: .minute, value: selectChargingTime, to: selectTempDay!)!

            textStartDay = "MM/dd (E)".dateFormatter(formatDate: selectTempDay!)
            textStartTime = "HH:mm".dateFormatter(formatDate: selectTempDay!)
            textEndDay = "MM/dd (E)".dateFormatter(formatDate: selectTempDay!)
            textEndTime = "HH:mm".dateFormatter(formatDate: calcDate!)
            
            print(selectChargingTime)
            
            maxSelectionTime = 1410
            maxSelectionTime = maxSelectionTime - (selectChargingTime - 30)
        }
        
        startDay = textStartDay
        startTime = textStartTime
        endDay = textEndDay
        endTime = textEndTime
    }
    

//    func setSearchDate() {
//        if selectChargingTime >= 60 {
//            if selectChargingTime % 60 == 0 {
//                textChargingTime = String(selectChargingTime / 60) + "시간"
//            }
//            else {
//                textChargingTime = String(selectChargingTime / 60) + "시간 " + String(selectChargingTime % 60) + "분"
//            }
//        }
//        else {
//            textChargingTime = String(selectChargingTime) + "분"
//        }
//
//        startDate = "MM/dd (E) HH:mm".dateFormatter(formatDate: setDate)
//
//        let calcEndDate: Date = Calendar.current.date(byAdding: .minute, value: selectChargingTime, to: setDate)!
//
//        endDate = "MM/dd (E) HH:mm".dateFormatter(formatDate: calcEndDate)
//        endTime = "HH:mm".dateFormatter(formatDate: calcEndDate)
//    }
//
//    func changeSelectDay() {
//        let today = "yyyyMMdd".dateFormatter(formatDate: Date())
//        let selectedDay = "yyyyMMdd".dateFormatter(formatDate: selectDay)
//
//        if today == selectedDay {
//            if selectChargeType == "Instant" {
//                setDate = Date()
//                setTime = 0
//            }
//            else {
//                let currentDate: String = "yyyyMMdd".dateFormatter(formatDate: Date())
//                var currentHour: Int = Int("HH".dateFormatter(formatDate: Date()))!
//                var currentMinute: Int = Int("mm".dateFormatter(formatDate: Date()))!
//
//                var changedDate = ""
//
//                if currentMinute >= 0 && currentMinute < 30 {
//                    print("30")
//                    currentMinute = 30
//                }
//                else if currentMinute >= 30 && currentMinute < 59 {
//                    print("00")
//                    currentHour = currentHour + 1
//                    currentMinute = 0
//                }
//
//                setTime = (currentHour * 60) + currentMinute
//                selectTime = String(format: "%02d", currentHour) + String(format: "%02d", currentMinute)
//                changedDate = currentDate + String(format: "%02d", currentHour) + String(format: "%02d", currentMinute) + "00"
//
//                setDate = "yyyyMMddHHmmss".toDateFormatter(formatString: changedDate)!
//            }
//        }
//        else {
//            setDate = "yyyyMMddHHmmss".toDateFormatter(formatString: selectedDay + "000000")!
//            setTime = 0
//            selectTime = "0000"
//        }
//    }
//
//    func changeSearchDate() {
//
//        if selectChargeType == "Instant" {
//            selectDay = Date()
//            selectTime = "0000"
//        }
//        else if selectChargeType == "Scheduled" {
//            let currentDate: String = "yyyyMMdd".dateFormatter(formatDate: Date())
//            var currentHour: Int = Int("HH".dateFormatter(formatDate: Date()))!
//            var currentMinute: Int = Int("mm".dateFormatter(formatDate: Date()))!
//            var changedDate = ""
//
//            if currentMinute >= 0 && currentMinute < 30 {
//                print("30")
//                currentMinute = 30
//            }
//            else if currentMinute >= 30 && currentMinute < 59 {
//                print("00")
//                currentHour = currentHour + 1
//                currentMinute = 0
//            }
//
//            changedDate = currentDate + String(format: "%02d", currentHour) + String(format: "%02d", currentMinute) + "00"
//
//            setDate = "yyyyMMddHHmmss".toDateFormatter(formatString: changedDate)!
//            setTime = (currentHour * 60) + currentMinute
//
//            selectTime = String(format: "%02d", currentHour) + String(format: "%02d", currentMinute)
//        }
//    }
    
    //MARK: - 위치 정보 호출
    func getLoacation() {
        location.getLocation()  //위치 정보 호출
        
        if authStatus == "authorized" || authStatus == "authorizedAlways" || authStatus == "authorizedWhenInUse" {
            latitude = location.latitude!    //위도
            longitude = location.longitude!  //경도
        }
    }
    
    //MARK: - 현재 위치 이동
    func currentLocation() {
        getLoacation()  //현재 위치 정보 호출
        
        //현재 위치 지도 중심으로 이동
        mapView.setMapCenter(
            MTMapPoint(geoCoord: MTMapPointGeo(latitude: latitude, longitude: longitude)),
            animated: true
        )
        
        mapView.setZoomLevel(MTMapZoomLevel(1.0), animated: true)   //Zoom Level 설정
        
        getChargerList(zoomLevel: 1, latitude: latitude, longitude: longitude)
    }
    
    //MARK: - 충전기 목록 조회 실행
    func getChargerList(zoomLevel: Int, latitude: Double, longitude: Double) {
        viewUtil.isLoading = true
        
        charger.removeAll()
        markerItem.removeAll()
        chargers.removeAll()    //조회한 충전기 목록 초기화
        markerItems.removeAll() //조회한 충전기 목록 마커 정보 초기화
        
        let currentDate: String = "yyyy-MM-dd'T'HH:mm:ss".dateFormatter(formatDate: currentDate)

        let parameters = [
            "gpsX": String(longitude),
            "gpsY": String(latitude),
            "startDate": currentDate,
            "endDate": currentDate,
            "distance": selectRadius
        ]

        //충전기 목록 API 호출
        let request = chargerAPI.requestChargerList(parameters: parameters)
        request.execute(
            //API 호출 성공
            onSuccess: { (getChargers) in
                self.viewUtil.isLoading = false
                self.result = "success"
                
                for index in 0..<getChargers.count {
                    let getCharger = getChargers[index]
                    
                    self.charger.updateValue(getCharger.id!, forKey: "chargerId")
                    self.charger.updateValue(getCharger.name!, forKey: "chargerName")
                    self.charger.updateValue(getCharger.address!, forKey: "address")
                    self.charger.updateValue(getCharger.gpsX!, forKey: "longitude")
                    self.charger.updateValue(getCharger.gpsY!, forKey: "latitude")
                    self.charger.updateValue(getCharger.currentStatusType!, forKey: "chargerStatus")
                    self.charger.updateValue(getCharger.searchDateFlag!, forKey: "isSearchDate")
                    
                    self.chargers.append(self.charger)
                }
                
                self.setChargerMarker(chargers: self.chargers)
            },
            //API 호출 실패
            onFailure: { (error) in
                self.viewUtil.isLoading = false
                self.result = "error"
                self.chargers = []
            }
        )
    }
    
    func setChargerMarker(chargers: [[String:Any]]) {
        
        for index in 0..<chargers.count {
            
            let charger = chargers[index]
            let chargerStauts = charger["chargerStatus"] as! String
            
            var markgerImage: String = ""
            var markgerSeletImage: String = ""
            
            if chargerStauts == "READY" {
                markgerImage = "Map-Pin-Blue.png"
                markgerSeletImage = "Map-Pin-Blue-Select.png"
            }
            else if chargerStauts == "RESERVATION" {
                markgerImage = "Map-Pin-Red.png"
                markgerSeletImage = "Map-Pin-Red-Select.png"
            }
            
            markerItem = [
                "markerId": charger["chargerId"]!,
                "markerName": charger["chargerName"]!,
                "address": charger["address"]!,
                "latitude": charger["latitude"]!,
                "longitude": charger["longitude"]!,
                "markerImage": markgerImage,
                "markerSelectImage": markgerSeletImage
            ]
            
            markerItems.append(markerItem)
        }
    }
    
    func selectedCharger(chargerId: Int) {
        let chargerId = String(chargerId)
        
        isFavorites = false
        isShowInfoView = true
        getCharger(chargerId: chargerId)
        getChargerReservation(chargerId: chargerId)
    }
    
    func getCharger(chargerId: String) {
    
        let request = chargerAPI.requestCharger(chargerId: chargerId)
        request.execute(
            onSuccess: { (charger) in
                //print(charger)
                self.chargerName = charger.name!
                self.chargerAddress = charger.address!
                self.chargerUnitPrice = charger.rangeOfFee!
            },
            //API 호출 실패
            onFailure: { (error) in
                self.result = "error"
            }
        )
    }

    func getChargerReservation(chargerId: String) {
        
        let parameters = [
            "page": "1",
            "size": "10",
            "sort": "ASC"
        ]
        
        let request = chargerAPI.requestChargerReservation(chargerId: chargerId, parameters: parameters)
        request.execute(
            onSuccess: { (charger) in
                //print(charger)
                //print(charger.chargerAllowTime)
                self.getAvailableTime(availableTime: charger.chargerAllowTime)
            },
            //API 호출 실패
            onFailure: { (error) in
                print(error)
                self.result = "error"
            }
        )
    }
    
    func getAvailableTime(availableTime: ChargerAllowTime) {
        print(availableTime)
        
        let getOpenTime = availableTime.todayOpenTime
        let openTime = "HH:mm:ss".toDateFormatter(formatString: getOpenTime)
        print(openTime)
        
        print("HHmmss".dateFormatter(formatDate: openTime!))
        
        if "2021-08-27T16:53:00" < "2021-08-27T"+getOpenTime {
            print("tq")
        }
        else {
            print("ttttttttq")
        }
    }
    
    func resetSearchCondition() {
        getCurrentDate() { (currentDate) in
            self.currentDate = currentDate
        }
        selectChargeType = "Instant"
        setTime = 0
        selectDay = Date()
        selectTempDay = selectDay
        selectTime = 0
        startSelectionTime = 0
        maxSelectionTime = 1410
        selectChargingTime = 240
        selectRadius = "3"
        showChargingTime = false
        showRadius = false
    }
}
