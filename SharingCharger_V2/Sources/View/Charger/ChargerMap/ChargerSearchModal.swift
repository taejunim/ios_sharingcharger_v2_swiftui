//
//  ChargerSearchModal2.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/06.
//

import SwiftUI

//MARK: - 충전기 검색 팝업 창
struct ChargerSearchModal: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var chargerSearch: ChargerSearchViewModel   //충전기 검색 View Model
    @ObservedObject var chargerMap: ChargerMapViewModel //충전기 지도 View Model
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    CloseButton()   //닫기 버튼
                    
                    Spacer()
                    
                    //초기화 버튼
                    RefreshButton() { (isReset) in
                        chargerSearch.isReset = isReset //초기화 여부
                    }
                }
                .padding(.bottom)
                
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        //총 충전 시간
                        Text("총 " + chargerSearch.textChargingTime + " 충전")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        //충전 시작일시 ~ 종료일시
                        Text("\(chargerSearch.textStartDay) \(chargerSearch.textStartTime) ~ \(chargerSearch.textEndDay) \(chargerSearch.textEndTime)")
                    }
                    
                    Spacer()
                }
                
                //검색 조건 선택 영역
                ScrollView {
                    VStack {
                        ChargeTypePicker(chargerSearch: chargerSearch)    //충전 유형 선택 Picker
                        VerticalDividerline()
                        
                        ChargingDatePicker(chargerSearch: chargerSearch)  //충전 일시 선택 Picker
                        VerticalDividerline()
                        
                        ChargingTimePicker(chargerSearch: chargerSearch)  //충전 시간 선택 Picker
                        VerticalDividerline()
                    }
                    
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
                        
                        RadiusPicker(chargerSearch: chargerSearch)    //반경 범위 선택 Picker
                        VerticalDividerline()
                    }
                    .padding(.top)
                }
            }
            .padding()
            
            ChargerSearchButton(chargerSearch: chargerSearch, chargerMap: chargerMap) //충전기 목록 검색 버튼
        }
        .onAppear {
            //충전기 검색 조건의 충전 타입이 '예약 충전'인 경우
            if chargerSearch.searchType == "Scheduled" {
                chargerSearch.selectChargeType = chargerSearch.searchType   //충전 타입
                chargerSearch.selectStartDate = chargerSearch.selectTempStartDate!  //시작 일자 선택
                chargerSearch.selectStartTime = chargerSearch.selectTempStartTime   //시작 시간 선택
            }
            else {
                chargerSearch.changeStartTimeRange()    //충전 시작 시간 범위 설정
            }
        }
        .onDisappear {
            chargerSearch.showChargingDate = false  //충전 시작일자 선택 항목 닫기
            chargerSearch.showChargingTime = false  //충전 시간 선택 항목 닫기
            chargerSearch.showRadius = false    //조회 반경범위 선택 항목 닫기
            chargerMap.isShowSearchModal = false
        }
    }
}

//MARK: - 충전 유형 선택 Picker
struct ChargeTypePicker: View {
    @ObservedObject var chargerSearch: ChargerSearchViewModel
    
    var body: some View {
        Picker(
            selection: $chargerSearch.selectChargeType, //충전 유형 선택
            label: Text("충전 선택"),
            content: {
                Text("즉시 충전").tag("Instant")
                Text("예약 충전").tag("Scheduled")
            }
        )
        .padding(.vertical)
        .pickerStyle(SegmentedPickerStyle())    //Picker Style 변경
    }
}

//MARK: - 충전 일시 선택 Picker
struct ChargingDatePicker: View {
    @ObservedObject var chargerSearch: ChargerSearchViewModel
    
    //충전 시작일자 선택 범위
    var closedRangeDate: ClosedRange<Date> {
        var today = chargerSearch.currentDate
        let todayTime = Int("HHmm".dateFormatter(formatDate: today))

        //현재 시간이 23시 30분 이전인 경우
        if todayTime! < 2330 {
            let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: today)    //현재 일자 + 1일

            return today...nextDay!
        }
        //현재 시간이 23시 30분 이후인 경우
        else {
            today = Calendar.current.date(byAdding: .day, value: 1, to: today)! //현재 일자 + 1일
            let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: today)    //현재 일자 + 2일

