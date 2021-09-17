//
//  Bluetooth.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/03.
//

import Foundation
import Combine
import CoreBluetooth
import EvzBLEKit

class Bluetooth: NSObject, ObservableObject {
    public var didChange = PassthroughSubject<Bluetooth, Never>()
    @Published var searchInfos: Array<String> = []
    
    @Published var isSwitchedOn = false
    @Published var bleNumber: String = ""
    
    @Published var permission: Bool = false
    @Published var isOnBluetooth: Bool = false
    
    override init() {
        super.init()
        
        initData()
    }
    
    private func initData() {
        BleManager.shared.setBleDelegate(delegate: self)
    }
    
    func bluetoothPermission() -> Bool {
        let permission = BleManager.shared.hasPermission()

        return permission
    }
    
    func bluetoothPower() {
        let isOnBluetooth = BleManager.shared.isOnBluetooth()
        
        self.isOnBluetooth = isOnBluetooth
    }
    
    func bluetoothScan() {
        BleManager.shared.bleScan()
    }
    
    func bluetoothScanStop() {
        BleManager.shared.bleScanStop()
    }
}

extension Bluetooth: BleDelegate {
    func bleResult(code: BleResultCode, result: Any?) {
        switch code {
        case .BleScan:
            if let scanData = result as? [String] {
                self.searchInfos = scanData
                
                for bleID: String in self.searchInfos {
                    print("검색된 충전기 ID : \(bleID)\n")
                    bleNumber.append(bleID)
                }
            }
            break
        default:
            break
        }
    }
}
