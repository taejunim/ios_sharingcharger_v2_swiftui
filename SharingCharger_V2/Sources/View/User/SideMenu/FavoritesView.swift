//
//  FavoritesView.swift
//  SharingCharger_V2
//
//  Created by guava on 2021/08/19.
//

import SwiftUI

struct FavoritesView: View {
    @Environment(\.presentationMode) var presentationMode   //Back 버튼 기능 추가에 필요
    
    @ObservedObject var favoritesViewModel = FavoritesViewModel()
    var body: some View {
        List {
            ForEach(favoritesViewModel.items) { item in
                ListRowView(item: item)
            }
            .onDelete(perform: favoritesViewModel.deleteItem)
            .onTapGesture {
                print("map")
            }
        }
        .navigationBarTitle(Text("title.favorites".localized()), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
    }
}

struct ListRowView: View {

    let item: ChargerModel
     
     var body: some View {
        HStack{
            VStack(spacing: 15.0) {
                Text(item.markerName)
                    .font(.title2)
                    .padding(.top, 5)
                    .lineSpacing(50)
                    .frame(width: 300, alignment: .leading)
                Text(item.address)
                    .font(.body)
                    .padding(.bottom, 5)
                    .frame(width: 300, alignment: .leading)
            }
            Spacer()
            VStack{
                Text(">")
                    .foregroundColor(.gray)
                    .font(.body)
            }
        }
        .font(.title2)
        .padding(.vertical, 8)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
