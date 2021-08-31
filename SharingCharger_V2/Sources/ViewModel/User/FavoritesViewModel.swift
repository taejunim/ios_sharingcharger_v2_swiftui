//
//  FavoritesViewModel.swift
//  SharingCharger_V2
//
//  Created by guava on 2021/08/19.
//

import Foundation

class FavoritesViewModel: ObservableObject {
    @Published var items: [ChargerModel] = []{
        didSet {
            saveItems()
        }
    }
    //forkey
    let itemskey: String = "chargerList"
    
    init() {
        getItems()
    }
    
    func getItems() {
        //        let newItems = [
        //            ChargerModel(markerId: 1, longitude: 126.56758115301774,  latitude: 33.447714772716694,  markerName: "관광대학교 주차장", address: "제주 제주시 제주관광대학로 111(아라일동)"),
        //            ChargerModel(markerId: 2, longitude: 126.56758115301774,  latitude: 33.447714772716694,  markerName: "test charger 2", address: "제주특별자치도 제주시 첨단로8길 37"),
        //            ChargerModel(markerId: 3, longitude: 126.56758115301774,  latitude: 33.447714772716694,  markerName: "test charger 3", address: "제주특별자치도 제주시 첨단로8길 38"),
        //            ChargerModel(markerId: 4, longitude: 126.56758115301774,  latitude: 33.447714772716694,  markerName: "test charger 4", address: "제주특별자치도 제주시 첨단로8길 39"),
        //            ChargerModel(markerId: 5, longitude: 126.56758115301774,  latitude: 33.447714772716694,  markerName: "test charger 5", address: "제주특별자치도 제주시 첨단로8길 40")
        //        ]
        //        items.append(contentsOf: newItems)
        guard
            let data = UserDefaults.standard.data(forKey: itemskey),
            let savedItems = try? JSONDecoder().decode([ChargerModel].self, from: data)
        else{
            return
        }
        
        self.items = savedItems
    }
    
    //삭제
    func deleteItem(indexSet: IndexSet){
        items.remove(atOffsets: indexSet)
    }
    
    
    func saveItems() {
        if let encodedData = try? JSONEncoder().encode(items){
            UserDefaults.standard.set(encodedData, forKey: itemskey)
        }
    }
}
