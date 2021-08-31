//
//  APIResponse.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/02.
//

import Foundation

//MARK: - Response : 데이터 존재하지 않는 경우 사용
/// Result, Message
struct Response: Codable {
    let result: String  //결과 상태
    let message: String?    //결과 메시지
}

//MARK: - Responses : 데이터 존재하는 경우 사용
/// Result, Message, Data
struct Responses<T: Codable>: Codable {
    let result: String?  //결과 상태
    let message: String?    //결과 메시지
    let data: T? //결과 데이터
}
