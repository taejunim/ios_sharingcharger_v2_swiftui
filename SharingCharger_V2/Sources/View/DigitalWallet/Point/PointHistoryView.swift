//
//  PointHistoryView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/19.
//

import SwiftUI

//MARK: - 포인트 구매 이력 화면
struct PointHistoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var point = PointViewModel()
    
    var body: some View {
        VStack {
            RemainingPoints(point: point)   //현재 잔여 포인트
            
            Divider()
            
            PointHistoryList(point: point)  //포인트 이력 목록
        }
        .navigationBarTitle(Text("포인트 구매 이력"), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton(), trailing: PointSearchModalButton(point: point))  //커스텀 Back 버튼 추가
        .onAppear {
            point.searchPoints.removeAll()                     //조회한 포인트 목록 초기화
            point.page = 1                                     //페이지 번호 초기화
            point.isSearchStart = true                         //조회 시작 여부
            
            point.getCurrentPoint()                            //현재 잔여 포인트 호출
            point.getPointHistory(page: point.page)   //포인트 목록 첫 페이지 호출
        }
        .sheet(
            isPresented: $point.showSearchModal,
            content: {
                PointSearchModal(point: point) //포인트 검색조건 Modal 창
            }
        )
    }
}

//MARK: - 포인트 검색 조건 팝업창 버튼
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
struct RemainingPoints: View {
    @ObservedObject var point: PointViewModel
    
    var body: some View {
        //현재 잔여 포인트
        VStack {
            HStack {
                Text("현재 잔여 포인트")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(point.currentPoint.pointFormatter())
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(minWidth: 120, minHeight: 30)
                    .background(Color("#3498DB"))
                    .cornerRadius(20.0)
                    .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
            }
        }
        .padding()
        .padding(.top, 10)
    }
}

//MARK: - 포인트 이력 목록
struct PointHistoryList: View {
    @ObservedObject var point: PointViewModel
    
    @State var pointTypeBool: Bool = false //글씨 색상
    
    var body: some View  {
        //포인트 이력
        ScrollView{
            LazyVStack {
                let searchPoints = point.searchPoints
                
                ForEach(searchPoints, id: \.self) { points in
                    
                    let created: String = points["created"]!        //생성 날짜
                    let type: String = points["type"]!              //포인트 유형
                    let historyPoint: String = points["point"]!            //포인트
                    let targetName: String = points["targetName"]!
                    let typeColor: String = points["typeColor"]!    //유형에 따른 text color
                    let typeCode: String = points["typeCode"]!  //이력 유형

                    let date = created.replacingOccurrences(of: "T", with: " ") //생성 날짜에서 T 제거
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(date)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            if (typeCode == "PURCHASE" || typeCode == "PURCHASE_CANCEL" ) {
                                Text("승인 번호 : \(targetName)")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        HStack {
                            Text("\(type)")
                                .font(.headline)
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            
                            Spacer()
                            
                            Text(typeCode == "PURCHASE" || typeCode == "EXCHANGE" || typeCode == "GIVE" ? "+\(historyPoint.pointFormatter())" : historyPoint.pointFormatter())
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(Color(typeColor))
                        }
                        
                        if (typeCode == "EXCHANGE" || typeCode == "GIVE" || typeCode == "WITHDRAW" ) {
                            if targetName != "" {
                                Spacer()
                                
                                HStack {
                                    Text("\(targetName)")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .onAppear {
                        //조회 시작 여부 true일 경우 실행
                        if point.isSearchStart {
                            //스크롤 하단 이동 시, 마지막 이력 정보일 때 추가 조회 실행
                            if searchPoints.last == points {
                                point.page += 1    //한 페이지씩 추가
                                point.getPointHistory(page: point.page)   //다음 페이지 호출
                            }
                        }
                    }
                    
                    Divider()
                }
            }
            .padding(.horizontal, 10)
        }
    }
}

struct PointHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        PointHistoryView()
    }
}
