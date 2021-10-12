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
    @ObservedObject var viewUtil = ViewUtil()
    @State var chargerId:String
    @State var selectedFee = 0
    
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
                    selection: $chargerDetailViewModel.unitPrice, //주차 요금 여부
                    label: Text("요금 설정"),
                    content: {
                        Text("2,000").tag("2,000")
                        Text("1,500").tag("1,500")
                        Text("1,000").tag("1,000")
                        Text("직접 입력").tag("")
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
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(true)
            }
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Text("변경 단가")
                    .frame(width: 100)
                Spacer()
                TextField("변경 단가", text: $chargerDetailViewModel.unitPrice)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Spacer()
            
            ChangeButton(chargerDetailViewModel: chargerDetailViewModel, chargerDetailPage: "price", chargerId: chargerId, viewUtil: viewUtil)
                
        }
        .padding(10)
        .popup(
            isPresented: $viewUtil.isShowToast,   //팝업 노출 여부
            type: .floater(verticalPadding: 80),
            position: .bottom,
            animation: .easeInOut(duration: 0.0),   //애니메이션 효과
            autohideIn: 2,  //팝업 노출 시간
            closeOnTap: false,
            closeOnTapOutside: false,
            view: {
                viewUtil.toast()
            }
        )
    }
}

//소유주 충전기 운영 시간 설정
struct OwnerChargerOperateTimeSetting: View {
    @ObservedObject var chargerDetailViewModel: ChargerDetailViewModel
    @ObservedObject var viewUtil = ViewUtil()
    @State var chargerId:String
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text("충전기 운영 시간 설정")
                .font(.title)
                .fontWeight(.bold)
                .lineSpacing(30)
            
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Text("현재 운영 시간")
                    .frame(width : 130)
                
                //변경 예정 시간
                DatePicker(
                 "",
                 selection: $chargerDetailViewModel.previousOpenTime,
                    displayedComponents: [.hourAndMinute]
                 )
                 .labelsHidden()
                 .accentColor(.black)
                 .disabled(true)
                 .environment(\.locale, Locale(identifier:"ko_KR"))  //한국어 언어 변경
                Text(" ~ ")
                //변경 예정 시간
                DatePicker(
                 "",
                 selection: $chargerDetailViewModel.previousCloseTime
                    
                    ,
                    displayedComponents: [.hourAndMinute]
                 )
                 .labelsHidden()
                 .accentColor(.black)
                 .disabled(true)
                 .environment(\.locale, Locale(identifier:"ko_KR"))  //한국어 언어 변경
            }
            .frame(height: 50)
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Text("변경 예정 시간")
                    .frame(width : 130)

                //변경 예정 시간
                DatePicker(
                 "",
                 selection: $chargerDetailViewModel.openTime,
                    displayedComponents: [.hourAndMinute]
                 )
                 .labelsHidden()
                 .accentColor(.black)
                 .environment(\.locale, Locale(identifier:"ko_KR"))  //한국어 언어 변경
                Text(" ~ ")
                //변경 예정 시간
                DatePicker(
                 "",
                 selection: $chargerDetailViewModel.closeTime,
                    displayedComponents: [.hourAndMinute]
                 )
                 .labelsHidden()
                 .accentColor(.black)
                 .environment(\.locale, Locale(identifier:"ko_KR"))  //한국어 언어 변경
            }
            .frame(height: 50)
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Text("* 시간 변경시 2일 후 적용됩니다.")
            }
            
            Spacer()
            
            ChangeButton(chargerDetailViewModel: chargerDetailViewModel, chargerDetailPage: "time", chargerId: chargerId, viewUtil: viewUtil)
                
        }.padding(10)
        .popup(
            isPresented: $viewUtil.isShowToast,   //팝업 노출 여부
            type: .floater(verticalPadding: 80),
            position: .bottom,
            animation: .easeInOut(duration: 0.0),   //애니메이션 효과
            autohideIn: 2,  //팝업 노출 시간
            closeOnTap: false,
            closeOnTapOutside: false,
            view: {
                viewUtil.toast()
            }
        )
    }
}

//소유주 충전기 정보 수정
struct OwnerChargerInformationEdit: View {
    @ObservedObject var chargerDetailViewModel: ChargerDetailViewModel
    @ObservedObject var viewUtil = ViewUtil()
    @State var chargerId:String
    
