//
//  ChargerRegistView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/27.
//

import SwiftUI

struct ChargerRegistView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var chargerRegist = ChargerRegistViewModel()
    
    var body: some View {
        VStack {
            //블루투스 수정 중
        }
        .navigationBarTitle(Text("충전기 등록"), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
    }
}

struct ChargerRegistView_Previews: PreviewProvider {
    static var previews: some View {
        ChargerRegistView()
    }
}
