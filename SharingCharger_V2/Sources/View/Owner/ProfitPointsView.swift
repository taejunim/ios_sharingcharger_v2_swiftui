//
//  ProfitPointsView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/09/27.
//

import SwiftUI

struct ProfitPointsView: View {
    @ObservedObject var ownerCharger: OwnerChargerViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ProfitPointsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfitPointsView(ownerCharger: OwnerChargerViewModel())
    }
}
