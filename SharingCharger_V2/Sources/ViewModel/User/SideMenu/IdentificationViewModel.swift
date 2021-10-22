//
//  IdentificationViewModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/10/22.
//

import Foundation

///회원 증명서 View Model
class IdentificationViewModel: ObservableObject {
    private let userAPI = UserAPIService()  //사용자 API Service
    
    @Published var userIdNo: String = UserDefaults.standard.string(forKey: "userIdNo")! //사용자 ID 번호
    @Published var userId: String = ""  //사용자 ID(이메일)
    @Published var userName: String = ""    //사용자 명
    @Published var did: String = "" //DID 번호
    @Published var issueDate: String = ""   //발급일자
    
    //MARK: - DID 정보 호출
    func getUserDID() {
        let userIdNo = userIdNo
        
        //사용자의 DID 조회 API 호출
        let request = userAPI.requestDID(userIdNo: userIdNo)
        request.execute(
            //API 호출 성공
            onSuccess: { (user) in
                self.userId = user.email!
                self.userName = user.name!
                self.did = user.did ?? "-"
                
                let formatIssueDate = "yyyy-MM-dd HH:mm:ss".toDateFormatter(formatString: user.created!)!
                
                self.issueDate = "yyyy.MM.dd".dateFormatter(formatDate: formatIssueDate)
            },
            //API 호출 실패
            onFailure: { (error) in
                print(error)
            }
        )
    }
}
