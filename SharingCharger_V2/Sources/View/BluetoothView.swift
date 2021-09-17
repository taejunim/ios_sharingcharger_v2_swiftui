//
//  BluetoothView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/04.
//

import SwiftUI

struct BluetoothView: View {
    @Environment(\.presentationMode) var presentationMode   //Back 버튼 기능 추가에 필요
    @ObservedObject var bluetooth = Bluetooth()
    
    var body: some View {
        VStack {
            Text("Hello, world!")
                .padding()
            
            if bluetooth.isSwitchedOn {
                Text("Bluetooth is switched on")
                    .foregroundColor(.green)
            }
            else {
                Text("Bluetooth is NOT switched on")
                    .foregroundColor(.red)
            }
            
            if bluetooth.permission {
                Text("사용 권한 있음")
            }
            else {
                Text("사용 권한 없음")
            }
            
            Button(
                action: {
                    bluetooth.bluetoothPermission()
                },
                label: {
                    Text("블루투스 사용권한 확인")
                }
            )
            
            if bluetooth.isOnBluetooth {
                Text("블루투스 ON")
            }
            else {
                Text("블루투스 OFF")
            }
            
            Button(
                action: {
                    bluetooth.bluetoothPower()
                },
                label: {
                    Text("블루투스 ON/OFF")
                }
            )
            
            Button(
                action: {
                    bluetooth.bluetoothScan()
                },
                label: {
                    Text("블루투스 검색 시작")
                }
            )
            
            Text(bluetooth.bleNumber)
            
            Button(
                action: {
                    bluetooth.bluetoothScanStop()
                },
                label: {
                    Text("블루투스 검색 중지")
                }
            )
        }
        .navigationBarTitle(Text("회원가입"), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
        .onDisappear {
            
        }
    }
}

struct BluetoothView_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothView()
    }
}
