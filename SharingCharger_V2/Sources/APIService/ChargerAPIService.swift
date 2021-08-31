//
//  ChargerAPIService.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/19.
//

import Alamofire
import PromisedFuture

class ChargerAPIService {
    let apiClient = APIClient() //API Client - 공통 API 호출
    
    public func requestChargerList(parameters: [String:String]) -> Future<[Charger], AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/app/chargers", parameters: parameters, contentType: "json"))
    }
    
    public func requestCharger(chargerId: String) -> Future<Charger, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/app/chargers/\(chargerId)", parameters: [:], contentType: "json"))
    }
    
    public func requestCurrentDate() -> Future<String, AFError> {

        return apiClient.requestText(route: APIRouter.get(useApi: "base", path: "/reservation/current/time", parameters: [:], contentType: "text"))
    }
    
    public func requestChargerReservation(chargerId: String, parameters: [String:String]) -> Future<ChargerReservation, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/reservations/chargers/\(chargerId)", parameters: parameters, contentType: "json"))
    }
}
