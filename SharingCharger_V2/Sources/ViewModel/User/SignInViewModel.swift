//
//  SignInViewModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/04.
//

import Foundation
import Combine

class SignInViewModel: ObservableObject {
    public var didChange = PassthroughSubject<SignInViewModel, Never>()
    
    private let userAPI = UserAPIService()  //사용자 API Service
    @Published var viewUtil = ViewUtil() //View Util

    @Published var id: String = ""  //아이디 - 이메일
    @Published var password: String = ""    //비밀번호
    @Published var isSignIn: Bool = false   //로그인 성공 여부
    @Published var isValidation: Bool = false   //유효성 검사 여부

    @Published var signInStatus: String = ""    //로그인 상태
    
    //로그인 결과
    @Published var result: String = "" {
        didSet {
            didChange.send(self)
        }
    }
    
    //MARK: - 자동 로그인 실행
    /// - Parameters:
    ///   - userId: 사용자 아이디(이메일)
    ///   - password: 비밀번호
    ///   - completion: 로그인 결과 상태
    func autoSignIn(userId: String, password: String, completion: @escaping (String) -> Void) {
        
        let parameters = [
            "loginId": userId,    //아이디
            "password": password  //비밀번호
        ]
        
        var signinStatus: String = ""

        //로그인 API 호출
        let request = userAPI.requestSignIn(parameters: parameters)
        request.execute(
            //로그인 성공
            onSuccess: { (signIn) in
                signinStatus = "success"
                completion(signinStatus)
            },
            //로그인 실패
            onFailure: { (error) in
                switch error {
                //유효하지 않는 ID 또는 잘못된 비밀번호 엽력 오류
                case .responseSerializationFailed:
                    signinStatus = "fail"
                    completion(signinStatus)
                //일시적인 서버 오류 및 네트워크 오류
                default:
                    signinStatus = "error"
                    completion(signinStatus)
                    break
                }
            }
        )
    }
    
    //MARK: - 로그인 실행
    func signIn() {
        
        viewUtil.isLoading = true
        
        //API 호출 - Request Body
        let parameters = [
            "loginId": id,    //아이디 - 일반 사용자: email/소유주: username
            "password": password  //비밀번호
//            "loginId": "personal@test.com",   //임시 - 소유자
//            "loginId": "general@test.com",  //임시 - 일반 사용자
//            "password": "test123!"  //임시 - 비밀번호
        ]

        //로그인 API 호출
        let request = userAPI.requestSignIn(parameters: parameters)
        request.execute(
            //로그인 성공
            onSuccess: { (signIn) in
                print("Success: \(signIn)")
                
                UserDefaults.standard.set(signIn.id, forKey: "userIdNo")
                UserDefaults.standard.set(signIn.email, forKey: "userId")
                UserDefaults.standard.set(self.password, forKey: "password")
                
                self.result = "success"
                self.viewUtil.showToast(isShow: true, message: "success.signin".message())
                
                self.id = ""    //아이디(이메일) 초기화
                self.password = ""  //비밀번호 초기화
                
                self.viewUtil.nextView()    //다음화면 이동 여부 변경
            },
            //로그인 실패
            onFailure: { (error) in
                print("Failure: \(error)")
                
                switch error {
                //유효하지 않는 ID 또는 잘못된 비밀번호 엽력 오류
                case .responseSerializationFailed:
                    self.result = "fail"
                    self.viewUtil.showToast(isShow: true, message: "fail.signin".message())
                //일시적인 서버 오류 및 네트워크 오류
                default:
                    self.result = "server error"
                    self.viewUtil.showToast(isShow: true, message: "server.error".message())
                    
                    break
                }
                
                self.viewUtil.isLoading = false
            }
        )
    }
    
    //MARK: - 아이디(이메일) 유효성 검사
    func isIdValid() -> Bool {
        let regExp = "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,64}" //아매알 형식
        let predicate = NSPredicate(format: "SELF MATCHES %@", regExp)
        
        return predicate.evaluate(with: id)
    }
    
    //MARK: - 비밀번호 유효성 검사
    func isPasswordValid() -> Bool {
        let regExp = "^(?=.*[a-zA-Z])(?=.*\\d)(?=.*[!@#$%^&*?])(?=.*[0-9])[a-zA-Z\\d!@#$%^&*?]{6,20}"   //영문, 숫자, 특수문자
        let predicate = NSPredicate(format: "SELF MATCHES %@", regExp)

        return predicate.evaluate(with: password)
    }
    
    //MARK: - 유효성 검사
    func validation() -> Bool {
        
        isValidation = true
        
        //아이디(이메일) 입력 여부 확인
        if id.isEmpty {
            viewUtil.showToast(isShow: true, message: "input.empty.email".message())
            return false
        }
        else {
            //아이디(이메일) 유효성 검사
            guard isIdValid() else {
                viewUtil.showToast(isShow: true, message: "input.invalid.email".message())
                return false
            }
        }
        
        //비밀번호 입력 여부 확인
        if password.isEmpty {
            viewUtil.showToast(isShow: true, message: "input.empty.password".message())
            return false
        }
        else {
            //비밀번호 유효성 검사
            guard isPasswordValid() else {
                viewUtil.showToast(isShow: true, message: "input.invalid.password".message())
                return false
            }
        }
        
        return true
    }
}
