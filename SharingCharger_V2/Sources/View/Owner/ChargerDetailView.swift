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
        .onAppear {
            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(named: "#8E44AD")    //Picker 배경 색상
        }
        .onDisappear {
            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(named: "#3498DB")    //Picker 배경 색상
        }
        
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
        
        HStack {
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
                        .padding(2)
                        .frame(width: 35, height: 35)
                        .foregroundColor(isShowChargerDetailMain ? Color("#8E44AD") : Color("#5E5E5E"))
                }
            )
            
            Spacer()
            
            HStack {
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
                            .frame(width: 35, height: 35)
                            .foregroundColor(isShowChargerPriceSetting ? Color("#8E44AD") : Color("#5E5E5E"))
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
                                .padding(3)
                                .frame(width: 35, height: 35)
                                .foregroundColor(isShowChargerOperateTimeSetting ? Color("#8E44AD") : Color("#5E5E5E"))
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
                            .frame(width: 35, height: 35)
                            .foregroundColor(isShowChargerInformationEdit ? Color("#8E44AD") : Color("#5E5E5E"))
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
                            .padding(.horizontal, 2)
                            .padding(.top, 3)
                            .frame(width: 35, height: 35)
                            .foregroundColor(isShowChargerHistory ? Color("#8E44AD") : Color("#535353"))
                        }
                )
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)

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
