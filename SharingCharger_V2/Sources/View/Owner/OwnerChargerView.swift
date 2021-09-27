//
//  OwnerChargerView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/27.
//

import SwiftUI

struct OwnerChargerView: View {
    @Environment(\.presentationMode) var presentationMode   //Back 버튼 기능 추가에 필요
    @ObservedObject var ownerCharger = OwnerChargerViewModel()    //충전기 관리 View Model
    
    var body: some View {
        VStack {
            OwnerChargerSummaryInfo(ownerCharger: ownerCharger)  //소유주 충전기 요약 정보
            
            Dividerline()
            
            OwnerChargerList(ownerCharger: ownerCharger)  //소유주 충전기 목록
        }
        .navigationBarTitle(Text("충전기 관리"), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
        .sheet(
            isPresented: $ownerCharger.showProfitPointsView,
            content: {
                ProfitPointsView(ownerCharger: ownerCharger)
            }
        )
    }
}

//MARK: - 소유주의 충전기 요약 정보
///NavigationView 문제로 화면 구성 변경
struct OwnerChargerSummaryInfo: View {
    @ObservedObject var ownerCharger: OwnerChargerViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("총 충전기 대수")
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 2) {
                    Text("10")
                        //.font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("#8E44AD"))
                        
                    Text("대")
                        .fontWeight(.bold)
                }
                .padding(.trailing, 10)
                
                ChargerRegistViewButton(ownerCharger: ownerCharger)
            }
            
            VerticalDividerline()
            
            HStack {
                Text("이달의 수익 포인트")
                    .fontWeight(.bold)
                Spacer()
                
                ProfitPointsViewButton(ownerCharger: ownerCharger)
            }
        }
        .padding()
    }
}

//MARK: - 충전기 등록 화면 이동 버튼
struct ChargerRegistViewButton: View {
    @ObservedObject var ownerCharger: OwnerChargerViewModel
    
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
    @ObservedObject var ownerCharger: OwnerChargerViewModel
    
    var body: some View {
        Button(
            action: {
                ownerCharger.showProfitPointsView = true
            },
            label: {
                Text("5,000p")
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
}

//MARK: - 소유주 충전기 목록
struct OwnerChargerList: View {
    @ObservedObject var ownerCharger: OwnerChargerViewModel
    
    var body: some View {
        ScrollView {
            Button(
                action: {
                    
                },
                label: {
                    HStack {
                        Text("1")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color("#8E44AD"))
                        
                        VStack(alignment: .leading) {
                            HStack(spacing: 1) {
                                Text("메티스 충전기 01")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Text("(2E:92)")
                                    .font(.subheadline)
                            }
                            
                            Text("제주특별자치도 제주시 첨단로 8길 40")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text("주차장 입구")
                                .font(.subheadline)
                                .foregroundColor(Color.gray)
                        }
                        .padding(.horizontal, 5)
                        
                        Spacer()
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 70, height: 25)
                                .foregroundColor(Color("#3498DB"))    //충전기 상태에 따른 배경 색상
                                .shadow(color: .gray, radius: 1, x: 1.2, y: 1.2)
                            
                            Text("대기중")
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
            
            Button(
                action: {
                    
                },
                label: {
                    HStack {
                        Text("2")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color("#8E44AD"))
                        
                        VStack(alignment: .leading) {
                            HStack(spacing: 1) {
                                Text("메티스 충전기 02")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Text("(2E:92)")
                                    .font(.subheadline)
                            }
                            
                            Text("제주특별자치도 제주시 첨단로 8길 40")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text("주차장 입구")
                                .font(.subheadline)
                                .foregroundColor(Color.gray)
                        }
                        .padding(.horizontal, 5)
                        
                        Spacer()
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 70, height: 25)
                                .foregroundColor(Color("#C0392B"))    //충전기 상태에 따른 배경 색상
                                .shadow(color: .gray, radius: 1, x: 1.2, y: 1.2)
                            
                            Text("사용중")
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

struct OwnerChargerView_Previews: PreviewProvider {
    static var previews: some View {
        OwnerChargerView()
    }
}
