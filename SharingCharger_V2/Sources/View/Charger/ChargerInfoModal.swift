//
//  ChargerInfoModal.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/27.
//

import SwiftUI

struct ChargerInfoModal: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        GeometryReader { (geometry) in
            SlideOverModal(
                isShown: $chargerMap.isShowInfoView,
                modalHeight: geometry.size.height/2.5,
                content: {
                    VStack {
                        VStack(spacing: 15) {
                            
                            ChargerSummaryInfo(chargerMap: chargerMap)
                            
                            ChargerAvailableTime(chargerMap: chargerMap)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        ChargingProgressButton(chargerMap: chargerMap)
                    }
                    .padding(.top, 30)
                }
            )
        }
    }
}

struct ChargerSummaryInfo: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(chargerMap.chargerName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ChargerFavoritesButton(chargerMap: chargerMap)
                }
                
                Text(chargerMap.chargerAddress)
                
                Text("충전 요금 : 시간 당 " + chargerMap.chargerUnitPrice)
            }
            
            Spacer()
            
            ChargerNavigationButton(chargerMap: chargerMap)
        }
    }
}

struct ChargerFavoritesButton: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        Button(
            action: {
                chargerMap.isFavorites.toggle()
            },
            label: {
                Image(chargerMap.isFavorites ? "Charger-Favorite-Fill" : "Charger-Favorite")
                    .resizable()
                    .scaledToFit()
                    .padding(.bottom, 8)
                    .frame(width: 40, height: 40)
                    .cornerRadius(5.0)
                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
            }
        )
    }
}

struct ChargerNavigationButton: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        Button(
            action: {
            },
            label: {
                ZStack {
                    Circle()
                        .foregroundColor(Color("#3498DB"))

                    Image("Map-Roadmap")
                        .resizable()
                        .scaledToFit()
                        .padding(.leading, 5)
                }
                .frame(width: 70 ,height: 70)
                .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
            }
        )
    }
}

struct ChargerAvailableTime: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        HStack {
            Text("이용 가능 시간")
                .font(.headline)
                .fontWeight(.bold)
            Text("- 항시 충전 가능")
            Spacer()
        }
    }
}

struct ChargingProgressButton: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        Button(
            action: {
                if chargerMap.selectChargeType == "Instant" {
                    
                }
                else if chargerMap.selectChargeType == "Reservation" {
                    
                }
            },
            label: {
                Text(chargerMap.selectChargeType == "Instant" ? "충전하기" : "예약하기")
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

struct ChargerInfoModal_Previews: PreviewProvider {
    static var previews: some View {
        ChargerInfoModal(chargerMap: ChargerMapViewModel())
    }
}
