//
//  ChargerSearchModal.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/26.
//

import SwiftUI

//MARK: - 충전기 검색 조건 Modal 화면
struct ChargerSearchModal: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    CloseButton()   //닫기 버튼
                    
                    Spacer()
                    
                    //초기화 버튼
                    RefreshButton() { (isRefresh) in
                        chargerMap.isRefresh = isRefresh
                    }
                }
                .padding(.bottom)
                
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        //총 충전 시간
                        Text("총 " + chargerMap.textChargingTime + " 충전")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        //충전 시작일시 ~ 종료일시
                        Text("\(chargerMap.startDay) \(chargerMap.startTime)~\(chargerMap.endDay) \(chargerMap.endTime)")
                    }
                    
                    Spacer()
                }
                
                //검색 조건 선택 영역
                ScrollView {
                    VStack {
                        ChargeTypePicker(chargerMap: chargerMap)    //충전 유형 선택 Picker
                        
                        VerticalDividerline()
                        
                        ChargingDatePicker(chargerMap: chargerMap)  //충전 일시 선택 Picker
                        
                        VerticalDividerline()
                        
                        ChargingTimePicker(chargerMap: chargerMap)  //충전 시간 선택 Picker
                        
                        VerticalDividerline()
                    }
                    
                    VStack {
                        HStack {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("검색 조건")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                        }
                        
                        VerticalDividerline()
                        
                        RadiusPicker(chargerMap: chargerMap)    //반경 범위 선택 Picker
                        
                        VerticalDividerline()
                    }
                    .padding(.top)
                }
            }
            .padding()
            
            ChargerSearchButton(chargerMap: chargerMap) //충전기 목록 검색 버튼
        }
        .onAppear {
            chargerMap.setTotalChargingTime()
            chargerMap.setSearchDate()
            chargerMap.setReservationSearchDate()
        }
    }
}

//MARK: - 충전 유형 선택 Picker
struct ChargeTypePicker: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        Picker(
            selection: $chargerMap.selectChargeType,
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
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var closedRange: ClosedRange<Date> {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        
        return today...tomorrow
    }
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $chargerMap.showChargingDate,
            content: {
                VStack {
                    DatePicker(
                        "",
                        selection: $chargerMap.selectDay,
                        in: closedRange,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .environment(\.locale, Locale(identifier:"ko_KR"))  //한국어 언어 변경
                    
                    Picker("시간 선택", selection: $chargerMap.selectTime) {
                        //30분 ~ 10시간 (30분 단위)
                        ForEach(Array(stride(from: chargerMap.startSelectionTime, through: chargerMap.maxSelectionTime, by: 30)), id: \.self) { (minute) in

                            let timeHour = minute / 60  //시간 계산
                            let timeMinute = minute % 60    //분 계산

                            let setHour = String(format: "%02d", timeHour)
                            let setMinute = String(format: "%02d", timeMinute)
                            let timeLabel =  setHour + ":" + setMinute

                            Text(timeLabel).tag(setHour+setMinute).font(.subheadline)
                        }
                    }
                }
            },
            label: {
                Button(
                    action: {
                        chargerMap.showChargingDate.toggle()
                    },
                    label: {
                        HStack {
                            fieldTitle(title: "충전 시작 일시", isRequired: false)
                            Spacer()
                            Text("\(chargerMap.startDay) \(chargerMap.startTime)")
                        }
                    }
                )
            }
        )
        .accentColor(chargerMap.selectChargeType == "Instant" ? .gray : .black)
        .disabled(chargerMap.selectChargeType == "Instant" ? true : false)
    }
}

//MARK: - 충전 시간 선택 Picker
struct ChargingTimePicker: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        HStack {
            DisclosureGroup(
                isExpanded: $chargerMap.showChargingTime,
                content: {
                    Picker("충전 시간 선택", selection: $chargerMap.selectChargingTime) {
                        //30분 ~ 10시간 (30분 단위)
                        ForEach(Array(stride(from: 30, through: 600, by: 30)), id: \.self) { (minute) in

                            let timeHour = minute / 60  //시간 계산
                            let timeMinute = minute % 60    //분 계산
                            
                            if minute > 30 {
                                if timeMinute == 0 {
                                    let timeLabel = "\(timeHour)시간"
                                    Text(timeLabel).tag(minute).font(.subheadline)
                                }
                                else {
                                    let timeLabel = "\(timeHour)시간 \(timeMinute)분"
                                    Text(timeLabel).tag(minute).font(.subheadline)
                                }
                            }
                            else {
                                let timeLabel = "\(minute)분"
                                Text(timeLabel).tag(minute).font(.subheadline)
                            }
                        }
                    }
                },
                label: {
                    Button(
                        action: {
                            chargerMap.showChargingTime.toggle()
                        },
                        label: {
                            HStack {
                                fieldTitle(title: "충전 시간", isRequired: false)
                                Spacer()
                                Text(chargerMap.textChargingTime)
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
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        HStack {
            DisclosureGroup(
                isExpanded: $chargerMap.showRadius,
                content: {
                    Picker(
                        selection: $chargerMap.selectRadius,
                        label: Text("범위 선택"),
                        content: {
                            Text("3km").tag("3")
                            Text("10km").tag("10")
                            Text("40km").tag("40")
                        }
                    )
                },
                label: {
                    Button(
                        action: {
                            chargerMap.showRadius.toggle()
                        },
                        label: {
                            HStack {
                                fieldTitle(title: "범위", isRequired: false)
                                Spacer()
                                Text(chargerMap.selectRadius + "km")
                            }
                            .frame(maxWidth: .infinity)
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
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        Button(
            action: {
                chargerMap.currentLocation()    //현재 위치 기준으로 충전기 검색
                presentationMode.wrappedValue.dismiss() //현재 창 닫기
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

struct ChargerSearchModal_Previews: PreviewProvider {
    static var previews: some View {
        ChargerSearchModal(chargerMap: ChargerMapViewModel())
    }
}