    var body: some View {
    
        VStack(alignment: .leading) {
            
            Text("충전기 정보 수정")
                .font(.title)
                .fontWeight(.bold)
            
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Text("충전기명")
                    .frame(width: 100)
                    .font(.subheadline)
                Spacer()
                TextField("충전기명", text: $chargerDetailViewModel.chargerName)
                    .autocapitalization(.none)    //첫 문자 항상 소문자
                    .keyboardType(.namePhonePad)
                    .font(.subheadline)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Text("주소")
                    .frame(width: 100)
                    .font(.subheadline)
                Spacer()
                TextField("주소", text: $chargerDetailViewModel.address)
                    .autocapitalization(.none)    //첫 문자 항상 소문자
                    .keyboardType(.namePhonePad)
                    .font(.subheadline)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Text("상세 주소")
                    .frame(width: 100)
                    .font(.subheadline)
                Spacer()
                TextField("상세 주소", text: $chargerDetailViewModel.detailAddress)
                    .autocapitalization(.none)    //첫 문자 항상 소문자
                    .keyboardType(.namePhonePad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Text("주차 요금 여부")
                    .frame(width: 100)
                    .font(.subheadline)
                Spacer()
                Picker(
                    selection: $chargerDetailViewModel.parkingFeeFlag, //주차 요금 여부
                    label: Text("주차 요금 여부"),
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
                    .font(.subheadline)
                Spacer()
                Picker(
                    selection: $chargerDetailViewModel.cableFlag, //케이블 존재 여부
                    label: Text("케이블 존재 여부"),
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
                    .font(.subheadline)
                Spacer()
                TextField("주차요금 설명", text: $chargerDetailViewModel.parkingFeeDescription)
                    .autocapitalization(.none)    //첫 문자 항상 소문자
                    .keyboardType(.namePhonePad)
                    .font(.subheadline)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Spacer()
            
            ChangeButton(chargerDetailViewModel: chargerDetailViewModel, chargerDetailPage: "information", chargerId: chargerId, viewUtil: viewUtil)
                
        }.padding(10)
        .popup(
            isPresented: $viewUtil.isShowToast,   //팝업 노출 여부
            type: .floater(verticalPadding: 80),
            position: .bottom,
            animation: .easeInOut(duration: 0.0),   //애니메이션 효과
            autohideIn: 2,  //팝업 노출 시간
            closeOnTap: false,
            closeOnTapOutside: false,
            view: {
                viewUtil.toast()
            }
        )
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
                    let histories = chargerDetailViewModel.histories
                    
                    ForEach(histories, id: \.self) { history in
                    VStack(alignment: .leading){
                        HStack {
                        
                            Image("Charge-Position")
                                .resizable()
                                .frame(width: 20, height: 20)
                        
                            Text("충전기명 : ")
                                .font(.caption)
                            Text(history["chargerName"]!)
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
                            Text(history["id"]!)
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
                                    Text(history["reservationPeriod"]!)
                                        .font(.caption)
                                    Spacer()
                                }
                                HStack{
                                    Text("충전 일자 : ")
                                        .font(.caption)
                                    Text(history["rechargePeriod"]!)
                                        .font(.caption)
                                    Spacer()
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
                            Text(history["ownerPoint"]!)
                                .font(.caption)
                            Spacer()
                        }
                        Dividerline()
                    }}
                }.padding(.vertical, 8.0)
            }
            
        }.padding(10)
        .sheet(
            isPresented: $chargerDetailViewModel.showSearchModal,
            content: {
                OwnerChargerHistorySearchModal(chargerDetailViewModel: chargerDetailViewModel, chargerId: chargerId) //포인트 검색조건 Modal 창
            }
        ).onAppear(){
            chargerDetailViewModel.requestOwnerChargeHistory(chargerId: chargerId)
        }
        
        Spacer()
    }
}

