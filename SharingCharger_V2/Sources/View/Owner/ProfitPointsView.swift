//
//  ProfitPointsView.swift
//  SharingCharger_V2
//
//  Created by TJ on 2021/09/27.
//

import SwiftUI

struct ProfitPointsView: View {
    @ObservedObject var ownerChargerViewModel: OwnerChargerViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack() {
                    CloseButton()
                    Spacer()
                    Text("월별 수익 포인트")
                        .fontWeight(.bold)
                    Spacer()
                    Spacer()
                        .frame(width: 25)
                }
                HStack {
                    Button(
                        action: {
                            ownerChargerViewModel.isShowYearPopupView = true
                        },
                        label: {
                            Text(ownerChargerViewModel.searchYear + " 년")
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                                .foregroundColor(.black)
                                .frame(width: 100, height: 30)
                                .background(Color("#EFEFEF"))
                        }
                    )
                    Spacer()
                }
                .padding(.leading)
                
                Spacer()
                
                VStack {
                    profitPointList(ownerChargerViewModel: ownerChargerViewModel)
                }
            }
            .padding() // 월별 수익 포인트 팝업창 상,하,좌,우 패딩
            
            if ownerChargerViewModel.isShowYearPopupView {
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(Color.black.opacity(0.5))
                    .popup(
                        isPresented: $ownerChargerViewModel.isShowYearPopupView,   //팝업 노출 여부
                        type: .default,
                        position: .top,
                        animation: .easeInOut(duration: 0.0),   //애니메이션 효과
                        dragToDismiss: false,
                        closeOnTap: false,
                        closeOnTapOutside: false,
                        view: {
                            YearPopupView(ownerChargerViewModel: ownerChargerViewModel)
                        }
                    )
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear() {
            ownerChargerViewModel.searchPoints.removeAll()
            ownerChargerViewModel.searchYear = "yyyy".dateFormatter(formatDate: Date())
            ownerChargerViewModel.requestProfitPoints()
        }
    }
}

struct YearPopupView: View {
    @ObservedObject var ownerChargerViewModel: OwnerChargerViewModel
    @State var currentYear = "yyyy".dateFormatter(formatDate: Date())
    @State var selectedYear = ""
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack{
                VStack {
                    HStack{
                        Picker("", selection: $ownerChargerViewModel.searchYear) {
                            ForEach((2021...Int(currentYear)!), id: \.self) {
                                Text(String($0)).tag(String($0))
                            }
                        }
                        .pickerStyle(InlinePickerStyle())
                        .clipped()
                    }
                    .frame(width: geometryReader.size.width/1.5, height: geometryReader.size.width/2.2)
                    
                    HStack {
                        Button(
                            action: {
                                ownerChargerViewModel.isShowYearPopupView = false
                                ownerChargerViewModel.requestProfitPoints()
                            },
                            label: {
                                Text("확인")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color("#3498DB"))
                            }
                        )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.top, 5)
                .background(Color.white)
                .cornerRadius(5.0)
                .frame(width: geometryReader.size.width/1.5, height: geometryReader.size.width/2.2 + 50, alignment: .center)
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 0)
            }
            .frame(width: geometryReader.size.width, height: geometryReader.size.height)
        }
        .onAppear {
            selectedYear = ownerChargerViewModel.searchYear
        }
    }
}

struct profitPointList: View {
    @ObservedObject var ownerChargerViewModel: OwnerChargerViewModel
    
    var body: some View  {
        
        //포인트 이력
        ScrollView{
            LazyVStack {
                let searchPoints = ownerChargerViewModel.searchPoints
                
                ForEach(searchPoints, id: \.self) {points in
                    let month: String = points["month"]!
                    let point: String = points["point"]!
                    
                    HStack {
                        Text("\(month)")
                            .font(.body)
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        
                        Spacer()
                        
                        Text("\(point.pointFormatter())")
                            .font(.body)
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .foregroundColor(Color("#3498DB"))
                    }
                    .padding(.vertical, 8.0)
                    
                    Divider()
                }
            }
        }
    }
}


struct ProfitPointsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfitPointsView(ownerChargerViewModel: OwnerChargerViewModel())
        YearPopupView(ownerChargerViewModel: OwnerChargerViewModel())
    }
}
