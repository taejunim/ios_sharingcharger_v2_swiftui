//
//  DigitalWalletView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/26.
//

import SwiftUI

struct DigitalWalletView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var point = PointViewModel()
    @ObservedObject var purchase = PurchaseViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    VStack(spacing: 30) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(UserDefaults.standard.string(forKey: "userName") ?? "User Name")" + "님의 지갑")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("000-00-0000")
                                    .font(.callout)
                            }
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text(String(point.currentPoint).pointFormatter())
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            PointPaymentButton(purchase: purchase)
                                .shadow(color: .black, radius: 1, x: 1.2, y: 1.2)
                        }
                        
                        HStack {
                            PointTransferMenuButton()
                            
                            Divider()
                                .frame(width: 1, height: 30)
                                .background(Color("#EFEFEF"))
                                .padding(.horizontal, 10)
                            
                            PointHistoryMenuButton()
                        }
                    }
                    .padding()
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .background(Color("#5E5E5E"))
                .cornerRadius(10)
                .shadow(color: .gray, radius: 1, x: 1.2, y: 1.2)
                .padding()
                
                Spacer()
            }
            
            //충전하기 버튼 클릭 시, '포인트 결제 금액 입력 알림창' 호출
            if purchase.showPaymentInputAlert {
                PaymentInputAlert(purchase: purchase)   //포인트 결제 금액 입력 알림창
            }
        }
        .navigationBarTitle(Text("전자지갑"), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
        .onAppear {
            point.getCurrentPoint() //현재 사용자 포인트 조회
        }
    }
}

//MARK: - 포인트 이체 메뉴 버튼
struct PointTransferMenuButton: View {
    var body: some View {
        NavigationLink(
            destination: PointHistoryView(),
            label: {
                Text("포인트 이체")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(minWidth: 100, minHeight: 30)
                    .background(Color("#3498DB"))
                    .cornerRadius(5.0)
                    .shadow(color: .black, radius: 1, x: 1.2, y: 1.2)
            }
        )
        .disabled(true)
    }
}

//MARK: - 포인트 이력 메뉴 버튼
struct PointHistoryMenuButton: View {
    var body: some View {
        NavigationLink(
            destination: PointHistoryView(),
            label: {
                Text("포인트 이력")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                    .frame(minWidth: 100, minHeight: 30)
                    .background(Color("#3498DB"))
                    .cornerRadius(5.0)
                    .shadow(color: .black, radius: 1, x: 1.2, y: 1.2)
            }
        )
    }
}

struct DigitalWalletView_Previews: PreviewProvider {
    static var previews: some View {
        DigitalWalletView()
    }
}