//MARK: - 변경 버튼
struct ChangeButton: View {
    @ObservedObject var chargerDetailViewModel: ChargerDetailViewModel
    @State var chargerDetailPage: String
    @State var chargerId:String
    @ObservedObject var viewUtil: ViewUtil
    var body: some View {
        
        HStack{
            Spacer()
            Button(
                action: {
                    chargerDetailViewModel.viewUtil.dismissKeyboard()  //키보드 닫기
                    
                    switch chargerDetailPage {
                    case "price" :
                        chargerDetailViewModel.requestUpdateUnitPrice(chargerId: chargerId) { (completion) in
                            switch(completion){
                                case "success" :
                                    viewUtil.showToast(isShow: true, message: "충전기 단가 정보 변경에 성공하셨습니다.")
                                break
                                case "failure" :
                                    viewUtil.showToast(isShow: true, message: "충전기 단가 정보 변경에 실패하셨습니다. 다시 시도하여 주십시오.")
                                break
                                default : break
                            }
                        }
                        break
                    case "time" :
                        if(chargerDetailViewModel.closeTime < chargerDetailViewModel.openTime){viewUtil.showToast(isShow: true, message: "운영시간을 확인하여 주십시오.")}
                        else{
                            chargerDetailViewModel.requestUpdateUsageTime(chargerId: chargerId){ (completion) in
                                switch(completion){
                                    case "success" :
                                        viewUtil.showToast(isShow: true, message: "충전기 운영 시간 변경에 성공하셨습니다.")
                                    break
                                    case "failure" :
                                        viewUtil.showToast(isShow: true, message: "충전기 운영 시간 변경에 실패하셨습니다. 다시 시도하여 주십시오.")
                                    break
                                    default : break
                                }
                            }
                        }
                        break
                    case "information" :
                        
                        if(chargerDetailViewModel.chargerName == "" ) { viewUtil.showToast(isShow: true, message: "충전기명을 입력하여 주십시오.") }
                        else if(chargerDetailViewModel.address == "") { viewUtil.showToast(isShow: true, message: "충전기 주소를 입력하여 주십시오.") }
                        else {
                            chargerDetailViewModel.requestUpdateCharger(chargerId: chargerId) { (completion) in
                                switch(completion){
                                    case "success" :
                                        viewUtil.showToast(isShow: true, message: "충전기 정보 변경에 성공하셨습니다.")
                                        break
                                    case "failure" :
                                        viewUtil.showToast(isShow: true, message: "충전기 단가 정보 변경에 실패하셨습니다. 다시 시도하여 주십시오.")
                                        break
                                default : break
                                }
                            }
                        }
                        break
                        default : break
                    }
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
            Spacer()
        }
    }
}

//MARK: - 충전 이력 검색 조건 버튼
struct OwnerChargerHistorySearchModalButton: View {
    @ObservedObject var chargerDetailViewModel: ChargerDetailViewModel
    
    var body: some View {
        Button(
            action: {
                chargerDetailViewModel.showSearchModal = true
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

//MARK: - 충전 이력 검색 조건 확인 버튼
struct OwnerChargerHistorySearchButton: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var chargerDetailViewModel: ChargerDetailViewModel
    @State var chargerId:String
    
    var body: some View {
        Button(
            action: {
                chargerDetailViewModel.histories.removeAll()                     //조회한 포인트 목록 초기화
                chargerDetailViewModel.page = 1                      //페이지 번호 초기화
                chargerDetailViewModel.isSearchStart = true                         //조회 시작 여부
                chargerDetailViewModel.requestOwnerChargeHistory(chargerId: chargerId)
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

//소유주 충전 이력 검색조건
struct OwnerChargerHistorySearchModal: View {
    @ObservedObject var chargerDetailViewModel: ChargerDetailViewModel
    @State var chargerId:String
    
    var body: some View {
        
        VStack {
            HStack {
                CloseButton()   //닫기 버튼
                Spacer()
                //초기화 버튼
                RefreshButton() { (isSearchReset) in
                    chargerDetailViewModel.resetSearchCondition()
                }
            }
            .padding(10)
            
            //검색 조건 선택 영역
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
                        
                        Picker(
                            selection: $chargerDetailViewModel.chooseDate, //조회기간 선택
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
                        
                        HStack {
                            //조회 시작일자
                            DatePicker(
                             "",
                             selection: $chargerDetailViewModel.selectMonth,
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
                             selection: $chargerDetailViewModel.currentDate,
                             displayedComponents: [.date]
                             )
                             .labelsHidden()
                             .accentColor(.black)
                             .environment(\.locale, Locale(identifier:"ko_KR"))  //한국어 언어 변경
                             
                        }
                        .frame(maxWidth: .infinity)
                        .disabled(chargerDetailViewModel.chooseDate != "ownPeriod" ? true : false)   //조회기간 선택에 따라 비활성화 변경
                    }
                    Spacer()
                }
                
                VerticalDividerline()
                //정렬
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("정렬")
                            .font(.body)
                        VStack (alignment:.leading){
                            Picker(
                                selection: $chargerDetailViewModel.selectSort, //포인트 유형 선택
                                label: Text("정렬 선택"),
                                content: {
                                    Text("최신순").tag("DESC")
                                    Text("과거순").tag("ASC")
                                }
                            )
                            .pickerStyle(SegmentedPickerStyle())
                        }.padding(.vertical,25.0)
                    }
                    Spacer()
                }
                .padding(.top)
            }
            .padding()
        }
        Spacer()
        
        OwnerChargerHistorySearchButton(chargerDetailViewModel: chargerDetailViewModel, chargerId: chargerId)
    }
}
