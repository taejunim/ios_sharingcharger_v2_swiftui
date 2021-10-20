//
//  ChargerRegistView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/27.
//

import SwiftUI

//MARK: - 충전기 등록 화면
struct ChargerRegistView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewUtil = ViewUtil()
    
    @ObservedObject var regist = ChargerRegistViewModel()   //충전기 등록 View Model
    @ObservedObject var bluetooth = ChargingViewModel() //충전 View Model - Bluetooth 기능 사용
    
    var body: some View {
        ZStack {
            VStack {
                RegistStepGuide(regist: regist) //상단 등록 단계 안내
                
                Spacer()
                
                //1번째 단계
                if regist.currentStep == 1 {
                    FindChargerBLE(regist: regist, bluetooth: bluetooth)    //충전기 BLE 찾기
                }
                //2번째 단계
                else if regist.currentStep == 2 {
                    ChargerBasicInfo(regist: regist)    //충전기 기초 정보
                }
                //3번째 단계
                else if regist.currentStep == 3 {
                    ChargerAdditionalInfo(regist: regist)   //충전기 추가 정보
                }
                
                Spacer()
                
                //버튼 영역
                HStack(spacing: 2) {
                    RegistPreviousButton(regist: regist)    //이전 버튼
                    
                    if regist.currentStep < 3 {
                        RegistNextButton(viewUtil: viewUtil, regist: regist)    //다음 버튼
                    }
                    else {
                        ChargerRegistButton(viewUtil: viewUtil, regist: regist) //충전기 등록 버튼
                    }
                }
            }
            
            //블루투스 검색 완료된 상태 or BLE 목록 모달 창 호출 시
            if bluetooth.isSearch || regist.isShowBLEModal {
                FindChargerBLEModal(regist: regist, bluetooth: bluetooth)   //검색한 충전기 BEL 번호 모달 창
            }
            
            //블루투스 검색 중 or 로딩 호출 시
            if bluetooth.isLoading || regist.isLoading {
                viewUtil.loadingView()  //로딩 화면
            }
        }
        .navigationBarTitle(Text("충전기 등록"), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
        .onAppear {
            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(named: "#8E44AD")    //Picker 배경 색상
        }
        .onDisappear {
            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(named: "#3498DB")    //Picker 배경 색상
        }
        .popup(
            isPresented: $regist.isShowToast,   //팝업 노출 여부
            type: .floater(verticalPadding: 80),
            position: .bottom,
            animation: .easeInOut(duration: 0.0),   //애니메이션 효과
            autohideIn: 2,  //팝업 노출 시간
            closeOnTap: false,
            closeOnTapOutside: false,
            view: {
                viewUtil.toastPopup(message: regist.showMessage)
            }
        )
    }
}

//MARK: - 등록 단계 안내
struct RegistStepGuide: View {
    @ObservedObject var regist: ChargerRegistViewModel
    
