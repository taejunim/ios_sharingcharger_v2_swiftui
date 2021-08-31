//
//  BluetoothView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/04.
//

import SwiftUI

struct BluetoothView: View {
    @Environment(\.presentationMode) var presentationMode   //Back 버튼 기능 추가에 필요
    @ObservedObject var signUpViewModel: SignUpViewModel
    @ObservedObject var blueTooth = Bluetooth()
    
    var body: some View {
        VStack {
            Text("Hello, world!")
                .padding()
            
            if blueTooth.isSwitchedOn {
                Text("Bluetooth is switched on")
                    .foregroundColor(.green)
            }
            else {
                Text("Bluetooth is NOT switched on")
                    .foregroundColor(.red)
            }
            
            Button(
                action: {
                    blueTooth.test()
                    blueTooth.test2()
                },
                label: {
                    Text("조회 시작")
                    
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
        BluetoothView(signUpViewModel: SignUpViewModel())
    }
}
