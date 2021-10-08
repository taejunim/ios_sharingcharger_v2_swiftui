//
//  OwnerChargerView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/27.
//

import SwiftUI

struct OwnerChargerView: View {
    @Environment(\.presentationMode) var presentationMode   //Back 버튼 기능 추가에 필요
    @ObservedObject var ownerChargerViewModel = OwnerChargerViewModel()    //충전기 관리 View Model
    
    var body: some View {
        VStack {
            OwnerChargerSummaryInfo(ownerChargerViewModel: ownerChargerViewModel)  //소유주 충전기 요약 정보
            
            Dividerline()
            
            OwnerChargerList(ownerChargerViewModel: ownerChargerViewModel)  //소유주 충전기 목록
        }
        .navigationBarTitle(Text("충전기 관리"), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
        .onAppear {
            ownerChargerViewModel.requestOwnerSummaryInfo()
            ownerChargerViewModel.requestOwnerChargerList()
        }
        .sheet(
            isPresented: $ownerChargerViewModel.showProfitPointsView,
            content: {
                ProfitPointsView(ownerChargerViewModel: ownerChargerViewModel)
            }
        )
    }
}

//MARK: - 소유주의 충전기 요약 정보
///NavigationView 문제로 화면 구성 변경
struct OwnerChargerSummaryInfo: View {
    @ObservedObject var ownerChargerViewModel: OwnerChargerViewModel
    
    var body: some View {
        
        let ownChargerCount = ownerChargerViewModel.ownChargerCount
        VStack {
            HStack {
                Text("총 충전기 대수")
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 2) {
                    Text(String(ownChargerCount))
                        //.font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("#8E44AD"))
                        
                    Text("대")
                        .fontWeight(.bold)
                }
                .padding(.trailing, 10)
                
                ChargerRegistViewButton(ownerChargerViewModel: ownerChargerViewModel)
            }
            
            VerticalDividerline()
            
            HStack {
                Text("이달의 수익 포인트")
                    .fontWeight(.bold)
                Spacer()
                
                ProfitPointsViewButton(ownerChargerViewModel: ownerChargerViewModel)
            }
        }
        .padding()
    }
}

//MARK: - 충전기 등록 화면 이동 버튼
struct ChargerRegistViewButton: View {
    @ObservedObject var ownerChargerViewModel: OwnerChargerViewModel
    
    var body: some View {
        NavigationLink(
            destination: ChargerRegistView(),
            label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 35, height: 35)
                        .foregroundColor(Color("#8E44AD"))
                        .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                    
                    Image("Button-Add")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                }
            }
        )
    }
}

//MARK: - 월별 수익 포인트 화면 이동 버튼
struct ProfitPointsViewButton: View {
    @ObservedObject var ownerChargerViewModel: OwnerChargerViewModel
    
    var body: some View {
        
        let monthlyCumulativePoint = ownerChargerViewModel.monthlyCumulativePoint
        Button(
            action: {
                ownerChargerViewModel.showProfitPointsView = true
            },
            label: {
                Text(numberFormatter(number: monthlyCumulativePoint) + "p")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(minWidth: 120, minHeight: 35)
                    .background(Color("#8E44AD"))
                    .cornerRadius(5.0)
                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
            }
        )
    }
    //숫자에 콤마
    func numberFormatter(number: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter.string(from: NSNumber(value: number))!
    }
}

//MARK: - 소유주 충전기 목록
struct OwnerChargerList: View {
    @ObservedObject var ownerChargerViewModel: OwnerChargerViewModel
    
    var body: some View {
        ScrollView {
            
            let searchChargers = ownerChargerViewModel.chargers
            VStack{
            ForEach(searchChargers, id: \.self) {charger in
                
                let id: String = charger["id"]!
                let name: String = charger["name"]!                                         //충전기 명
                let address: String = charger["address"]!                                   //주소
                let description: String = charger["description"]!                           //설명
                let bleNumber: String = charger["bleNumber"]!                               //ble번호
                let currentStatusType: String = charger["currentStatusType"]!               //현재 충전기 상태
                let typeColor: String = charger["typeColor"]!                               //충전기 상태별 Color
                let index: String = charger["index"]!                                       //번호 (n번째 충전기) - 화면 표출용
                
                NavigationLink(
                    destination: ChargerDetailView(chargerId : id),
                    label: {
                        HStack {
                            Text(index)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(Color("#8E44AD"))
                            
                            VStack(alignment: .leading) {
                               
                                HStack(spacing: 1) {
                                    Text(name)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    
                                    Text(bleNumber.suffix(5))
                                        .font(.subheadline)
                                }
                                
                                Text(address)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text(description)
                                    .font(.subheadline)
                                    .foregroundColor(Color.gray)
                            }
                            .padding(.horizontal, 5)
                            
                            Spacer()
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: 70, height: 25)
                                    .foregroundColor(Color(typeColor))    //충전기 상태에 따른 배경 색상
                                    .shadow(color: .gray, radius: 1, x: 1.2, y: 1.2)
                                
                                Text(currentStatusType)
                                    .font(.subheadline)
                                    .foregroundColor(Color.white)
                                    .fontWeight(.bold)
                            }
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                )
                
                HorizontalDividerline()
            }
        }
        }
    }
}

struct OwnerChargerView_Previews: PreviewProvider {
    static var previews: some View {
        OwnerChargerView()
    }
}
