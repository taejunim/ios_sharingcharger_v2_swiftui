//
//  SideMenuViewModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/20.
//

import Foundation

///사이드 메뉴 View Model
class SideMenuViewModel: ObservableObject {
    @Published var isShowMenu: Bool = false //사이드 메뉴 노출 여부
    @Published var isSignOut: Bool = false
}
