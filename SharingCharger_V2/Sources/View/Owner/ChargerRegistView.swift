//
//  ChargerRegistView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/27.
//

import SwiftUI

struct ChargerRegistView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewUtil = ViewUtil()
    @ObservedObject var regist = ChargerRegistViewModel()
    @ObservedObject var bluetooth = ChargingViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                RegistStepGuide(regist: regist)
                
                Spacer()
                
                if regist.currentStep == 1 {
                    FindChargerBLE(regist: regist, bluetooth: bluetooth)
                }
                else if regist.currentStep == 2 {
                    ChargerBasicInfo(regist: regist)
                }
                else if regist.currentStep == 3 {
                    ChargerAdditionalInfo(regist: regist)
                }
                
                Spacer()
                
                HStack(spacing: 2) {
                    RegistPreviousButton(regist: regist)
                    
                    if regist.currentStep < 3 {
                        RegistNextButton(regist: regist)
                    }
                    else {
                        ChargerRegistButton(regist: regist)
                    }
                }
            }
            .navigationBarTitle(Text("충전기 등록"), displayMode: .inline) //Navigation Bar 타이틀
            .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
            .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
            
            if bluetooth.isSearch || regist.isShowBLEModal {
                FindChargerBLEModal(regist: regist, bluetooth: bluetooth)
            }
            
            if bluetooth.isLoading {
                viewUtil.loadingView()
            }
        }
    }
}

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

struct RegistPreviousButton: View {
    @ObservedObject var regist: ChargerRegistViewModel
    
    var body: some View {
        Button(
            action: {
                print(regist.currentStep)
                
                regist.currentStep -= 1
                
                print(regist.currentStep)
            },
            label: {
                Text("이전")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(regist.currentStep > 1 ? Color("#674EA7") : Color("#BDBDBD"))
            }
        )
        .disabled(regist.currentStep > 1 ? false : true)
    }
}

struct RegistNextButton: View {
    @ObservedObject var regist: ChargerRegistViewModel
    
    var body: some View {
        Button(
            action: {
                print(regist.currentStep)
                
                regist.currentStep += 1
                
                print(regist.currentStep)
            },
            label: {
                Text("다음")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(Color("#674EA7"))
            }
        )
    }
}

struct ChargerRegistButton: View {
    @ObservedObject var regist: ChargerRegistViewModel
    
    var body: some View {
        Button(
            action: {
                
            },
            label: {
                Text("등록")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(Color("#674EA7"))
            }
        )
    }
}

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
                
                Button(
                    action: {
                        regist.isShowBLEModal = true
                    },
                    label: {
                        Text(regist.selectBLENumber)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .frame(width: 200)
                            .background(Color("#8E44AD"))
                            .cornerRadius(5.0)
                            .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                    }
                )
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(
                action: {
                    bluetooth.searchChargerBLE()
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
                            ForEach(regist.chargerBLEList, id:\.self) { (chargerBLE) in
                                Button(
                                    action: {
                                        regist.selectBLENumber = chargerBLE["bleNumber"]!
                                    },
                                    label: {
                                        HStack {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: 18, height: 18)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color("#8E44AD"))
                                                    )
                                                
                                                if chargerBLE["bleNumber"]! == regist.selectBLENumber {
                                                    Circle()
                                                        .fill(Color("#8E44AD"))
                                                        .frame(width: 10, height: 10)
                                                }
                                            }
                                            
                                            Text(chargerBLE["bleNumber"]!)
                                                .foregroundColor(Color.black)
                                            
                                            Spacer()
                                        }
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 5) {
                        //취소 버튼 - 알림창 닫기
                        Button(
                            action: {
                                bluetooth.isSearch = false
                                regist.isShowBLEModal = false
                                regist.selectBLENumber = regist.tempSelectBLENumber
                            },
                            label: {
                                Text("취소")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, maxHeight: 35)
                                    .background(Color("#C0392B"))
                                    .cornerRadius(5.0)
                                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                            }
                        )
                        
                        Button(
                            action: {
                                bluetooth.isSearch = false
                                regist.isShowBLEModal = false
                                regist.tempSelectBLENumber = regist.selectBLENumber
                            },
                            label: {
                                Text("확인")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, maxHeight: 35)
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

struct ChargerBasicInfo: View {
    @ObservedObject var regist: ChargerRegistViewModel
    
    var body: some View {
        VStack {
            Text("충전기 기초 정보")
        }
    }
}

struct ChargerAdditionalInfo: View {
    @ObservedObject var regist: ChargerRegistViewModel
    
    var body: some View {
        VStack {
            Text("충전기 추가 정보")
        }
    }
}

struct ChargerRegistView_Previews: PreviewProvider {
    static var previews: some View {
        ChargerRegistView()
    }
}
