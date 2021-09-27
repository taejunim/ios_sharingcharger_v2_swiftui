//
//  ChargingView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/15.
//

import SwiftUI

//MARK: - 충전 화면
struct ChargingView: View {
    @ObservedObject var viewOptionSet = ViewOptionSet()
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var reservation: ReservationViewModel
    @ObservedObject var charging = ChargingViewModel()
    
    var body: some View {
        NavigationView {
            ChargerBLESearchView(chargerMap: chargerMap, reservation: reservation, charging: charging)
        }
        .onAppear {
        }
    }
}

//MARK: - 충전기 BLE 검색 화면
struct ChargerBLESearchView: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var reservation: ReservationViewModel
    @ObservedObject var charging: ChargingViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            ScrollView {
                VStack {
                    HStack {
                        Text("근처 충전기와 연결을 시작합니다.\n커넥터와 차량이 연결되어 있는지 확인 후, 충전기 앞에서 연결 버튼을 터치해 주세요.")
                            .foregroundColor(Color("#5E5E5E"))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 5)
                    
                    VerticalDividerline()
                    
                    ConnectionGuide()
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            
            ChargerBLESearchButton(charging: charging)
        }
        .navigationBarTitle(Text("충전기 검색"), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackMainButton(chargerMap: chargerMap))  //커스텀 Back 버튼 추가
    }
}

//MARK: - 충전기 연결 가이드
struct ConnectionGuide: View {
    var body: some View {
        VStack {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 90, height: 25)
                        .foregroundColor(Color("#3498DB"))    //충전기 상태에 따른 배경 색상
                        .shadow(color: .gray, radius: 1, x: 1.2, y: 1.2)
                    
                    Text("STEP 1")
                        .foregroundColor(Color.white)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Text("충전기에 전원이 들어와 있는지 확인하십시오.")
                    .foregroundColor(Color("#5E5E5E"))
                
                Spacer()
            }
            .padding(.top, 5)
            .frame(maxWidth: .infinity, minHeight: 100)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            
            HorizontalDividerline()
            
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 90, height: 25)
                        .foregroundColor(Color("#3498DB"))
                        .shadow(color: .gray, radius: 1, x: 1.2, y: 1.2)
                    
                    Text("STEP 2")
                        .foregroundColor(Color.white)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Text("충전기가 대기상태인지 확인하십시오.")
                    .foregroundColor(Color("#5E5E5E"))
                
                Spacer()
            }
            .padding(.top, 5)
            .frame(maxWidth: .infinity, minHeight: 100)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            
            HorizontalDividerline()
            
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 90, height: 25)
                        .foregroundColor(Color("#3498DB"))    //충전기 상태에 따른 배경 색상
                        .shadow(color: .gray, radius: 1, x: 1.2, y: 1.2)
                    
                    Text("STEP 3")
                        .foregroundColor(Color.white)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Text("충전기 근처에 스마트폰을 가져가십시오.\n자동으로 충전기 감지가 진행됩니다.")
                    .foregroundColor(Color("#5E5E5E"))
                
                Spacer()
            }
            .padding(.top, 5)
            .frame(maxWidth: .infinity, minHeight: 100)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .border(Color("#EFEFEF"), width: 2)
        .padding(.horizontal, 5)
    }
}

//MARK: - 충전기
struct ChargerBLESearchButton: View {
    @ObservedObject var charging: ChargingViewModel
    
    var body: some View {
        NavigationLink(
            destination: ChargingControlView(charging: charging),
            isActive: $charging.isConnect,
            label: {
                Button(
                    action: {
                        charging.isConnect = true
                    },
                    label: {
                        Text("충전기 검색")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(Color("#3498DB"))
                    }
                )
            }
        )
    }
}

struct BackMainButton: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        Button(
            action: {
                withAnimation {
                    chargerMap.showChargingView = false
                }
            },
            label: {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
                .padding(.trailing)
            }
        )
    }
}

struct ChargingControlView: View {
    @Environment(\.presentationMode) var presentationMode   //Back 버튼 기능 추가에 필요
    @ObservedObject var charging: ChargingViewModel
    
