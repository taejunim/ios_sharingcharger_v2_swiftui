//
//  PointHistoryView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/19.
//

import SwiftUI

struct PointHistoryView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView{
            VStack {
                remainPoints()
                Divider()
                pointHistory()
            }
            .padding(.horizontal)
            .navigationBarTitle(Text("title.point.history".localized()), displayMode: .inline) //Navigation Bar 타이틀
            .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
            .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
        }
    }
}

//MARK: - 현재 잔여 포인트
struct remainPoints: View {
    var body: some View  {
        VStack {
            
            HStack {
                Text("현재 잔여 포인트 ")
                    .font(.title2)
                    .fontWeight(.bold)
                
                
                Spacer()
                Text("50,000"+"p")
                    .foregroundColor(.white)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .frame(width: 100, height: 40)
                    .background(Color.blue)
                    .cornerRadius(20)
                
            }
            .padding((EdgeInsets(top: 20, leading: 0, bottom: 35, trailing: 0)))
        }
    }
}

struct pointHistory: View {
    var body: some View  {
        VStack(spacing: 10) {
            
            HStack {
                VStack(alignment: .leading){
                    Text("2020-07-23 18:00 ")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    HStack{
                        Text("부분 환불")
                            .font(.title3)
                        Spacer()
                        Text("+"+"1,350")
                            .font(.body)
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.blue)
                    }
                    
                }
                .padding(.vertical, 5.0)
            }
            Divider()
            HStack {
                VStack(alignment: .leading){
                    Text("2020-07-23 18:00 ")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    HStack{
                        Text("사용")
                            .font(.title3)
                        Spacer()
                        Text("-"+"3,000")
                            .font(.body)
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.red)
                    }
                    
                }
                .padding(.vertical, 5.0)
            }
            Divider()
            HStack {
                VStack(alignment: .leading){
                    Text("2020-07-23 18:00 ")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    HStack{
                        Text("포인트 충전")
                            .font(.title3)
                        Spacer()
                        Text("+"+"50,000")
                            .font(.body)
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 5.0)
            }
            Divider()
        }
    }
}

struct PointHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        PointHistoryView()
    }
}
