//
//  Keyboard.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/06.
//

import SwiftUI
import Foundation

//MARK: - 키보드 활성화 시 화면 위치 이동
struct Keyboard: ViewModifier {
    @State var offset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, offset)
            .onAppear {
                //키보드 활성화 시, 키보드 영역만큼 화면 위치 이동
                NotificationCenter.default.addObserver(
                    forName: UIResponder.keyboardWillShowNotification,
                    object: nil,
                    queue: .main
                ) { (notification) in
                    let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                    let height = value.height
                    
                    self.offset = height
                }
                
                //키보드 비활성화 시, 이동한 화면 위치 복구
                NotificationCenter.default.addObserver(
                    forName: UIResponder.keyboardWillHideNotification,
                    object: nil,
                    queue: .main
                ) { (notification) in
                    self.offset = 0
                }
            }
    }
}

extension View {
    //ScrollView {}.keyboardResponsive() - 사용법
    func keyboardResponsive() -> ModifiedContent<Self, Keyboard> {
        return modifier(Keyboard())
    }
}
