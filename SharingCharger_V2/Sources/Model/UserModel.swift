//
//  UserModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/09.
//

import Foundation

struct User: Codable {
    let id: Int?    //ID No
    let userType: String?   //사용자 타입
    let username: String?   //개인 소유주 ID
    let email: String?  //이메일 - 일반 사용자 ID
    let password: String?   //비밀번호
    let name: String?   //이름
    let phone: String?  //휴대전화번호
    let companyId: Int? //회사 ID
    let companyName: String?    //회사 명
    let servicePolicyFlag: Bool?    //서비스 이용약관 동의 여부
    let privacyPolicyFlag: Bool?    //개인정보 처리방침 동의 여부
    let created: String?    //생성 일자
    let updated: String?    //갱신 일자
}