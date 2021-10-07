//
//  ChargerDetailView.swift
//  SharingCharger_V2
//
//  Created by 조유영 on 2021/09/29.
//
import SwiftUI

struct ChargerDetailView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var chargerDetailViewModel = ChargerDetailViewModel()
        
    @State var chargerId:String
    
    var body: some View {
        VStack(spacing: 0) {
            OwnerChargerDetailMenu(chargerDetailViewModel: chargerDetailViewModel)
            OwnerChargerDetail(chargerDetailViewModel: chargerDetailViewModel)
        }
        .navigationBarTitle(Text("충전기 관리"), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
        .onAppear {
    
            chargerDetailViewModel.requestOwnerCharger(chargerId: chargerId)
        }
        Spacer()
    }
    
}

struct OwnerChargerDetail: View {
    @ObservedObject var chargerDetailViewModel: ChargerDetailViewModel
    
    var body: some View {
        
        VStack(alignment: .leading) {
        
            let charger = chargerDetailViewModel.charger
            let name: String = charger["name"] ?? ""
            
            //테스트용 임시 텍스트
            Text(name)
                .font(.title)
                .fontWeight(.bold)
            
            Text("메티스 충전기 4번")
                .font(.title)
                .fontWeight(.bold)
            
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Image("Label-Bluetooth")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color("#8E44AD"))
                Text("04:32:F4:40:A7:E1")
                Spacer()
            }
            
            HStack(alignment: VerticalAlignment.top , spacing: 10){
                Image("Label-Building")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color("#8E44AD"))
                Text("(주) 차지인")
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
                    Text("제주특별자치도 제주시 첨단로8길 40")
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
                    Text("무료주차")
                    Text("무료")
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
                    Text("설명이다 .. 설명이다 .. 설명이다 .. 설명이다 .. 설명이다 .. 설명이다 .. 설명이다 .. 설명이다 .. 설명이다 .. 설명이다 .. 설명이다 .. 설명이다 .. 설명이다 .. 설명이다 .. 설명이다 .. 설명이다 .. 설명이다 .. 설명이다 .. ")
                }
                Spacer()
            }
        }.padding(10)
    }
}

struct OwnerChargerDetailMenu: View{
    @ObservedObject var chargerDetailViewModel: ChargerDetailViewModel
    var body: some View {
        
        HStack(spacing: 5) {
            Button(
                action: {
                    print("테스트 1")
                },
                label: {
                    Image("Button-Home")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(5)
                }
            )
            Spacer()
            HStack(spacing: 2) {
                Button(
                    action: {
                        print("테스트 2")
                    },
                    label: {
                        Image("Button-Coin")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding(5)
                        }
                )
                Button(
                    action: {
                        print("테스트 3")
                    },
                    label: {
                        Image("Button-Clock")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding(5)
                        }
                )
                Button(
                    action: {
                        print("테스트 4")
                        
                    },
                    label: {
                        Image("Button-Edit")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding(5)
                        }
                )
                Button(
                    action: {
                        print("테스트 5")
                    },
                    label: {
                        Image("Button-Credit-Card")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding(5)
                        }
                )
            }
            .padding(.trailing, 10)
        }
        .padding(.leading, 10)
        .padding(.top, 10)
        .padding(.bottom, 10)
    
    }
    
}

struct ChargerDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        ChargerDetailView(chargerId: "")
    }
}
