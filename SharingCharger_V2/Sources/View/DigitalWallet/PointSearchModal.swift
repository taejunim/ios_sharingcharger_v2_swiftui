//
//  PointSearchModal.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/17.
//

import SwiftUI

struct PointSearchModal: View {
    @ObservedObject var point: PointViewModel //Point View Model
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    CloseButton()   //닫기 버튼
                    
                    Spacer()
                    
                    //초기화 버튼
                    RefreshButton() { (isReset) in
                        point.isSearchReset = isReset //초기화 여부
                    }
                }
                .padding(.bottom)
                
                //검색 조건 선택 영역
                ScrollView {
                    VStack {
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
                        
                        //
                        //검색 조건 항목 추가
                        //
                    }
                    .padding(.top)
                }
            }
            .padding()
            
            //
            //하단버튼 추가
            //
        }
    }
}

struct PointSearchModal_Previews: PreviewProvider {
    static var previews: some View {
        PointSearchModal(point: PointViewModel())
    }
}