    var body: some View {
        HStack {
            //1단계 - 충전기 찾기
            VStack {
                ZStack {
                    Circle()
                        .foregroundColor(regist.currentStep > 1 ? Color("#8E44AD") : Color("#674EA7"))

                    if regist.currentStep == 1 {
                        Text("1")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                    }
                    else if regist.currentStep > 1 {
                        Image(systemName: "checkmark")
                            .font(Font.system(size: 25, weight: .semibold))
                            .foregroundColor(Color.white)
                    }
                }
                .frame(width: 50 ,height: 50)
                .shadow(color: Color.gray, radius: 2, x: 1.5, y: 1.5)
                
                Text("충전기 찾기")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(regist.currentStep > 1 ? Color("#BDBDBD") : Color("#674EA7"))
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            //2단계 - 충전기 기초 정보
            VStack {
                ZStack {
                    Circle()
                        .foregroundColor(
                            regist.currentStep == 2 ? Color("#674EA7") : (regist.currentStep > 2 ? Color("#8E44AD") : Color("#BDBDBD"))
                        )
                    
                    if regist.currentStep <= 2 {
                        Text("2")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                    }
                    else if regist.currentStep > 2 {
                        Image(systemName: "checkmark")
                            .font(Font.system(size: 25, weight: .semibold))
                            .foregroundColor(Color.white)
                    }
                }
                .frame(width: 50 ,height: 50)
                .shadow(color: Color.gray, radius: 2, x: 1.5, y: 1.5)
                
                Text("충전기 기초 정보")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(regist.currentStep == 2 ? Color("#674EA7") : Color("#BDBDBD"))
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            //3단계 - 충전기 추가 정보
            VStack {
                ZStack {
                    Circle()
                        .foregroundColor(regist.currentStep < 3 ? Color("#BDBDBD") : Color("#674EA7"))
                    
                    Text("3")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                }
                .frame(width: 50 ,height: 50)
                .shadow(color: Color.gray, radius: 2, x: 1.5, y: 1.5)
                
                Text("충전기 추가 정보")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(regist.currentStep < 3 ? Color("#BDBDBD") : Color("#674EA7"))
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .padding(.top)
    }
}

//MARK: - 충전기 BLE 찾기
struct FindChargerBLE: View {
    @ObservedObject var regist: ChargerRegistViewModel
    @ObservedObject var bluetooth: ChargingViewModel
    
    var body: some View {
        VStack {
            Text("충전기 전원을 켜고\n하단의 '충전기 검색' 버튼을 눌러주세요.")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            HStack {
                Text("충전기 BLE 번호")
                    .fontWeight(.bold)
                
                Spacer()
                
                //선택된 충전기 BLE 번호 버튼
                Button(
                    action: {
                        regist.isShowBLEModal = true    //충전기 BLE 목록 모달 창 호출
                    },
                    label: {
                        //선택된 충전기 BLE 번호
                        Text(regist.selectBLENumber)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .frame(width: 200)
                            .background(regist.chargerBLEList == [] ? Color("#F2F2F2") : Color("#8E44AD"))
                            .cornerRadius(5.0)
                            .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                    }
                )
                .disabled(regist.chargerBLEList == [] ? true : false)
            }
            .padding(.horizontal)
            
            Spacer()
            
            //충전기 검색 버튼
            Button(
                action: {
                    bluetooth.isLoading = true
                    
                    //블루투스 사용 권한 확인 - 권한 있음
                    if bluetooth.checkPermission() {
                        
                        //블루투스 전원 확인 - Power ON
                        if bluetooth.checkBluetoothPower() {
                            bluetooth.startBluetoothScan()    //블루투스 스캔 시작
                        }
                        //블루투스 전원 확인 - Power OFF
                        else {
                            bluetooth.isLoading = false
                            regist.toastMessage(message: "블루투스 전원이 꺼져 있습니다.\n블루투스 전원을 확인해주세요.")    //블루투스 전원 확인 메시지
                        }
                    }
                    //블루투스 사용 권한 확인 - 권한 없음
                    else {
                        bluetooth.isLoading = false
                        regist.toastMessage(message: "블루투스 사용 권한이 없습니다.\n블루투스 권한 설정을 확인해주세요.") //블루투스 사용 권한 확인 메시지
                    }
                },
                label: {
                    Text("충전기 검색")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(Color("#8E44AD"))
                        .cornerRadius(5.0)
                        .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                }
            )
            .padding()
        }
        .padding()
    }
}

//MARK: - 검색된 충전기 BLE 모달 창
struct FindChargerBLEModal: View {
    @ObservedObject var regist: ChargerRegistViewModel
    @ObservedObject var bluetooth: ChargingViewModel
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack {
                VStack(spacing: 0) {
                    HStack{
                        Text("충전기 BLE 번호")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HorizontalDividerline()
                    
                    Spacer()
                    
                    ScrollView {
                        LazyVStack {
                            //충전기 BLE 목록
                            ForEach(regist.chargerBLEList, id:\.self) { (chargerBLE) in
                                //충전기 BLE 별 선택 버튼
                                Button(
                                    action: {
                                        regist.registChargerId = chargerBLE["chargerId"]!   //충전기 ID
                                        regist.selectBLENumber = chargerBLE["bleNumber"]!   //충전기 BLE 번호
                                        regist.providerId = chargerBLE["providerId"]!   //충전기 제공업체 ID
                                    },
                                    label: {
                                        HStack {
                                            //라디오 버튼
                                            ZStack {
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: 18, height: 18)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(chargerBLE["isAssigned"]! == "true" ? Color("#8E44AD") : Color("#BDBDBD"))
                                                    )
                                                
                                                //선택 시 라디오 버튼 표시
                                                if chargerBLE["bleNumber"]! == regist.selectBLENumber {
                                                    Circle()
                                                        .fill(Color("#8E44AD"))
                                                        .frame(width: 10, height: 10)
                                                }
                                            }
                                            
                                            //충전기 BLE 번호 텍스트
                                            Text(chargerBLE["bleNumber"]!)
                                                .foregroundColor(chargerBLE["isAssigned"]! == "true" ? Color.black : Color("#BDBDBD"))
                                            
                                            Spacer()
                                            
                                            //충전기 등록 가능 여부 라벨
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 20)
                                                    .frame(width: 70, height: 25)
                                                    .foregroundColor(chargerBLE["isAssigned"]! == "true" ? Color("#8E44AD") : Color("#C0392B"))
                                                    .shadow(color: .gray, radius: 1, x: 1.2, y: 1.2)
                                                
                                                Text(chargerBLE["isAssigned"]! == "true" ? "등록 가능" : "등록 불가")
                                                    .font(.footnote)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(Color.white)
                                            }
                                        }
                                    }
                                )
                                .disabled(chargerBLE["isAssigned"]! == "true" ? false: true)
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 5) {
                        //취소 버튼 - 알림창 닫기
                        Button(
                            action: {
                                bluetooth.isSearch = false  //BLE 검색 여부 초기화
                                regist.isShowBLEModal = false   //충전기 BLE Modal 창 닫기
                                regist.selectBLENumber = regist.tempSelectBLENumber //선택한 BLE 번호 초기화
                            },
                            label: {
                                Text("취소")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, minHeight: 35)
                                    .background(Color("#C0392B"))
                                    .cornerRadius(5.0)
                                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                            }
                        )
                        
                        //확인 버튼 - 모달 창에서 선택한 충전기 BLE로 변경
                        Button(
                            action: {
                                bluetooth.isSearch = false  //BLE 검색 여부 초기화
                                regist.isShowBLEModal = false   //충전기 BLE Modal 창 닫기
                                regist.tempSelectBLENumber = regist.selectBLENumber //선택한 BLE 번호로 변경
                            },
                            label: {
                                Text("확인")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, minHeight: 35)
                                    .background(Color("#674EA7"))
                                    .cornerRadius(5.0)
                                    .shadow(color: Color.gray, radius: 1, x: 1.5, y: 1.5)
                            }
                        )
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(5.0)
                .frame(width: geometryReader.size.width/1.2, height: 300)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 3, y: 3)
            }
            .padding()
            .frame(width: geometryReader.size.width, height: geometryReader.size.height)
            .background(Color.black.opacity(0.5))
            .onAppear {
                if bluetooth.isSearch {
                    regist.getBLENumberList(getBleNumbers: bluetooth.bleScanList)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

//MARK: - 충전기 기초 정보
struct ChargerBasicInfo: View {
    @ObservedObject var regist: ChargerRegistViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            //충전기 명
            VStack(spacing: 3) {
                //충전기 명 타이틀
                HStack(spacing: 10) {
                    Image("Label-Charger")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    
                    Text("충전기 명")
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                
                //충전기 명 입력창
                HStack(spacing: 10) {
                    Spacer().frame(width: 30)
                    
                    TextField("", text: $regist.chargerName)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity)
                        .background(Color("#F2F2F2"))
                        .cornerRadius(5.0)
                        .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                            
                    Spacer()
                }
            }
            
            //상세 설명
            VStack(spacing: 3) {
                //상세 설명 타이틀
                HStack(spacing: 10) {
                    Image("Label-Document")
                        .resizable()
                        .scaledToFit()
                        .padding(2)
                        .frame(width: 30, height: 30)
                    
                    Text("상세 설명")
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                
                //상세 설명 입력창
                HStack(spacing: 10) {
                    Spacer().frame(width: 30)
                    
                    TextEditor(text: $regist.chargerDescription)
                        .frame(maxWidth: .infinity, maxHeight: 120)
                        .cornerRadius(5.0)
                        .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                        .colorMultiply(Color("#F2F2F2"))
                    
                    Spacer()
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

//MARK: - 충전기 추가 정보
struct ChargerAdditionalInfo: View {
    @ObservedObject var regist: ChargerRegistViewModel
    
    @State var viewPath: String = "chargerRegist"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                //주소
                VStack(spacing: 3) {
                    //주소 타이틀
                    HStack(spacing: 10) {
                        Image("Label-Location")
                            .resizable()
                            .scaledToFit()
                            .padding(2)
                            .frame(width: 30, height: 30)
                        
                        Text("주소")
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    
                    //주소 검색 버튼 및 상세 주소 입력창
                    HStack(spacing: 10) {
                        Spacer().frame(width: 30)
                        
                        VStack {
                            //주소 검색 버튼
                            Button(
                                action: {
                                    regist.isShowAddressModal = true
                                },
                                label: {
                                    TextField("\(Image(systemName: "magnifyingglass")) 장소・주소 검색", text: $regist.address)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .frame(maxWidth: .infinity)
                                        .background(Color("#F2F2F2"))
                                        .cornerRadius(5.0)
                                        .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                                        .disabled(true)
                                }
                            )
                            .sheet(
                                isPresented: $regist.isShowAddressModal,
                                content: {
                                    AddressSearchModal(chargerMap: ChargerMapViewModel(), regist: regist, viewPath: $viewPath)  //주소 검색 모달창
                                }
                            )
                            
                            //상세 주소 입력창
                            TextField("상세주소", text: $regist.detailAddress)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .frame(maxWidth: .infinity)
                                .background(Color("#F2F2F2"))
                                .cornerRadius(5.0)
                                .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                        }
                    
                        Spacer()
                    }
                }
                
                //운영 유형
                VStack(spacing: 3) {
                    //운영 유형 타이틀
                    HStack(spacing: 10) {
                        Image("Label-Clock")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        
                        Text("운영 유형")
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    
                    //운영 유형 선택 Picker
                    HStack(spacing: 10) {
                        Spacer().frame(width: 30)
                        
                        Picker(
                            selection: $regist.selectSharedType,
                            label: Text("운영 유형 선택"),
                            content: {
                                Text("부분 운영").tag("PARTIAL_SHARING")
                                Text("항시 운영").tag("SHARING")
                            }
                        )
                        .pickerStyle(SegmentedPickerStyle())    //Picker Style 변경
                        .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                                
                        Spacer()
                    }
                }
                
                //케이블 보유 여부
                VStack(spacing: 3) {
                    //케이블 보유 타이틀
                    HStack(spacing: 10) {
                        ZStack {
                            Image("Label-Cable")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color.black)
                                .frame(width: 50, height: 50)
                        }
                        .frame(width: 30, height: 30)
                        
                        Text("케이블 보유")
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    
                    //케이블 보유 선택 Picker
                    HStack(spacing: 10) {
                        Spacer().frame(width: 30)
                        
                        Picker(
                            selection: $regist.selectCableFlag,
                            label: Text("케이블 보유 선택"),
                            content: {
                                Text("없음").tag(false)
                                Text("있음").tag(true)
                            }
                        )
                        .pickerStyle(SegmentedPickerStyle())    //Picker Style 변경
                        .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                                
                        Spacer()
                    }
                }
                
                //충전 타입
                VStack(spacing: 3) {
                    //충전 타입 타이틀
                    HStack(spacing: 10) {
                        ZStack {
                            Image("Label-Battery")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color.black)
                                .frame(width: 40, height: 40)
                        }
                        .frame(width: 30, height: 30)
                        
                        Text("충전 타입")
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    
                    //충전 타입 선택 Picker
                    HStack(spacing: 10) {
                        Spacer().frame(width: 30)
                        
                        Picker(
                            selection: $regist.selectSupplyCapacity,
                            label: Text("충전 타입 선택"),
                            content: {
                                Text("완속").tag("STANDARD")
                                Text("저속").tag("SLOW")
                            }
                        )
                        .pickerStyle(SegmentedPickerStyle())    //Picker Style 변경
                        .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                                
                        Spacer()
                    }
                }
                
                //주차 요금
                VStack(spacing: 3) {
                    //주차 요금 타이틀
                    HStack(spacing: 10) {
                        Image("Label-Car")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        
                        Text("주차 요금")
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    
                    //주차 요금 선택 Picker
                    HStack(spacing: 10) {
                        Spacer().frame(width: 30)
                        
                        Picker(
                            selection: $regist.selectParkingFeeFlg,
                            label: Text("주차 요금 선택"),
                            content: {
                                Text("없음").tag(false)
                                Text("있음").tag(true)
                            }
                        )
                        .pickerStyle(SegmentedPickerStyle())    //Picker Style 변경
                        .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                                
                        Spacer()
                    }
                }
                
                //주차 요금 설명
                VStack(spacing: 3) {
                    //주차 요금 설명 타이틀
                    HStack(spacing: 10) {
                        Image("Label-Document")
                            .resizable()
                            .scaledToFit()
                            .padding(2)
                            .frame(width: 30, height: 30)
                        
                        Text("주차 요금 설명")
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    
                    //주차 요금 설명 입력창
                    HStack(spacing: 10) {
                        Spacer().frame(width: 30)
                        
                        TextField("", text: $regist.parkingFeeDescription)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity)
                            .background(!regist.selectParkingFeeFlg ? Color("#BDBDBD") : Color("#F2F2F2"))
                            .cornerRadius(5.0)
                            .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                            .disabled(!regist.selectParkingFeeFlg ? true : false)
                        
                        Spacer()
                    }
                }
            }
            .padding()
        }
    }
}

//MARK: - 이전 버튼
struct RegistPreviousButton: View {
    @ObservedObject var regist: ChargerRegistViewModel
    
    var body: some View {
        Button(
            action: {
                regist.currentStep -= 1 //현재 단계 - 1
            },
            label: {
                Text("이전")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(regist.currentStep > 1 ? Color("#674EA7") : Color("#BDBDBD"))
            }
        )
        .disabled(regist.currentStep > 1 ? false : true)
    }
}

//MARK: - 다음 버튼
struct RegistNextButton: View {
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var regist: ChargerRegistViewModel
    
    var body: some View {
        Button(
            action: {
                viewUtil.dismissKeyboard()  //키보드 닫기
                regist.checkNextStep()  //다음 단계 이동 전 입력값 확인
            },
            label: {
                Text("다음")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(Color("#674EA7"))
            }
        )
    }
}

//MARK: - 충전기 등록 버튼
struct ChargerRegistButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewUtil: ViewUtil
    @ObservedObject var regist: ChargerRegistViewModel
    
    var body: some View {
        Button(
            action: {
                viewUtil.dismissKeyboard()  //키보드 닫기
                
                //충전기 등록 가능 확인 후 등록 진행
                if regist.checkRegistStep() {
                    regist.isLoading = true
                    
                    regist.registCharger() { result in
                        if result == "success" {
                            regist.toastMessage(message: "정상적으로 충전기 등록이 완료되었습니다.")

                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                regist.isLoading = false
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                        else if result == "error" {
                            regist.isLoading = false
                            regist.toastMessage(message: "server.error".message())
                        }
                    }
                }
            },
            label: {
                Text("등록")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(Color("#674EA7"))
            }
        )
    }
}

struct ChargerRegistView_Previews: PreviewProvider {
    static var previews: some View {
        ChargerRegistView()
        ChargerBasicInfo(regist: ChargerRegistViewModel())
        ChargerAdditionalInfo(regist: ChargerRegistViewModel())
    }
}
