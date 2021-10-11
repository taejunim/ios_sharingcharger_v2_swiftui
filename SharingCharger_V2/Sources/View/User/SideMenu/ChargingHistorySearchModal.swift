//
//  ChargingHistorySearchModal.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/10/11.
//

import SwiftUI

struct ChargingHistorySearchModal: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var chargingHistory: ChargingHistoryViewModel
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    CloseButton()   //닫기 버튼
                    
                    Spacer()
                    
                    //초기화 버튼
                    RefreshButton() { (isReset) in
                       
                    }
                }
                .padding(.bottom)
                
                //검색 조건 타이틀
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("검색 조건")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                }
                
                VerticalDividerline()
                
                //검색 조건 선택 영역
                ScrollView {
                }
            }
            .padding()
            
        }
        .onAppear {
            
        }
        .onDisappear {
            
        }
    }
}

struct ChargingHistorySearchModal_Previews: PreviewProvider {
    static var previews: some View {
        ChargingHistorySearchModal(chargingHistory: ChargingHistoryViewModel())
    }
}