    var body: some View {
        VStack {
            ChargerBLEConnectionButton(charging: charging)  //충전기 BLE 연결 버튼
            
            HorizontalDividerline().padding(.vertical)
            
            ChargingInfoView()  //충전 정보
            
            HorizontalDividerline().padding(.vertical)
            
            Spacer()
            
            ChargingTimer() //충전 타이머
            
            Spacer()
            
            HStack {
                Spacer()
                
                ChargeStartButton(charging: charging)   //충전 시작 버튼
                
                Spacer()
                
                ChargeEndButton(charging: charging) //충전 종료 버튼
                
                Spacer()
            }
            .padding(.vertical)
            
            Spacer()
        }
        .padding(.top, 10)
        .navigationBarTitle(Text("충전"), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
    }
}

//MARK: - 충전기 BLE 연결 버튼
struct ChargerBLEConnectionButton: View {
    @ObservedObject var charging: ChargingViewModel
    
    var body: some View {
        Button(
            action: {
                
            },
            label: {
                Text("충전기 연결")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(Color(charging.isConnect ? "#BDBDBD" : "#1ABC9C"))
                    .cornerRadius(5.0)
                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                    .padding(.horizontal)
            }
        )
        .padding(.top)
    }
}

//MARK: - 충전 정보
struct ChargingInfoView: View {
    var body: some View {
        HStack {
            VStack {
                Text("충전기")
                Text("충전기")
                Text("충전기")
                Text("충전기")
            }
            .padding(.horizontal, 10)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

//MARK: - 충전 타이머
struct ChargingTimer: View {
    var body: some View {
        VStack {
            Text("00:00")
                .font(.system(size: 70))
                .fontWeight(.bold)
                .shadow(color: .gray, radius: 1, x: 1.8, y: 1.8)
        }
        //.padding(.vertical)
    }
}

//MARK: - 충전 시작 버튼
struct ChargeStartButton: View {
    @ObservedObject var charging: ChargingViewModel
    
    var body: some View {
        Button(
            action: {
                charging.isChargingStart = true
            },
            label: {
                VStack {
                    ZStack {
                        Circle()
                            .foregroundColor(Color(charging.isChargingStart ? "#BDBDBD" : "#3498DB"))
                            .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                        
                        Image("Charge-State-Start")
                            .resizable()
                            .scaledToFit()
                            .padding()
                    }
                    .frame(width: 100 ,height: 100)
                    
                    Text("충전 시작")
                        .foregroundColor(charging.isChargingStart ? Color("#BDBDBD") : Color.black)
                        .fontWeight(charging.isChargingStart ? .none : .semibold)
                        .shadow(color: .gray, radius: 1, x: 1.2, y: 1.2)
                }
            }
        )
        .disabled(charging.isChargingStart)
    }
}

//MARK: - 충전 종료 버튼
struct ChargeEndButton: View {
    @ObservedObject var charging: ChargingViewModel
    
    var body: some View {
        Button(
            action: {
                charging.isChargingStart = false
            },
            label: {
                VStack {
                    ZStack {
                        Circle()
                            .foregroundColor(Color(!charging.isChargingStart ? "#BDBDBD" : "#C0392B"))
                            .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                        
                        Image("Charge-State-End")
                            .resizable()
                            .scaledToFit()
                            .padding()
                    }
                    .frame(width: 100 ,height: 100)
                    
                    Text("충전 종료")
                        .foregroundColor(!charging.isChargingStart ? Color("#BDBDBD") : Color.black)
                        .fontWeight(!charging.isChargingStart ? .none : .semibold)
                        .shadow(color: .gray, radius: 1, x: 1.2, y: 1.2)
                }
            }
        )
        .disabled(!charging.isChargingStart)
    }
}

struct ChargingView_Previews: PreviewProvider {
    
    static var previews: some View {
        ChargingView(chargerMap: ChargerMapViewModel(), reservation: ReservationViewModel())
        ChargingControlView(charging: ChargingViewModel())
    }
}
