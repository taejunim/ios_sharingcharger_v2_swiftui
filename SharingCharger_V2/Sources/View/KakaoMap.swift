//
//  KakaoMap.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/03.
//

import SwiftUI

struct KakaoMap: View {
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            
            KakaoMapView()
        }
    }
}
	
struct KakaoMapView: UIViewRepresentable {
    func updateUIView(_ uiView: MTMapView, context: Context) {
        
    }
    
    func makeUIView(context: Context) -> MTMapView {
        let view = MTMapView(frame: .zero)
    
        view.setZoomLevel(MTMapZoomLevel(1.0), animated: true)
        view.showCurrentLocationMarker = false
        view.currentLocationTrackingMode = .off
        
        //view.showCurrentLocationMarker = true
        //view.currentLocationTrackingMode = .onWithoutHeading
    
        return view
    }
}

struct KakaoMap_Previews: PreviewProvider {
    static var previews: some View {
        KakaoMap()
    }
}
