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
            pointViewModel.searchPoints.removeAll()                     //조회한 포인트 목록 초기화
            pointViewModel.page = 1                                     //페이지 번호 초기화
            pointViewModel.isSearchStart = true                         //조회 시작 여부
            
            pointViewModel.getCurrentPoint()                            //현재 잔여 포인트 호출
            pointViewModel.getPointHistory(page: pointViewModel.page)   //포인트 목록 첫 페이지 호출
        }
        .sheet(
            isPresented: $pointViewModel.showSearchModal,
            content: {
                PointSearchModal(pointViewModel: pointViewModel) //포인트 검색조건 Modal 창
            }
        )
    }
}
//MARK: - 포인트 검색 조건
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

//MARK: - 현재 잔여 포인트, 포인트 이력
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
                
                Text(pointViewModel.currentPoint.pointFormatter())
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
            LazyVStack {
                let searchPoints = pointViewModel.searchPoints
                
                ForEach(searchPoints, id: \.self) {points in
                    let created: String = points["created"]!        //생성 날짜
                    let type: String = points["type"]!              //포인트 유형
                    let point: String = points["point"]!            //포인트
                    let targetName: String = points["targetName"]!  //
                    let typeColor: String = points["typeColor"]!    //유형에 따른 text color
                    let typeCode: String = points["typeCode"]!
                    
                    let date = created.replacingOccurrences(of: "T", with: " ") //생성 날짜에서 T 제거
                    
                    HStack {
                        VStack(alignment: .leading){
                            HStack{
                                Text("\(date)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                if (typeCode == "PURCHASE" || typeCode == "PURCHASE_CANCEL" ){
                                    Text("\(targetName)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            HStack{
                                Text("\(type)")
                                    .font(.title3)
                                Spacer()
                                Text(point.pointFormatter())
                                    .font(.body)
                                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                    .foregroundColor(Color(typeColor))
                            }
                            Spacer()
                            HStack{
                                if (typeCode == "EXCHANGE" || typeCode == "GIVE" || typeCode == "WITHDRAW" ){
                                    if targetName != ""{
                                        Text("\(targetName)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 5.0)
                    }
                    .onAppear{
                        //조회 시작 여부 true일 경우 실행
                        if pointViewModel.isSearchStart{
                            //스크롤 하단 이동 시, 마지막 이력 정보일 때 추가 조회 실행
                            if searchPoints.last == points{
                                pointViewModel.page += 1    //한 페이지씩 추가
                                pointViewModel.getPointHistory(page: pointViewModel.page)   //다음 페이지 호출
                            }
                        }
                    }
                    Divider()
                }
            }
        }
    }
}

struct PointHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        PointHistoryView()
    }
}
