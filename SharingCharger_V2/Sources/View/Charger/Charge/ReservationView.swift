//
//  ReservationView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/13.
//

import SwiftUI

struct ReservationView: View {
    
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var reservation: ReservationViewModel
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    HStack {
                        Text("결제 정보 확인")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding()
                    
                    ReservedChargerSummaryInfo(chargerMap: chargerMap)
                    
                    ReservationPointInfo()
                    
                    VerticalDividerline()
                    
                    Precautions()
                }
            }
            
            ReservationButton()
        }
        .navigationBarTitle(Text("예약 진행"), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
    }
}

struct ReservedChargerSummaryInfo: View {
    @ObservedObject var chargerMap: ChargerMapViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 0) {
                //충전기 명
                Text(chargerMap.chargerName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color("#E74C3C"))
                
                Text("(" + chargerMap.bleNumber.suffix(5) + ")")
                
                Spacer()
            }
            
            Text(chargerMap.chargerAddress) //충전기 주소
            Text(chargerMap.chargerDetailAddress) //충전기 상세주소
                .foregroundColor(Color.gray)
        }
        .padding(.horizontal)
    }
}

struct ReservationPointInfo: View {
    var body: some View {
        VStack(spacing: 1) {
            HStack {
                Text("현재 잔여 포인트")
                
                Spacer()
            }
            
            VerticalDividerline()
            
            HStack {
                Text("예상 차감 포인트")
                
                Spacer()
            }
            
            VerticalDividerline()
            
            HStack {
                Text("예약 진행 후 잔여 포인트")
                
                Spacer()
            }
        }
        .padding()
    }
}

struct Precautions: View {
    var body: some View {
        VStack {
            HStack {
                Text("※ 예약 전 주의 사항")
                    .font(.title3)
                    .foregroundColor(Color("#E74C3C"))
                
                Spacer()
            }
            
            Text("예약완료 버튼 클릭 시 포인트가 차감됩니다.\n포인트 부족시에는 포인트를 충전 후 예약을 진행하여 주시기 바랍니다.")
                .padding(.vertical, 10)
        }
        .padding(.horizontal)
    }
}

struct ReservationButton: View {
    var body: some View {
        Button(
            action: {
                
            },
            label: {
                Text("예약 완료")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(Color("#3498DB"))
            }
        )
    }
}

struct ReservationView_Previews: PreviewProvider {
    static var previews: some View {
        ReservationView(chargerMap: ChargerMapViewModel(), reservation: ReservationViewModel())
    }
}
