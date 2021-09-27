//
//  ChargingViewModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/15.
//

import Foundation

///충전 View Model
class ChargingViewModel: ObservableObject {
    @Published var bluetooth = Bluetooth()
    @Published var isConnect: Bool = false
    @Published var isChargingStart = false
    
    let pointAPI = PointAPIService()
    
    func searchChargerBLE() {
        bluetooth.bluetoothPermission()
        
        print(bluetooth.permission)
    }
}