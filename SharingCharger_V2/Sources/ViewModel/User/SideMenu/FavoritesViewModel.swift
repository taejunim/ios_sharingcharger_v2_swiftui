//
//  FavoritesViewModel.swift
//  SharingCharger_V2
//
//  Created by guava on 2021/08/19.
//

import Foundation

class FavoritesViewModel: ObservableObject {
    
    @Published var userIdNo: String = UserDefaults.standard.string(forKey: "userIdNo")!
    
    @Published var isFavorite: Bool = false
    @Published var favoritesList: [Favorites] = []
    @Published var favoriteItem: Favorites?
    
    func getFavorites() {
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

        if let userFavorites = UserDefaults.standard.value(forKey:"favorites-\(userIdNo)") as? Data {
            let saveFavorites = try? PropertyListDecoder().decode([Favorites].self, from: userFavorites)
           
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
        
        let addFavoriteItem: Favorites = Favorites(
            chargerId: item["chargerId"] as! String,
            chargerName: item["chargerName"] as! String,
            address: item["address"] as! String,
            detailAddress: item["detailAddress"] as! String,
            latitude: item["latitude"] as! Double,
            longitude: item["longitude"] as! Double
        )
        
        var addFavorites: [Favorites] = []
        
        if let data = UserDefaults.standard.value(forKey:"favorites-\(userIdNo)") as? Data {
            let saveFavorites = try? PropertyListDecoder().decode([Favorites].self, from: data)
            
            for saveFavoriteItem in saveFavorites! {
                addFavorites.append(saveFavoriteItem)
            }
            
            addFavorites.append(addFavoriteItem)
            
            UserDefaults.standard.set(try? PropertyListEncoder().encode(addFavorites), forKey: "favorites-\(userIdNo)")
        }
        else {
            addFavorites.append(addFavoriteItem)
            
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
                
                if saveFavoriteItem.chargerId != chargerId {
                    keepFavorites.append(saveFavoriteItem)
                }
            }
            
            UserDefaults.standard.set(try? PropertyListEncoder().encode(keepFavorites), forKey: "favorites-\(userIdNo)")
        }
    }
}
