//
//  ChargerDetailContentVIew.swift
//  SharingCharger_V2
//
//  Created by 조유영 on 2021/10/08.
//

import SwiftUI
import Combine

//소유주 충전기 상세 메인
struct OwnerChargerDetailMain: View {
    @ObservedObject var chargerDetailViewModel: ChargerDetailViewModel
    @State var chargerId:String
    
    @State var timer: Timer.TimerPublisher = Timer.publish(every: 0.5, on: .main, in: .common)
    
    var body: some View {
        
        VStack(alignment: .leading) {
        
            let charger = chargerDetailViewModel.charger
            let name: String = charger["name"] ?? ""
            let bleNumber: String = charger["bleNumber"] ?? ""
            let providerCompanyName: String = charger["providerCompanyName"] ?? ""
            let address: String = charger["address"] ?? ""
            let parkingFeeFlag: String = charger["parkingFeeFlag"] ?? ""
            let parkingFeeDescription: String = charger["parkingFeeDescription"] ?? ""
            let description: String = charger["description"] ?? ""
            
            Text(name)
                .font(.title)
                .fontWeight(.bold)
            
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Image("Label-Bluetooth")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color("#8E44AD"))
                Text(bleNumber)
                Spacer()
            }
            
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Image("Label-Building")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color("#8E44AD"))
                Text(providerCompanyName)
                Spacer()
            }
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Image("Label-Map")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color("#8E44AD"))
                VStack(alignment: .leading){
                    Text("주소")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(address)
                }
                Spacer()
            }
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Image("Label-Car")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color("#8E44AD"))
                VStack(alignment: .leading){
                    Text("주차")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(parkingFeeFlag)
                    Text(parkingFeeDescription)
                }
                Spacer()
            }.padding(.top)
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Image("Label-Car")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color("#8E44AD"))
                VStack(alignment: .leading){
                    Text("설명")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(description)
                }
                Spacer()
            }
        }
        .padding(10)
        .onAppear{
            startTimer()
        }.onReceive(timer) { _ in
            chargerDetailViewModel.requestOwnerCharger(chargerId: chargerId)
            stopTimer()
        }
    }
    func startTimer() {
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
        _ = timer.connect()
    }
    func stopTimer() {
        timer.connect().cancel()
    }

}

//소유주 충전기 단가 설정
struct OwnerChargerPriceSetting: View {
    @ObservedObject var chargerDetailViewModel: ChargerDetailViewModel
    @State var chargerId:String
    @State var selectedFee = 0
    var fee = ["2,000", "1,500", "1,000", "직접 입력"]
    
    var body: some View {
    
        VStack(alignment: .leading) {
            
            Text("충전기 단가 설정")
                .font(.title)
                .fontWeight(.bold)
            
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Text("요금 설정")
            }
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Picker(
                    selection: $selectedFee, //주차 요금 여부
                    label: Text("요금 설정"),
                    content: {
                        ForEach(0 ..< fee.count) {
                            Text(self.fee[$0])
                        }
                    }
                )
                .pickerStyle(SegmentedPickerStyle())
            }
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Text("현재 단가")
                    .frame(width: 100)
                    .multilineTextAlignment(.leading)
                Spacer()
                TextField("현재 단가", text: $chargerDetailViewModel.rangeOfFee)
                    .autocapitalization(.none)    //첫 문자 항상 소문자
                    .keyboardType(.namePhonePad)
                    .disabled(true)
            }
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Text("변경 단가")
                    .frame(width: 100)
                Spacer()
                TextField("변경 단가", text: $chargerDetailViewModel.rangeOfFee)
                    .autocapitalization(.none)    //첫 문자 항상 소문자
                    .keyboardType(.namePhonePad)
            }
            
            Spacer()
            
            ChangeButton(chargerDetailViewModel: chargerDetailViewModel)
                
        }
        .padding(10)
    }
}

//소유주 충전기 운영 시간 설정
struct OwnerChargerOperateTimeSetting: View {
    @ObservedObject var chargerDetailViewModel: ChargerDetailViewModel
    @State var chargerId:String
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text("충전기 운영 시간 설정")
                .font(.title)
                .fontWeight(.bold)
                .lineSpacing(30)
            
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Text("요금 설정")
            }
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Picker(
                    selection: $chargerDetailViewModel.parkingFeeFlag, //주차 요금 여부
                    label: Text("요금 설정"),
                    content: {
                        Text("없음").tag(false)
                        Text("있음").tag(true)
                        Text("있음").tag(true)
                        
                    }
                )
                    .pickerStyle(SegmentedPickerStyle())
            }
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Text("주소")
                    .frame(width: 100)
                    .multilineTextAlignment(.leading)
                Spacer()
                TextField("주소", text: $chargerDetailViewModel.address)
                    .autocapitalization(.none)    //첫 문자 항상 소문자
                    .keyboardType(.namePhonePad)
            }
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Text("상세 주소")
                    .frame(width: 100)
                Spacer()
                TextField("상세 주소", text: $chargerDetailViewModel.detailAddresss)
                    .autocapitalization(.none)    //첫 문자 항상 소문자
                    .keyboardType(.namePhonePad)
            }
            
            Spacer()
            
            ChangeButton(chargerDetailViewModel: chargerDetailViewModel)
                
        }.padding(10)
    }
}

//소유주 충전기 정보 수정
struct OwnerChargerInformationEdit: View {
    @ObservedObject var chargerDetailViewModel: ChargerDetailViewModel
    @State var chargerId:String
    