            return today...nextDay!
        }
    }
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $chargerSearch.showChargingDate,
            content: {
                HStack {
                    DatePicker(
                        "충전 시작 일시 선택",
                        selection: $chargerSearch.selectStartDate,
                        in: closedRangeDate,
                        displayedComponents: .date
                    )
                    .labelsHidden() //라벨 비활성화
                    .environment(\.locale, Locale(identifier:"ko_KR"))  //한국어 언어 변경
                    
                    Picker("충전 시작 시간 선택", selection: $chargerSearch.selectStartTime) {
                        //시간 선택 - 00:00 ~ 23:30 (30분 단위)
                        ForEach(Array(stride(from: 0, to: 86400, by: 1800)), id: \.self) { (second) in

                            let timeHour: Int = second / 3600    //시간 계산
                            let timeMinute: Int = second % 3600 / 60   //분 계산

                            let time: String = String(format: "%02d", timeHour) + String(format: "%02d", timeMinute)    //HHmm
                            let timeLabel: String = String(format: "%02d", timeHour) + ":" + String(format: "%02d", timeMinute) //HH:mm
                            let formatStartDate: String = "yyyyMMdd".dateFormatter(formatDate: chargerSearch.selectStartDate)   //yyyyMMdd

                            //현재 일자와 충전 시작일자를 비교하여 선택 가능한 충전 시작 시간만 표출
                            if chargerSearch.formatCurrentDay == formatStartDate {
                                
                                //시작 시간 최소 범위와 같거나 큰 경우만
                                if chargerSearch.startTimeMinRange <= second {
                                    Text(timeLabel).tag(time)
                                }
                            }
                            else {
                                //시작 시간 최대 범위와 같거나 작은 경우만
                                if chargerSearch.startTimeMaxRange >= second {
                                    Text(timeLabel).tag(time)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 2)
                    .padding(.horizontal, 40)
                    .background(Color("#EFEFF0"))
                    .cornerRadius(7)
                }
                .padding(.vertical, 10)
            },
            label: {
                Button(
                    action: {
                        chargerSearch.showChargingDate.toggle()
                    },
                    label: {
                        HStack {
                            fieldTitle(title: "충전 시작 일시", isRequired: false)
                            Spacer()
                            Text("\(chargerSearch.textStartDay) \(chargerSearch.textStartTime)")
                        }
                    }
                )
            }
        )
        .accentColor(chargerSearch.selectChargeType == "Instant" ? .gray : .black)  //충전 유형 선택에 따라 색상 변경
        .disabled(chargerSearch.selectChargeType == "Instant" ? true : false)   //충전 유형 선택에 따라 비활성화 변경
    }
}

//MARK: - 충전 시간 선택 Picker
struct ChargingTimePicker: View {
    @ObservedObject var chargerSearch: ChargerSearchViewModel
    
    var body: some View {
        HStack {
            DisclosureGroup(
                isExpanded: $chargerSearch.showChargingTime,
                content: {
                    Picker("충전 시간 선택", selection: $chargerSearch.selectChargingTime) {
                        //30분 ~ 10시간 (30분 단위)
                        ForEach(Array(stride(from: 1800, through: 36000, by: 1800)), id: \.self) { (second) in
                            
                            let timeHour: Int = second / 3600    //시간 계산
                            let timeMinute: Int = second % 3600 / 60   //분 계산
                            let time: String = String(format: "%02d", timeHour) + String(format: "%02d", timeMinute) + "00" //HHmmss
                            
                            //시간 단위 없는 경우
                            if timeHour == 0 {
                                let timeLabel: String = String(format: "%02d", timeMinute) + "분"
                                Text(timeLabel).tag(time).font(.subheadline)
                            }
                            else {
                                //분 단위 없는 경우
                                if timeMinute == 0 {
                                    let timeLabel = String(timeHour) + "시간"
                                    Text(timeLabel).tag(time).font(.subheadline)
                                }
                                //분 단위 있는 경우
                                else {
                                    let timeLabel = String(timeHour) + "시간 " + String(format: "%02d", timeMinute) + "분"
                                    Text(timeLabel).tag(time).font(.subheadline)
                                }
                            }
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 250, height: 70)
                    .clipped()
                    .padding(.vertical, 10)
                },
                label: {
                    Button(
                        action: {
                            chargerSearch.showChargingTime.toggle()
                        },
                        label: {
                            HStack {
                                fieldTitle(title: "충전 시간", isRequired: false)
                                Spacer()
                                Text(chargerSearch.textChargingTime)
                            }
                        }
                    )
                }
            )
            .accentColor(.black)
        }
    }
}

//MARK: - 반경 범위 선택 Picker
struct RadiusPicker: View {
    @ObservedObject var chargerSearch: ChargerSearchViewModel
    
    var body: some View {
        HStack {
            DisclosureGroup(
                isExpanded: $chargerSearch.showRadius,
                content: {
                    Picker(
                        selection: $chargerSearch.selectRadius, //반경범위 선택
                        label: Text("범위 선택"),
                        content: {
                            Text("3km").tag("3").font(.subheadline)
                            Text("10km").tag("10").font(.subheadline)
                            Text("40km").tag("40").font(.subheadline)
                        }
                    )
                    .pickerStyle(.wheel)
                    .frame(width: 250, height: 70)
                    .clipped()
                    .padding(.vertical, 10)
                },
                label: {
                    Button(
                        action: {
                            chargerSearch.showRadius.toggle()
                        },
                        label: {
                            HStack {
                                fieldTitle(title: "범위", isRequired: false)
                                Spacer()
                                Text(chargerSearch.selectRadius + "km")
                            }
                        }
                    )
                }
            )
            .accentColor(.black)
        }
    }
}

//MARK: - 충전기 목록 검색 버튼
struct ChargerSearchButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var chargerSearch: ChargerSearchViewModel
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        Button(
            action: {
                let search = chargerSearch.setSearchCondition() //검색조건 설정
                chargerMap.radius = search.radius   //반경범위 설정
                chargerMap.currentLocation(search.startDate, search.endDate)    //현재 위치 이동 후, 충전기 목록 조회
                
                presentationMode.wrappedValue.dismiss() //현재 창 닫기
            },
            label: {
                Text("확인")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(Color("#3498DB"))
            }
        )
    }
}

struct ChargerSearchModal_Previews: PreviewProvider {
    static var previews: some View {
        ChargerSearchModal(chargerSearch: ChargerSearchViewModel(), chargerMap: ChargerMapViewModel())
    }
}
