//
//  CustomView.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/04.
//

import SwiftUI
import WebKit
import UIKit

//MARK: - Back 버튼
struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(
            action: {
                self.presentationMode.wrappedValue.dismiss()    //화면 닫기
            },
            label: {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
                .padding(.trailing)
            }
        )
    }
}

struct CloseButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(
            action: {
                self.presentationMode.wrappedValue.dismiss()    //화면 닫기
            },
            label: {
                Image("Button-Close")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
            }
        )
    }
}

struct RefreshButton: View {
    var isRefresh: (Bool) -> ()
    
    var body: some View {
        Button(
            action: {
                isRefresh(true)
            },
            label: {
                Image("Button-Refresh")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
            }
        )
    }
}

//MARK: - 구분선
struct Dividerline: View {
    var body: some View {
        Divider()
            .frame(height: 1)
            .background(Color("#EFEFEF"))
            .padding(.all, 10)
    }
}

//MARK: - 구분선 - Vertical Padding
struct VerticalDividerline: View {
    var body: some View {
        Divider()
            .frame(height: 1)
            .background(Color("#EFEFEF"))
            .padding(.vertical, 10)
    }
}

//MARK: - Text Field 밑줄
struct TextFieldUnderline: View {
    var body: some View {
        Divider()
            .frame(height: 1)
            .background(Color("#EFEFEF"))
            .padding(.bottom, 10)
    }
}

//MARK: - 필수입력(*) Label
struct RequiredInputLabel: View {
    var body: some View {
        Text("*")
            .foregroundColor(Color("#E4513D"))
    }
}

//MARK: - 입력 창 타이틀
/// - Parameters:
///   - title: 타이틀
///   - isRequired: 필수입력 표시 여부
/// - Returns: Text Field Title View
func fieldTitle(title: String, isRequired: Bool) -> some View {
    HStack {
        Text(title)
        
        if isRequired {
            RequiredInputLabel()    //필수입력(*) Label
        }
    }
}

//MARK: - 기본 입력 창
/// - Parameters:
///   - comment: 입력 창. 설명
///   - text: Binding String
///   - type: Keyboard Type
/// - Returns: Text Field View
func defaultTextField(comment: String, text: Binding<String>, type: UIKeyboardType) -> some View {
    HStack {
        TextField(comment, text: text)
            .autocapitalization(.none)    //첫 문자 항상 소문자
            .keyboardType(type)    //키보드 타입 - 영문만 표시
    }
}

//MARK: - 입력 창 (Text Field 밑줄 포함)
/// - Parameters:
///   - comment: 입력 창 설명
///   - text: Binding String
///   - type: Keyboard Type
/// - Returns: Text Field View
func textField(comment: String, text: Binding<String>, type: UIKeyboardType) -> some View {
    VStack {
        HStack {
            TextField(comment, text: text)
                .autocapitalization(.none)    //첫 문자 항상 소문자
                .keyboardType(type)    //키보드 타입 - 영문만 표시
        }
        
        TextFieldUnderline()    //Text Field 밑줄
    }
}

//MARK: - 보안 입력 창 (Text Field 밑줄 포함)
/// - Parameters:
///   - comment: 입력 창 설명
///   - text: Binding String
/// - Returns: Secure Field View
func secureField(comment: String, text: Binding<String>) -> some View {
    VStack {
        HStack {
            SecureField(comment, text: text)
                .autocapitalization(.none)    //첫 문자 항상 소문자
                .textContentType(.oneTimeCode)
        }
        
        TextFieldUnderline()    //Text Field 밑줄
    }
}

//MARK: - HTML Text 화면
struct HTMLText: UIViewRepresentable {
    let htmlContent: String
    
    //MARK: - Web View 생성
    /// - Parameter context: HTML Text
    /// - Returns: Web View
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    //MARK: - HTML Text Load
    /// - Parameters:
    ///   - uiView: Web View
    ///   - context: HTML Text
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}

struct CustomDatePicker: UIViewRepresentable {
    @Binding var date: Date

    private let datePicker = UIDatePicker()

    func makeUIView(context: Context) -> UIDatePicker {
        datePicker.datePickerMode = .date
        datePicker.addTarget(context.coordinator, action: #selector(Coordinator.changed(_:)), for: .valueChanged)
        return datePicker
    }

    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        datePicker.date = date
    }

    func makeCoordinator() -> CustomDatePicker.Coordinator {
        Coordinator(date: $date)
    }

    class Coordinator: NSObject {
        private let date: Binding<Date>

        init(date: Binding<Date>) {
            self.date = date
        }

        @objc func changed(_ sender: UIDatePicker) {
            self.date.wrappedValue = sender.date
        }
    }
}
