//
//  LaunchScreen.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/07/30.
//

import SwiftUI

//MARK: - 시작 화면
struct LaunchScreen: View {
    var body: some View {
        ZStack {
            //시작 화면 이미지
            Image("LaunchImage")
                .resizable()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
    }
}