    var body: some View {
    
        VStack(alignment: .leading) {
            
            Text("충전기 정보 수정")
                .font(.title)
                .fontWeight(.bold)
            
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Text("충전기명")
                    .frame(width: 100)
                    .multilineTextAlignment(.leading)
                Spacer()
                TextField("충전기명", text: $chargerDetailViewModel.chargerName)
                    .autocapitalization(.none)    //첫 문자 항상 소문자
                    .keyboardType(.namePhonePad)
            }
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Text("주소")
                    .frame(width: 100)
                    .multilineTextAlignment(.leading)
                Spacer()
                TextField("주소", text: $chargerDetailViewModel.address)
                    .autocapitalization(.none)    //첫 문자 항상 소문자
                    .keyboardType(.namePhonePad)
            }
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Text("상세 주소")
                    .frame(width: 100)
                Spacer()
                TextField("상세 주소", text: $chargerDetailViewModel.detailAddresss)
                    .autocapitalization(.none)    //첫 문자 항상 소문자
                    .keyboardType(.namePhonePad)
            }
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Text("주차 요금 여부")
                    .frame(width: 100)
                Spacer()
                Picker(
                    selection: $chargerDetailViewModel.parkingFeeFlag, //주차 요금 여부
                    label: Text("정렬 선택"),
                    content: {
                        Text("없음").tag(false)
                        Text("있음").tag(true)
                    }
                )
                    .pickerStyle(SegmentedPickerStyle())
            }
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Text("케이블 존재 여부")
                    .frame(width: 100)
                Spacer()
                Picker(
                    selection: $chargerDetailViewModel.cableFlag, //케이블 존재 여부
                    label: Text("정렬 선택"),
                    content: {
                        Text("없음").tag(false)
                        Text("있음").tag(true)
                    }
                )
                    .pickerStyle(SegmentedPickerStyle())
            }
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Text("주차요금 설명")
                    .frame(width: 100)
                Spacer()
                TextField("상세 주소", text: $chargerDetailViewModel.parkingFeeDescription)
                    .autocapitalization(.none)    //첫 문자 항상 소문자
                    .keyboardType(.namePhonePad)
            }
            
            Spacer()
            
            ChangeButton(chargerDetailViewModel: chargerDetailViewModel)
                
        }.padding(10)
    }
}

//소유주 충전 이력
struct OwnerChargerHistory: View {
    @ObservedObject var chargerDetailViewModel: ChargerDetailViewModel
    @State var chargerId:String
    
    var body: some View {
    
        VStack(alignment: .leading) {
        
            HStack {
                Text("충전 이력")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                OwnerChargerHistorySearchModalButton(chargerDetailViewModel: chargerDetailViewModel)
            }
            
            //포인트 이력
            ScrollView {
                LazyVStack {
                    
                    VStack(alignment: .leading){
                        HStack {
                        
                            Image("Charge-Position")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 20, height: 20)
                        
                            Text("충전기명 : ")
                                .font(.caption)
                            Text("메티스 충전기 01")
                                .font(.caption)
                            Spacer()
                        }
                    
                        HStack {
                        
                            //배터리 이미지
                            ZStack {
                                Circle()
                                    .foregroundColor(Color("#0081C5"))
                                    .shadow(color: Color("#006AC5"), radius: 1, x: 1.5, y: 1.5)

                                Image("Charge-Battery")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(3)
                            }
                            .frame(width: 20 ,height: 20)
                        
                            Text("충전 번호 : ")
                                .font(.caption)
                            Text("10")
                                .font(.caption)
                            Spacer()
                        }
                    
                        HStack {
                        
                            Image("Charge-Clock")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 20, height: 20)
                        
                            VStack{
                                
                                HStack{
                                    Text("예약 일자 : ")
                                        .font(.caption)
                                    Text("2021-10-06 19:24 ~ 2021-10-06 23:24")
                                        .font(.caption)
                                }
                                HStack{
                                    Text("충전 일자 : ")
                                        .font(.caption)
                                    Text("2021-10-06 19:24 ~ 2021-10-06 23:24")
                                        .font(.caption)
                                }
                            }
                            Spacer()
                        }
                    
                        HStack {
                        
                            Image("Charge-Coin")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 20, height: 20)
                        
                            Text("수익 포인트 : ")
                                .font(.caption)
                            Text("42 p")
                                .font(.caption)
                            Spacer()
                        }
                        Dividerline()
                    }
                }.padding(.vertical, 8.0)
            }
            
        }.padding(10)
        
        Spacer()
    }
}

//MARK: - 변경 버튼
struct ChangeButton: View {
    @ObservedObject var chargerDetailViewModel: ChargerDetailViewModel
    
    var body: some View {
        Button(
            action: {
                chargerDetailViewModel.viewUtil.dismissKeyboard()  //키보드 닫기
            },
            label: {
                Text("button.change".localized())
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(width: 200, height: 50, alignment: .center)
                    .background(Color("#8E44AD"))
            }
        )
    }
}

//MARK: - 충전 이력 검색 조건 버튼
struct OwnerChargerHistorySearchModalButton: View {
    @ObservedObject var chargerDetailViewModel: ChargerDetailViewModel
    
    var body: some View {
        Button(
            action: {
                //point.showSearchModal = true
            },
            label: {
                Image("Button-Slider")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
            }
        )
    }
}
