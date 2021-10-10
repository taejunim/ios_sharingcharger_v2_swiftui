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
                    RefreshButton() { (isSearchReset) in
                        point.isSearchReset = isSearchReset //초기화 여부
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
                        //조회기간
                        HStack {
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("조회기간")
                                    .font(.body)
                                PointDatePicker(point: point)
                                HStack {
                                    //조회 시작일자
                                    DatePicker(
                                        "",
                                        selection: $point.selectMonth,
                                        displayedComponents: [.date]
                                    )
                                        .labelsHidden()
                                        .accentColor(.black)
                                        .environment(\.locale, Locale(identifier:"ko_KR"))  //한국어 언어 변경
                                    
                                    Spacer()
                                    
                                    Text("-")
                                    
                                    Spacer()
                                    
                                    //조회 종료일자
                                    DatePicker(
                                        "",
                                        selection: $point.currentDate,
                                        displayedComponents: [.date]
                                        
                                    )
                                        .labelsHidden()
                                        .accentColor(.black)
                                        .environment(\.locale, Locale(identifier:"ko_KR"))  //한국어 언어 변경
                                }
                                .frame(maxWidth: .infinity)
                                .disabled(point.chooseDate != "ownPeriod" ? true : false)   //조회기간 선택에 따라 비활성화 변경
                            }
                            Spacer()
                        }
                        
                        VerticalDividerline()
                        //유형
                        HStack {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("유형")
                                    .font(.body)
                                PointTypePicker(point: point)
                            }
                            Spacer()
                        }
                        VerticalDividerline()
                        //정렬
                        HStack {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("정렬")
                                    .font(.body)
                                PointSortPicker(point: point)
                            }
                            Spacer()
                        }
                        
                    }
                    .padding(.top)
                }
            }
            .padding()
            
            PointSearchButton(point: point)
        }
    }
}
//MARK: - 포인트 조회기간 선택 Picker
struct PointDatePicker: View {
    @ObservedObject var point: PointViewModel
    
    var body: some View {
        Picker(
            selection: $point.chooseDate, //조회기간 선택
            label: Text("조회기간 선택"),
            content: {
                Text("1개월").tag("oneMonth")
                Text("3개월").tag("threeMonth")
                Text("6개월").tag("sixMonth")
                Text("직접 선택").tag("ownPeriod")
            }
        )
            .padding(.vertical)
            .pickerStyle(SegmentedPickerStyle())    //Picker Style 변경
        
    }
}
//MARK: - 포인트 유형 선택 Picker
struct PointTypePicker: View {
    @ObservedObject var point: PointViewModel
    
    var body: some View {
        Picker(
            selection: $point.selectPointType, //포인트 유형 선택
            label: Text("유형 선택"),
            content: {
                Text("전체").tag("ALL")
                Text("구매").tag("PURCHASE")
                Text("구매 취소").tag("PURCHASE_CANCEL")
            }
        )
            .padding(.vertical)
            .pickerStyle(SegmentedPickerStyle())    //Picker Style 변경
        Picker(
            selection: $point.selectPointType, //포인트 유형 선택
            label: Text("유형 선택"),
            content: {
                Text("포인트 환전").tag("EXCHANGE")
                Text("포인트 지급").tag("GIVE")
                Text("포인트 회수").tag("WITHDRAW")
            }
        )
            .padding(.vertical)
            .pickerStyle(SegmentedPickerStyle())    //Picker Style 변경
    }
}
//MARK: - 포인트 정렬 선택 Picker
struct PointSortPicker: View {
    @ObservedObject var point: PointViewModel
    
    var body: some View {
        VStack (alignment:.leading){
            Picker(
                selection: $point.selectSort, //포인트 유형 선택
                label: Text("정렬 선택"),
                content: {
                    Text("최신순").tag("DESC")
                    Text("과거순").tag("ASC")
                }
            )
                .pickerStyle(SegmentedPickerStyle())
            
        }.padding(.vertical,25.0)
    }
}

//MARK: - 포인트 목록 검색 버튼
struct PointSearchButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var point: PointViewModel
    
    var body: some View {
        Button(
            action: {
                point.searchPoints.removeAll()                     //조회한 포인트 목록 초기화
                point.page = 1                                     //페이지 번호 초기화
                point.isSearchStart = true                         //조회 시작 여부
                point.getPointHistory(page: point.page)   //포인트 목록 조회
                presentationMode.wrappedValue.dismiss()                     //현재 창 닫기
            },
            label: {
                Text("확인")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(Color("#3498DB"))   //회원가입 정보 입력에 따른 배경색상 변경
            }
        )
    }
}
struct PointSearchModal_Previews: PreviewProvider {
    static var previews: some View {
        PointSearchModal(point: PointViewModel())
    }
}
