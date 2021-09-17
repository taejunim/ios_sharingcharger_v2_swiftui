//
//  ChargingView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/15.
//

import SwiftUI

struct ChargingView: View {
    @ObservedObject var viewOptionSet = ViewOptionSet()
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var charging = ChargingViewModel()
    
    var body: some View {
        NavigationView {
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
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                
                Button(
                    action: {
                        charging.searchChargerBLE()
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
            .navigationBarTitle(Text("충전기 검색"), displayMode: .inline) //Navigation Bar 타이틀
            .navigationBarItems(leading: BackMainButton(chargerMap: chargerMap))  //커스텀 Back 버튼 추가
        }
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

struct ChargingView_Previews: PreviewProvider {
    
    static var previews: some View {
        ChargingView(chargerMap: ChargerMapViewModel())
    }
}
