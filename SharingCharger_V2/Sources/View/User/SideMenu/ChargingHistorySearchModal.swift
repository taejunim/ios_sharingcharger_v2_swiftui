//
//  ChargingHistorySearchModal.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/10/11.
//

import SwiftUI

//MARK: - 충전 이력 검색조건 팝업창
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
                        if isReset {
                            chargingHistory.reset() //검색 조건 및 결과 초기화
                        }
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
                    VStack(alignment: .leading, spacing: 10) {
                        Text("검색 기간")
                        
                        ChargingPeriodPicker(chargingHistory: chargingHistory)  //기간 선택
                        
                        ChargingSearchDatePicker(chargingHistory: chargingHistory)  //검색 일자 선택
                    }
                    
                    VerticalDividerline()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("정렬 순서")
                        
                        HistorySortPicker(chargingHistory: chargingHistory) //정렬 순서 선택
                    }
                    
                    VerticalDividerline()
                }
            }
            .padding()
            
            HistorySearchButton(chargingHistory: chargingHistory)   //검색 실행 버튼
        }
        .onAppear {
            //현재일자 호출
            chargingHistory.getCurrentDate() { currentDate in
                chargingHistory.currentDate = currentDate
            }
        }
    }
}

//MARK: - 충전 이력 검색 기간 선택
struct ChargingPeriodPicker: View {
    @ObservedObject var chargingHistory: ChargingHistoryViewModel
    
    var body: some View {
        Picker(
            selection: $chargingHistory.selectPeriod,
            label: Text("조회 기간"),
            content: {
                Text("1개월").tag("oneMonth")
                Text("3개월").tag("threeMonths")
                Text("6개월").tag("sixMonths")
                Text("직접선택").tag("directly")
            }
        )
        .pickerStyle(SegmentedPickerStyle())    //Picker Style 변경
    }
}

//MARK: - 충전 이력 검색 일자 선택
struct ChargingSearchDatePicker: View {
    @ObservedObject var chargingHistory: ChargingHistoryViewModel
    
    var body: some View {
        HStack {
            DatePicker(
                "검색 시작일자",
                selection: $chargingHistory.searchStartDate,
                in: ...chargingHistory.searchEndDate,
                displayedComponents: .date
            )
            .labelsHidden() //라벨 비활성화
            .environment(\.locale, Locale(identifier:"ko_KR"))  //한국어 언어 변경
            
            Spacer()
            
            Text("~")
                .foregroundColor(!chargingHistory.isDirectlySelect ? Color.gray : Color.black)
            
            Spacer()
            
            DatePicker(
                "검색 종료일자",
                selection: $chargingHistory.searchEndDate,
                in: ...chargingHistory.currentDate,
                displayedComponents: .date
            )
            .labelsHidden() //라벨 비활성화
            .environment(\.locale, Locale(identifier:"ko_KR"))  //한국어 언어 변경
        }
        .accentColor(!chargingHistory.isDirectlySelect ? Color.gray : Color.black)
        .disabled(!chargingHistory.isDirectlySelect ? true : false)
    }
}

//MARK: - 정렬 순서 선택
struct HistorySortPicker: View {
    @ObservedObject var chargingHistory: ChargingHistoryViewModel
    
    var body: some View {
        Picker(
            selection: $chargingHistory.selectSort,
            label: Text("조회 기간"),
            content: {
                Text("최신순").tag("DESC")
                Text("과거순").tag("ASC")
            }
        )
        .pickerStyle(SegmentedPickerStyle())    //Picker Style 변경
    }
}

//MARK: - 충전 이력 검색 버튼
struct HistorySearchButton: View {
    @ObservedObject var chargingHistory: ChargingHistoryViewModel
    
    var body: some View {
        Button(
            action: {
                chargingHistory.page = 1    //페이지 초기화
                chargingHistory.getChargingHistory()    //충전 이력 조회
                
                chargingHistory.isShowSearchModal = false   //검색 조건 팝업창 닫기
            },
            label: {
                Text("확인")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(Color("#3498DB"))
            }
        )
    }
}

struct ChargingHistorySearchModal_Previews: PreviewProvider {
    static var previews: some View {
        ChargingHistorySearchModal(chargingHistory: ChargingHistoryViewModel())
    }
}
