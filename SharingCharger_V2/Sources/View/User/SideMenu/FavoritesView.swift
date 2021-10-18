//
//  FavoritesView.swift
//  SharingCharger_V2
//
//  Created by guava on 2021/08/19.
//

import SwiftUI

//MARK: - 즐겨찾기
struct FavoritesView: View {
    @Environment(\.presentationMode) var presentationMode   //Back 버튼 기능 추가에 필요
    
    @ObservedObject var favorites: FavoritesViewModel   //즐겨찾기 View Model
    @ObservedObject var chargerMap: ChargerMapViewModel //충전기 지도 View Model
    @ObservedObject var sideMenu: SideMenuViewModel //사이드 메뉴 View Model
    
    var body: some View {
        VStack {
            ScrollView {
                //즐겨찾기 없는 경우
                if favorites.favoritesList.count == 0 {
                    VStack(spacing: 5) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.largeTitle)
                            .foregroundColor(Color("#BDBDBD"))
                        
                        Text("등록된 즐겨찾기가 없습니다.")
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                    }
                    .padding()
                }
                else {
                    LazyVStack {
                        //즐겨찾기 목록
                        ForEach(favorites.favoritesList, id: \.self) { items in
                            //즐겨찾기 항목
                            FavoriteRow(favorites: favorites, chargerMap: chargerMap, sideMenu: sideMenu, favoriteItem: items)
                            
                            Dividerline()
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .onAppear {
                favorites.getFavorites()    //즐겨찾기 조회
            }
        }
        .navigationBarTitle(Text("title.favorites".localized()), displayMode: .inline) //Navigation Bar 타이틀
        .navigationBarBackButtonHidden(true)    //기본 Back 버튼 숨김
        .navigationBarItems(leading: BackButton())  //커스텀 Back 버튼 추가
    }
}

//MARK: - 즐겨찾기 항목
struct FavoriteRow: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var favorites: FavoritesViewModel
    @ObservedObject var chargerMap: ChargerMapViewModel
    @ObservedObject var sideMenu: SideMenuViewModel

    let favoriteItem: Favorites
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                //충전기 명
                Text(favoriteItem.chargerName)
                    .font(.headline)
                
                //충전기 주소
                Text(favoriteItem.address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                //충전기 상세 주소
                Text(favoriteItem.detailAddress)
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
            }
            
            Spacer()
            
            VStack(spacing: 10) {
                //해당 충전기의 지도보기 버튼
                Button(
                    action: {
                        self.presentationMode.wrappedValue.dismiss()    //화면 닫기
                        sideMenu.isShowMenu = false //사이드 메뉴 비활성화
                        
                        //지도에서 해당 충전기로 이동
                        chargerMap.moveToReservedCharger(chargerId: favoriteItem.chargerId, latitude: favoriteItem.latitude, longitude: favoriteItem.longitude)
                    },
                    label: {
                        Text("지도보기")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .padding(.horizontal)
                            .frame(minWidth: 85, minHeight: 25)
                            .background(Color("#3498DB"))
                            .cornerRadius(5.0)
                            .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                    }
                )
                
                //해당 충전기의 즐겨찾기 삭제 버튼
                Button(
                    action: {
                        let index = favorites.favoritesList.firstIndex(of: favoriteItem)!   //해당 즐겨찾기 Index
                        favorites.favoritesList.remove(at: index)   //즐겨찾기 목록에서 제거
                        
                        favorites.deleteFavorites(chargerId: favoriteItem.chargerId)    //즐겨찾기 정보 삭제
                    },
                    label: {
                        Text("삭제")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .padding(.horizontal)
                            .frame(minWidth: 85, minHeight: 25)
                            .background(Color("#C0392B"))
                            .cornerRadius(5.0)
                            .shadow(color: .gray, radius: 1, x: 1.5, y: 1.5)
                    }
                )
            }
        }
        .padding(.horizontal)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView(favorites: FavoritesViewModel(), chargerMap: ChargerMapViewModel(), sideMenu: SideMenuViewModel())
    }
}
