//
//  MapView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/23.
//

import SwiftUI

struct MapView: UIViewRepresentable {
    @Binding var mapView: MTMapView
    @Binding var latitude: Double  //위도
    @Binding var longitude: Double //경도
    @Binding var markerItems: [[String:Any]]
    
    var getAddress: (String) -> ()  //지도 중심점 주소
    var movedPoint: (Double, Double) -> ()  //지도 이동 후 중심의 좌표
    var changedZoomLevel: (Int) -> ()   //변경된 확대, 축소 레벨
    var selectedMarker: (Int) -> () //선택된 마커
    var isTapOn: (Bool) -> ()   //지도 터치 여부
    
    class Coordinator: NSObject, MTMapViewDelegate {
        var mapView: MapView
        
        init(mapView: MapView) {
            self.mapView = mapView
        }
        
        let authStatus = Location().getAuthStatus() //위치 서비스 권한 상태
        let apiKey = Bundle.main.infoDictionary!["KAKAO_APP_KEY"] as! String    //카카오맵 앱 키

        //MARK: - 지도 화면 이동 종료 후 실행
        func mapView(_ mapView: MTMapView!, finishedMapMoveAnimation mapCenterPoint: MTMapPoint!) {
            //위치 서비스 권한이 없는 경우 주소 호출 예외처리
            if authStatus != "notDetermined" && authStatus != "restricted" && authStatus != "denied" {
                guard let getAddress = MTMapReverseGeoCoder.findAddress(for: mapCenterPoint, withOpenAPIKey: apiKey) else { return }
                
                self.mapView.getAddress(getAddress)
            }
        }
        
        //MARK: - 지도 드래그 이동 종료 후 실행
        func mapView(_ mapView: MTMapView!, dragEndedOn mapPoint: MTMapPoint!) {
            guard let getAddress = MTMapReverseGeoCoder.findAddress(for: mapPoint, withOpenAPIKey: apiKey) else { return }
            self.mapView.getAddress(getAddress)

            mapView.removeAllPOIItems() //POIItem 정보 삭제

            let latitude = mapPoint.mapPointGeo().latitude  //위도
            let longitude = mapPoint.mapPointGeo().longitude    //경도
            
            self.mapView.movedPoint(latitude, longitude)    //지도 이동 후 중심의 위경도
        }
        
        //MARK: - 지도 확대/축소 레벨 변경된 경우 실행
        func mapView(_ mapView: MTMapView!, zoomLevelChangedTo zoomLevel: MTMapZoomLevel) {
            self.mapView.changedZoomLevel(Int(zoomLevel))   //Zoom Level
        }
        
        //MARK: - 지도 마커 선택 시 실행
        func mapView(_ mapView: MTMapView!, selectedPOIItem poiItem: MTMapPOIItem!) -> Bool {
            mapView.setMapCenter(poiItem.mapPoint, animated: true)  //지도 중심으로 이동
            
            let markerId = poiItem.tag  //마커 ID
            self.mapView.selectedMarker(markerId)   //선택된 마커 ID
            
            return true
        }
        
        //MARK: - 지도 터치 시 실행
        func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
            self.mapView.isTapOn(true)
        }
    }
    
    //MARK: - Map UI View 생성
    func makeUIView(context: Context) -> MTMapView {
        var mapPointGeo = MTMapPointGeo()
        mapView.delegate = context.coordinator

        mapPointGeo.latitude = latitude    //위도
        mapPointGeo.longitude = longitude  //경도
        mapView.setMapCenter(MTMapPoint(geoCoord: mapPointGeo), animated: true) //좌표 값으로 지도 중심 이동
        mapView.setZoomLevel(MTMapZoomLevel(0), animated: true)   //Zoom Level 설정
        mapView.showCurrentLocationMarker = false   //현재 위치 마커 표시 - False
        mapView.currentLocationTrackingMode = .off  //현재 위치 트래킹 모드 - Off
        
        return mapView
    }

    let apiKey = Bundle.main.infoDictionary!["KAKAO_APP_KEY"] as! String    //카카오맵 앱 키
    
    //MARK: - Map UI View 업데이트
    func updateUIView(_ uiView: MTMapView, context: Context) {
//        var poiItem: MTMapPOIItem?
//        var poiItems: [MTMapPOIItem] = []
//        var mapPoint: MTMapPoint?
//
//        for index in 0..<markerItems.count {
//            let markerItem = markerItems[index]
//
//            let latitude = markerItem["latitude"] as? Double
//            let longitude = markerItem["longitude"] as? Double
//            mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: latitude!, longitude: longitude!))
//
//            poiItem = MTMapPOIItem()
//            poiItem?.tag = markerItem["markerId"] as! Int
//            poiItem?.itemName = markerItem["markerName"] as? String
//            poiItem?.mapPoint = mapPoint
//            poiItem?.markerType = .customImage
//            poiItem?.customImage = UIImage(named: markerItem["markerImage"] as! String)?.resize(width: 40)
//            poiItem?.markerSelectedType = .customImage
//            poiItem?.customSelectedImage = UIImage(named: markerItem["markerSelectImage"] as! String)?.resize(width: 40)
//            poiItem?.customImageAnchorPointOffset = .init(offsetX: 40, offsetY: 0)
//            poiItem?.showDisclosureButtonOnCalloutBalloon = false
//
//            poiItems.append(poiItem!)
//        }
//
//        uiView.addPOIItems(poiItems)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(mapView: self)
    }
}


