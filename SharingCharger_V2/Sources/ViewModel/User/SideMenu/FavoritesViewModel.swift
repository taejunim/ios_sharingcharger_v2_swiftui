//
//  FavoritesViewModel.swift
//  SharingCharger_V2
//
//  Created by guava on 2021/08/19.
//  Updated by KJ
//

import Foundation

///즐겨찾기 View Model
class FavoritesViewModel: ObservableObject {
    
    @Published var userIdNo: String = UserDefaults.standard.string(forKey: "userIdNo")! //사용자 ID 번호
    
    @Published var isFavorite: Bool = false //즐겨찾기 여부
    @Published var favoritesList: [Favorites] = []  //즐겨찾기 목록
    @Published var favoriteItem: Favorites? //즐겨찾기 항목
    
    //MARK: - 즐겨찾기 조회
    func getFavorites() {
        //사용자의 즐겨찾기 정보 호출
        if let userFavorites = UserDefaults.standard.value(forKey:"favorites-\(userIdNo)") as? Data {
            let getFavorites = try? PropertyListDecoder().decode([Favorites].self, from: userFavorites)
            
            favoritesList = getFavorites!
        }
        else {
            favoritesList = []
        }
    }
    
    //MARK: - 충전기별 즐겨찾기 조회
    func getChargerFavorite(chargerId: String) {
        //해당 사용자의 즐겨찾기 정보 호출
        if let userFavorites = UserDefaults.standard.value(forKey:"favorites-\(userIdNo)") as? Data {
            let saveFavorites = try? PropertyListDecoder().decode([Favorites].self, from: userFavorites)
            
            //저장된 즐겨찾기된 충전기 항목 추출
            for saveFavoriteItem in saveFavorites! {
                if saveFavoriteItem.chargerId == chargerId {
                    isFavorite = true
                    
                    break
                }
                else {
                    isFavorite = false
                }
            }
        }
        else {
            isFavorite = false
        }
    }
    
    //MARK: - 즐겨찾기 추가
    func addFavorites(item: [String:Any]) {
        isFavorite = true
        
        //추가할 즐겨찾기 항목 정보
        let addFavoriteItem: Favorites = Favorites(
            chargerId: item["chargerId"] as! String,    //충전기 ID
            chargerName: item["chargerName"] as! String,    //충전기 명
            address: item["address"] as! String,    //주소
            detailAddress: item["detailAddress"] as! String,    //상세 주소
            latitude: item["latitude"] as! Double,  //위도
            longitude: item["longitude"] as! Double //경도
        )
        
        var addFavorites: [Favorites] = []  //추가 즐겨찾기 목록
        
        //기존 저장된 즐겨찾기 정보
        if let data = UserDefaults.standard.value(forKey:"favorites-\(userIdNo)") as? Data {
            let saveFavorites = try? PropertyListDecoder().decode([Favorites].self, from: data)
            
            //기존 저장된 즐겨찾기 항목 추출 후 추가 즐겨찾기 목록에 추가
            for saveFavoriteItem in saveFavorites! {
                addFavorites.append(saveFavoriteItem)
            }
            
            addFavorites.append(addFavoriteItem)    //신규 즐겨찾기 정보 추가
            
            UserDefaults.standard.set(try? PropertyListEncoder().encode(addFavorites), forKey: "favorites-\(userIdNo)")
        }
        //기존 저장된 즐겨찾기 정보가 없는 경우
        else {
            addFavorites.append(addFavoriteItem)    //신규 즐겨찾기 정보 추가
            
            UserDefaults.standard.set(try? PropertyListEncoder().encode(addFavorites), forKey: "favorites-\(userIdNo)")
        }
    }
    
    //MARK: - 즐겨찾기 삭제
    func deleteFavorites(chargerId: String) {
        isFavorite = false
        
        var keepFavorites: [Favorites] = []
        
        if let data = UserDefaults.standard.value(forKey:"favorites-\(userIdNo)") as? Data {
            let saveFavorites = try? PropertyListDecoder().decode([Favorites].self, from: data)
           
            for saveFavoriteItem in saveFavorites! {
                //삭제할 충전기의 ID가 아닌 경우만
                if saveFavoriteItem.chargerId != chargerId {
                    keepFavorites.append(saveFavoriteItem)
                }
            }
            
            UserDefaults.standard.set(try? PropertyListEncoder().encode(keepFavorites), forKey: "favorites-\(userIdNo)")
        }
    }
}
