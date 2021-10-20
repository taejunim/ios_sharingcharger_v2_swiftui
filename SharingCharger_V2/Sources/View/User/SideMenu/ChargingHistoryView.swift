//
//  ChargingHistoryView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/10/01.
//

import SwiftUI

//MARK:- 충전 이력 화면
struct ChargingHistoryView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var chargingHistory = ChargingHistoryViewModel()
    
    var body: some View {
        VStack{
            ScrollView {
                //조회 개수가 0인 경우 메시지 출력
                if chargingHistory.totalCount == 0 {
                    
                    VStack(spacing: 5) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.largeTitle)
                            .foregroundColor(Color("#BDBDBD"))
                        
                        if chargingHistory.isSearch {
                            Text("검색 조건에 맞는 검색 결과가 없습니다.")
                                .font(.subheadline)
                                .foregroundColor(Color.gray)
                        }
                        else {
                            Text("server.error".message())
                                .font(.subheadline)
                                .foregroundColor(Color.gray)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                }
                else {
                    ChargingHistoryList(chargingHistory: chargingHistory)   //충전 이력 목록
                }
            }
            .onAppear {
                //현재일자 조회하여 기본 검색 일자 설정 후, 충전 이력 조회
                chargingHistory.getCurrentDate() { currentDate in
                    chargingHistory.setSearchDate(endDate: currentDate) //검색일자 설정
                    chargingHistory.getChargingHistory()    //충전 이력 조회
                }
            }
            .onDisappear {
                chargingHistory.reset() //검색 조건 및 결과 초기화
            }
            .sheet(
                isPresented: $chargingHistory.isShowSearchModal,
                content: {
                    ChargingHistorySearchModal(chargingHistory: chargingHistory)    //충전 이력 검색조건 팝업창
                }
            )
        }
        .navigationBarTitle(Text("충전기 사용 이력"), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
        .navigationBarItems(
            leading: BackButton(),  //커스텀 Back 버튼 추가
            trailing: HistorySearchModalButton(chargingHistory: chargingHistory)
        )
    }
}

//MARK: - 충전 이력 검색조건 팝업창 버튼
struct HistorySearchModalButton: View {
    @ObservedObject var chargingHistory: ChargingHistoryViewModel
    
    var body: some View {
        Button(
            action: {
                chargingHistory.isShowSearchModal = true
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

//MARK: - 충전 이력 목록
struct ChargingHistoryList: View {
    @ObservedObject var chargingHistory: ChargingHistoryViewModel
    
    var body: some View {
        LazyVStack(alignment: .leading) {
            let histories = chargingHistory.histories
            
            ForEach(histories, id: \.self) { history in
                ChargingHistoryRow(chargingHistory: chargingHistory, history: history)
                    .onAppear {
                        if chargingHistory.page <= chargingHistory.totalPages {
                            //현재 페이지의 이력이 마지막인 경우
                            if histories.last == history {
                                chargingHistory.page += 1
                                chargingHistory.getChargingHistory()
                            }
                        }
                    }
            }
        }
        .padding(.vertical)
    }
}

//MARK: - 충전 이력 내용
struct ChargingHistoryRow: View {
    @ObservedObject var chargingHistory: ChargingHistoryViewModel
    
    let history: [String:String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 1) {
                Image("Charge-Position")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                
                //충전기 명
                Text(history["chargerName"]!)
                    .font(.callout)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 5) {
                //충전 번호
                HStack {
                    //충전 배터리 아이콘
                    ZStack {
                        Circle()
                            .foregroundColor(Color("#3498DB"))
                            
                        Image("Charge-Battery")
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(width: 23 ,height: 23)
                    
                    Text("충전 번호")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(":")
                        .font(.subheadline)
                    
                    Text(history["chargeId"]!)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                
                HStack {
                    //시계 아이콘
                    Image("Charge-Clock")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 23, height: 23)
                    
                    //충전 일시
                    Text(history["startDate"]!)
                        .font(.subheadline)
                    
                    if history["endDate"]! != "" {
                        Text("~")
                            .font(.subheadline)
                        
                        Text(history["endDate"]!)
                            .font(.subheadline)
                    }
                    
                    Spacer()
                }
                .padding(.leading, 25)
                
                HStack {
                    VStack {
                        //코인 아이콘
                        Image("Charge-Coin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 23, height: 23)
                        
                        Spacer()
                    }
                    
                    //포인트 내역
                    VStack(alignment: .leading) {
                        //예약 차감 포인트
                        HStack {
                            Text("예약 차감 포인트")
                                .font(.subheadline)
                            
                            Text(":")
                                .font(.subheadline)
                            
                            Text(history["prepaidPoint"]!)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        //충전 사용 포인트
                        HStack {
                            Text("충전 사용 포인트")
                                .font(.subheadline)
                            
                            Text(":")
                                .font(.subheadline)
                            
                            Text(history["deductionPoint"]!)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("#C0392B"))
                        }
                        
                        //환불 포인트
                        HStack {
                            Text("환불 포인트")
                                .font(.subheadline)
                            
                            Text(":")
                                .font(.subheadline)
                            
                            Text(history["refundPoint"]!)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("#3498DB"))
                        }
                    }
                    
                    Spacer()
                }
                .padding(.leading, 25)
            }
            .padding(.leading, 25)
        }
        .padding(.horizontal, 10)
        
        Dividerline()
    }
}

struct ChargingHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ChargingHistoryView()
    }
}
