//
//  ChargerDetailView.swift
//  SharingCharger_V2
//
//  Created by 조유영 on 2021/09/29.
//
import SwiftUI


struct ChargerDetailView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var chargerDetailViewModel = ChargerDetailViewModel()
        
    @State var chargerId:String
    @State var sharedType:String
    
    var body: some View {
        VStack(spacing: 0) {
            OwnerChargerDetailMenu(chargerDetailViewModel: chargerDetailViewModel, chargerId: chargerId, sharedType: sharedType)
        }
        .navigationBarTitle(Text("충전기 관리"), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)        //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
        Spacer()
    }
    
}

struct OwnerChargerDetailMenu: View{
    @ObservedObject var chargerDetailViewModel: ChargerDetailViewModel
    @State var chargerId:String
    @State var sharedType:String
    
    @State var isShowChargerDetailMain:Bool = true
    @State var isShowChargerPriceSetting:Bool = false
    @State var isShowChargerOperateTimeSetting:Bool = false
    @State var isShowChargerInformationEdit:Bool = false
    @State var isShowChargerHistory:Bool = false
    
    var body: some View {
        
        HStack(spacing: 0) {
            Button(
                action: {
                    isShowChargerDetailMain = true
                    isShowChargerPriceSetting = false
                    isShowChargerOperateTimeSetting = false
                    isShowChargerInformationEdit = false
                    isShowChargerHistory = false
                },
                label: {
                    Image("Button-Home")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 40, height: 40)
                        .padding(5)
                        .foregroundColor(isShowChargerDetailMain ? Color("#8E44AD"): .black)
                }
            )
            Spacer()
            HStack(spacing: 2) {
                Button(
                    action: {
                        isShowChargerDetailMain = false
                        isShowChargerPriceSetting = true
                        isShowChargerOperateTimeSetting = false
                        isShowChargerInformationEdit = false
                        isShowChargerHistory = false
                    },
                    label: {
                        Image("Button-Coin")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 40, height: 40)
                            .padding(5)
                            .foregroundColor(isShowChargerPriceSetting ? Color("#8E44AD"): .black)
                        }
                )
                
                if(sharedType == "PARTIAL_SHARING"){
                    Button(
                        action: {
                            isShowChargerDetailMain = false
                            isShowChargerPriceSetting = false
                            isShowChargerOperateTimeSetting = true
                            isShowChargerInformationEdit = false
                            isShowChargerHistory = false
                        },
                        label: {
                            Image("Button-Clock")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 40, height: 40)
                                .padding(5)
                                .foregroundColor(isShowChargerOperateTimeSetting ? Color("#8E44AD"): .black)
                            }
                    )
                }
                Button(
                    action: {
                        isShowChargerDetailMain = false
                        isShowChargerPriceSetting = false
                        isShowChargerOperateTimeSetting = false
                        isShowChargerInformationEdit = true
                        isShowChargerHistory = false
                    },
                    label: {
                        Image("Button-Edit")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 40, height: 40)
                            .padding(5)
                            .foregroundColor(isShowChargerInformationEdit ? Color("#8E44AD"): .black)
                        }
                )
                Button(
                    action: {
                        isShowChargerDetailMain = false
                        isShowChargerPriceSetting = false
                        isShowChargerOperateTimeSetting = false
                        isShowChargerInformationEdit = false
                        isShowChargerHistory = true
                    },
                    label: {
                        Image("Button-Credit-Card")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 40, height: 40)
                            .padding(5)
                            .foregroundColor(isShowChargerHistory ? Color("#8E44AD"): .black)
                        }
                )
            }
        }
        .padding(.trailing, 10)
        .padding(.top, 10)
        .padding(.leading, 10)
        .padding(.bottom, 10)
            

        //선택된 메뉴에 따라 내부 Content Show/Hide
        
        if self.isShowChargerDetailMain {
            OwnerChargerDetailMain(chargerDetailViewModel: chargerDetailViewModel, chargerId: chargerId)
        }
        if self.isShowChargerPriceSetting {
            OwnerChargerPriceSetting(chargerDetailViewModel: chargerDetailViewModel, chargerId: chargerId)
        }
        if self.isShowChargerOperateTimeSetting {
            OwnerChargerOperateTimeSetting(chargerDetailViewModel: chargerDetailViewModel, chargerId: chargerId)
        }
        if self.isShowChargerInformationEdit {
            OwnerChargerInformationEdit(chargerDetailViewModel: chargerDetailViewModel, chargerId: chargerId)
        }
        if self.isShowChargerHistory {
            OwnerChargerHistory(chargerDetailViewModel: chargerDetailViewModel, chargerId: chargerId)
        }
          
        
    }
}

struct ChargerDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        ChargerDetailView(chargerId: "", sharedType: "")
    }
}
