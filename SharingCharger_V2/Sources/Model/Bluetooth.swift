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
    private var centralManger: CBCentralManager!
    
    var searchInfos: Array<String> = []
    
    @Published var isSwitchedOn = false
    
    override init() {
        super.init()
        BleManager.shared.setBleDelegate(delegate: self)
        //centralManger = CBCentralManager(delegate: self, queue: nil)
        //centralManger.delegate = self
        
        
        
        //self.test()
        //self.test2()
    }
    
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        switch central.state {
//        case .unknown:
//            print("central.state is unknown")
//        case .resetting:
//            print("central.state is resetting")
//        case .unsupported:
//            print("central.state is unsupported")
//        case .unauthorized:
//            print("central.state is unauthorized")
//        case .poweredOff:
//            print("central.state is poweredOff")
//        case .poweredOn:
//            print("central.state is poweredOn")
//        @unknown default:
//            print("central.state default case")
//        }
//
//        if central.state == .poweredOn {
//            isSwitchedOn = true
//        }
//        else {
//            isSwitchedOn = false
//        }
//    }
    
    func test() {
        //BleManager.shared.setBleDelegate(delegate: self)
        
        let bluetoothPermission = BleManager.shared.hasPermission()
        
        print(bluetoothPermission)
    }
    
    func test2() {
        let isOnBluetooth = BleManager.shared.isOnBluetooth()
        
        print(isOnBluetooth)
        
        //BleManager.shared.bleScan()
        
        BleManager.shared.bleScan()
    }
}

extension Bluetooth: BleDelegate {
    func bleResult(code: BleResultCode, result: Any?) {
        print("tttttt")
        
        print(code)
        switch code {
        case .BleScan:
            if let scanData = result as? [String] {
                self.searchInfos = scanData
                for bleID: String in self.searchInfos {
                    print("검색된 충전기 ID : \(bleID)\n")
                }
            }
            
            break
        default:
            break
        }
        

    }
}
