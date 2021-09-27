//
//  NoticeView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/27.
//

import SwiftUI

struct NoticeView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack{
            
        }
        .navigationBarTitle(Text("공지사항"), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
    }
}

struct NoticeView_Previews: PreviewProvider {
    static var previews: some View {
        NoticeView()
    }
}
