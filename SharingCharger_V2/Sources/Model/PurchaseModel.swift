//
//  PurchaseModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/24.
//

import Foundation

//MARK: - 구매 정보
struct Purchase:Codable {
    let id: Int //구매 ID번호
    let userId: Int //사용자 ID번호
    let username: String    //사용자 아이디(이메일)
    let paymentType: String?    //결제 유형
    let paymentSuccessType: String? //결제 성공여부
    let approvalNumber: Int?    //결제 승인번호
    let approvalDate: String?   //결제 승인일시
    let userPoint: Int? //사용자 보유 포인트
    let paidAmount: Int?    //구매 포인트
    let cancelAmount: Int?  //구매 취소 포인트
}
