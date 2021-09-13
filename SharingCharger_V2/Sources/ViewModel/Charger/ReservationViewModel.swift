//
//  ReservationViewModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/13.
//

import Foundation
import Combine

class ReservationViewModel: ObservableObject {
    private let chargerAPI = ChargerAPIService()  //충전기 API Service

    @Published var reservationTest: String = ""
    @Published var chargeType: String = ""
    
    //MARK: - 충전 예약
    func reservation() {
        print(chargeType)
    }
}
