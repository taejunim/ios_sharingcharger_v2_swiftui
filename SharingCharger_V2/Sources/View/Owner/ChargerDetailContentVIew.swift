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
        
        VStack(alignment: .leading, spacing: 15) {
        
            let charger = chargerDetailViewModel.charger
            let name: String = charger["name"] ?? ""
            let bleNumber: String = charger["bleNumber"] ?? ""
            let providerCompanyName: String = charger["providerCompanyName"] ?? ""
            let address: String = charger["address"] ?? ""
            let detailAddress: String = charger["detailAddress"] ?? ""
            let parkingFeeFlag: String = charger["parkingFeeFlag"] ?? ""
            let parkingFeeDescription: String = charger["parkingFeeDescription"] ?? ""
            let description: String = charger["description"] ?? ""
            
            Text(name)
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                HStack(spacing: 10){
                    Image("Label-Bluetooth")
                        .resizable()
                        .renderingMode(.template)
                        .padding(3)
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color("#8E44AD"))
                    
                    Text(bleNumber)
                    
                    Spacer()
                }
                
                HStack(spacing: 10){
                    Image("Label-Building")
                        .resizable()
                        .renderingMode(.template)
                        .padding(3)
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color("#8E44AD"))
                    
                    Text(providerCompanyName)
                    
                    Spacer()
                }
                
                VStack(spacing: 3) {
                    HStack(spacing: 10) {
                        Image("Label-Map")
                            .resizable()
                            .renderingMode(.template)
                            .padding(2)
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color("#8E44AD"))
                        
                        Text("주소")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    
                    HStack(spacing: 10) {
                        Spacer().frame(width: 30)
                        
                        VStack(alignment: .leading) {
                            Text(address)
                            
                            Text(detailAddress != "" ? detailAddress : "-")
                                .foregroundColor(Color.gray)
                        }
                        
                                
                        Spacer()
                    }
                }
                
                VStack(spacing: 3) {
                    HStack(spacing: 10){
                        Image("Label-Car")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color("#8E44AD"))
                        
                        VStack(alignment: .leading) {
                            Text("주차")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                    }
                    
                    HStack(spacing: 10) {
                        Spacer().frame(width: 30)
                        
                        VStack(alignment: .leading) {
                            Text(parkingFeeFlag)
                            
                            if parkingFeeDescription != "" {
                                Text(parkingFeeDescription)
                            }
                        }
                                
                        Spacer()
                    }
                }
                
                VStack(spacing: 3) {
                    HStack(spacing: 10){
                        Image("Label-Document")
                            .resizable()
                            .renderingMode(.template)
                            .padding(3)
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color("#8E44AD"))
                        
                        Text("설명")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    
                    HStack(spacing: 10) {
                        Spacer().frame(width: 30)
                        
                        Text(description != "" ? description : "-")
                        
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 10)
        }
        .padding()
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
    
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        return formatter
    }()
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 15) {
                Text("충전기 단가 설정")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("요금 설정")
                    .fontWeight(.semibold)
                
                Picker(
                    selection: $chargerDetailViewModel.stringUnitPrice,
                    label: Text("요금 설정"),
                    content: {
                        Text("2,000").tag("2,000")
                        Text("1,500").tag("1,500")
                        Text("1,000").tag("1,000")
                        Text("직접 입력").tag("")
                    }
                )
                .pickerStyle(SegmentedPickerStyle())
                
                VStack {
                    HStack {
                        Text("현재 단가")
                            .frame(width: 100)
                        
                        Spacer()
                        
                        TextField("현재 단가", value: $chargerDetailViewModel.rangeOfFee, formatter: numberFormatter)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(true)
                    }
                    
                    HStack {
                        Text("변경 단가")
                            .frame(width: 100)
                        
                        Spacer()
                        
                        if chargerDetailViewModel.isDirectlyInput {
                            TextField("변경 단가", value: $chargerDetailViewModel.unitPrice, formatter : numberFormatter)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        else {
                            TextField("변경 단가", text: $chargerDetailViewModel.stringUnitPrice)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(true)
                        }
                    }
                }
            }
            .padding()
            
            Spacer()
            
            ChangeButton(chargerDetailViewModel: chargerDetailViewModel, chargerDetailPage: "price", chargerId: chargerId, viewUtil: viewUtil)
        }
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
        VStack {
            VStack(alignment: .leading, spacing: 15) {
                
                Text("충전기 운영 시간 설정")
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack {
                    Text("현재 운영 시간")
                    
                    Spacer()
                    
                    DatePicker(
                        "",
                        selection: $chargerDetailViewModel.previousOpenTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .labelsHidden()
                    .accentColor(.black)
                    .disabled(true)
                    .environment(\.locale, Locale(identifier:"ko_KR"))  //한국어 언어 변경
                    
                    Text("~")
                    
                    DatePicker(
                        "",
                        selection: $chargerDetailViewModel.previousCloseTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .labelsHidden()
                    .accentColor(.black)
                    .disabled(true)
                    .environment(\.locale, Locale(identifier:"ko_KR"))  //한국어 언어 변경
                }
                .padding(.horizontal, 10)
                
                HStack {
                    Text("변경 예정 시간")
                    
                    Spacer()
                    
                    DatePicker(
                        "",
                        selection: $chargerDetailViewModel.openTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .labelsHidden()
                    .accentColor(.black)
                    .environment(\.locale, Locale(identifier:"ko_KR"))  //한국어 언어 변경
                    
                    Text("~")
                    
                    DatePicker(
                        "",
                        selection: $chargerDetailViewModel.closeTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .labelsHidden()
                    .accentColor(.black)
                    .environment(\.locale, Locale(identifier:"ko_KR"))  //한국어 언어 변경
                }
                .padding(.horizontal, 10)
                
                
                HStack {
                    Text("* 시간 변경시 2일 후 적용됩니다.")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("#C0392B"))
                    
                    Spacer()
                }
                .padding(.top, 10)
            }
            .padding()
            
            Spacer()
            
            ChangeButton(chargerDetailViewModel: chargerDetailViewModel, chargerDetailPage: "time", chargerId: chargerId, viewUtil: viewUtil)
        }
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
    
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("충전기 정보 수정")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("충전기 명")
                            .fontWeight(.semibold)
                        
                        TextField("충전기 명", text: $chargerDetailViewModel.chargerName)
                            .autocapitalization(.none)    //첫 문자 항상 소문자
                            .keyboardType(.namePhonePad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("주소")
                            .fontWeight(.semibold)
                        
                        TextField("주소", text: $chargerDetailViewModel.address)
                            .autocapitalization(.none)    //첫 문자 항상 소문자
                            .keyboardType(.namePhonePad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("상세 주소", text: $chargerDetailViewModel.detailAddress)
                            .autocapitalization(.none)    //첫 문자 항상 소문자
                            .keyboardType(.namePhonePad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("케이블 보유")
                            .fontWeight(.semibold)
                        
                        Picker(
                            selection: $chargerDetailViewModel.cableFlag, //케이블 존재 여부
                            label: Text("케이블 여부"),
                            content: {
                                Text("없음").tag(false)
                                Text("있음").tag(true)
                            }
                        )
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("주차 요금")
                            .fontWeight(.semibold)
                        
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
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("주차 요금 설명")
                            .fontWeight(.semibold)
                        
                        TextField("주차 요금 설명", text: $chargerDetailViewModel.parkingFeeDescription)
                            .autocapitalization(.none)    //첫 문자 항상 소문자
                            .keyboardType(.namePhonePad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding()
            }
            
            Spacer()
            
            ChangeButton(chargerDetailViewModel: chargerDetailViewModel, chargerDetailPage: "information", chargerId: chargerId, viewUtil: viewUtil)
        }
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
        VStack {
            HStack {
                Text("충전 이력")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                OwnerChargerHistorySearchModalButton(chargerDetailViewModel: chargerDetailViewModel)
            }
            .padding([.horizontal, .top])
            
            Dividerline()
            
            if chargerDetailViewModel.histories.count == 0 {
                VStack(spacing: 5) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.largeTitle)
                        .foregroundColor(Color("#BDBDBD"))
                    
                    Text("검색 조건에 맞는 검색 결과가 없습니다.")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                }
                .padding(.horizontal)
            }
            else {
                //포인트 이력
                ScrollView {
                    LazyVStack {
                        let histories = chargerDetailViewModel.histories
                        
                        ForEach(histories, id: \.self) { (history) in
                            
                            VStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    //충전기 명
                                    HStack(spacing: 5) {
                                        Image("Charge-Position")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 25, height: 25)
                                        
                                        Text(history["chargerName"]!)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                
                                    //충전 번호
                                    HStack {
                                        HStack(spacing: 5) {
                                            ZStack {
                                                Circle()
                                                    .foregroundColor(Color("#3498DB"))
                                                    .frame(width: 23 ,height: 23)
                                                    
                                                Image("Charge-Battery")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 23 ,height: 23)
                                            }
                                            .frame(width: 25 ,height: 25)
                                        
                                            Text("충전 번호")
                                                .font(.subheadline)
                                        }
                                        
                                        Text(":")
                                            .font(.subheadline)
                                        
                                        Text(history["id"]!)
                                            .font(.subheadline)
                                        
                                        Spacer()
                                    }
                                
                                    //예약 일자, 충전 일자
                                    HStack(alignment: .top, spacing: 5) {
                                        VStack {
                                            Image("Charge-Clock")
                                                .resizable()
                                                .renderingMode(.template)
                                        }
                                        .frame(width: 25, height: 25)
                                    
                                        VStack(spacing: 5) {
                                            HStack {
                                                Text("예약 일자")
                                                    .font(.subheadline)
                                                
                                                Text(":")
                                                    .font(.subheadline)
                                                
                                                Text(history["reservationPeriod"]!)
                                                    .font(.footnote)
                                                
                                                Spacer()
                                            }
                                            
                                            HStack {
                                                Text("충전 일자")
                                                    .font(.subheadline)
                                                
                                                Text(":")
                                                    .font(.subheadline)
                                                
                                                Text(history["rechargePeriod"]!)
                                                    .font(.footnote)
                                                
                                                Spacer()
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                
                                    //수익 포인트
                                    HStack {
                                        HStack(spacing: 5) {
                                            Image("Charge-Coin")
                                                .resizable()
                                                .renderingMode(.template)
                                                .frame(width: 25, height: 25)
                                        
                                            Text("수익 포인트")
                                                .font(.subheadline)
                                        }
                                        
                                        Text(":")
                                            .font(.subheadline)
                                        
                                        Text(history["ownerPoint"]!)
                                            .font(.subheadline)
                                        
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal)
                                
                                
                                Dividerline()
                            }
                            .onAppear {
                                if chargerDetailViewModel.page <= chargerDetailViewModel.totalPage {
                                    if histories.last == history {
                                        chargerDetailViewModel.page += 1
                                        chargerDetailViewModel.requestOwnerChargeHistory(chargerId: chargerId)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .sheet(
            isPresented: $chargerDetailViewModel.showSearchModal,
            content: {
                OwnerChargerHistorySearchModal(chargerDetailViewModel: chargerDetailViewModel, chargerId: chargerId) //포인트 검색조건 Modal 창
            }
        )
        .onAppear {
            chargerDetailViewModel.page = 1
            chargerDetailViewModel.totalPage = 0
            chargerDetailViewModel.requestOwnerChargeHistory(chargerId: chargerId)
        }
        .onDisappear {
            chargerDetailViewModel.page = 1
            chargerDetailViewModel.totalPage = 0
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
                    .frame(maxWidth: .infinity, minHeight: 40)
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
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(Color("#8E44AD"))   //회원가입 정보 입력에 따른 배경색상 변경
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


struct OwnerChargerDetailMain_Previews: PreviewProvider {
    
    static var previews: some View {
        OwnerChargerDetailMain(chargerDetailViewModel: ChargerDetailViewModel(), chargerId: "")
        OwnerChargerOperateTimeSetting(chargerDetailViewModel: ChargerDetailViewModel(), chargerId: "107")
    }
}
