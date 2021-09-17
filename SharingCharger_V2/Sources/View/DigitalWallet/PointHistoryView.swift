//
//  PointHistoryView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/19.
//

import SwiftUI

struct PointHistoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var pointViewModel = PointViewModel()
    
    var body: some View {
        
        VStack {
            remainPoints(pointViewModel: pointViewModel)
        }
        .padding(.horizontal)
        .navigationBarTitle(Text("title.point.history".localized()), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton(), trailing: PointSearchModalButton(point: pointViewModel))  //커스텀 Back 버튼 추가
        .onAppear {
            pointViewModel.getCurrentPoint()
            pointViewModel.getPointHistory()
            print(pointViewModel.getPointHistory())
        }
        .sheet(
            isPresented: $pointViewModel.showSearchModal,
            content: {
                PointSearchModal(point: pointViewModel) //포인트 검색조건 Modal 창
            }
        )
    }
}

struct PointSearchModalButton: View {
    @ObservedObject var point: PointViewModel
    
    var body: some View {
        Button(
            action: {
                point.showSearchModal = true
            },
            label: {
                Image("Button-Slider")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
            }
        )
    }
}

//MARK: - 현재 잔여 포인트
struct remainPoints: View {
    @ObservedObject var pointViewModel: PointViewModel
    
    @State var pointTypeBool: Bool = false //글씨 색상
    
    var body: some View  {
        //현재 잔여 포인트
        VStack {
            HStack {
                Text("현재 잔여 포인트 ")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(numberFormatter(number: pointViewModel.currentPoint) + "p")
                    .foregroundColor(.white)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .frame(width: 100, height: 40)
                    .background(Color.blue)
                    .cornerRadius(20)
                
            }
            .padding((EdgeInsets(top: 20, leading: 0, bottom: 35, trailing: 0)))
        }
        Divider()
        //포인트 이력
        ScrollView{
            VStack(spacing: 10) {
                let searchPoints = pointViewModel.searchPoints
                
                ForEach(searchPoints, id: \.self) {points in
                    let created: String = points["created"]!        //생성 날짜
                    let type: String = points["type"]!              //포인트 유형
                    let point: String = points["point"]!            //포인트
                    let targetName: String = points["targetName"]!  //
                    let typeColor: String = points["typeColor"]!    //유형에 따른 text color
                    
                    let date = created.replacingOccurrences(of: "T", with: " ") //생성 날짜에서 T 제거
                    let Point = Int(point)  //포인트 int형으로 변환
                   
                    HStack {
                        VStack(alignment: .leading){
                            HStack{
                                Text("\(date)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(targetName)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            HStack{
                                Text("\(type)")
                                    .font(.title3)
                                Spacer()
                                Text(numberFormatter(number: Point!))
                                    .font(.body)
                                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                    .foregroundColor(Color(typeColor))
                            }
                            
                        }
                        .padding(.vertical, 5.0)
                    }
                    Divider()
                }
            }
        }
    }
    //숫자에 콤마
    func numberFormatter(number: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter.string(from: NSNumber(value: number))!
    }
}

struct PointHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        PointHistoryView()
    }
}
