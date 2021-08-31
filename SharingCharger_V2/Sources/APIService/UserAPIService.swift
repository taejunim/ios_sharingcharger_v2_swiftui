//
//  UserAPIService.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/09.
//

import Alamofire
import PromisedFuture

//MARK: - 사용자 API Service
class UserAPIService {
    let apiClient = APIClient() //API Client - 공통 API 호출
    
    //MARK: - 로그인 API 호출
    /// 로그인 API 호출
    /// - Parameter parameters:
    ///   - email: 일반 사용자 ID
    ///   - password: 비밀번호
    /// - Returns: User Model
    public func requestSignIn(parameters: [String:Any]) -> Future<User, AFError> {
        
        return apiClient.request(route: APIRouter.post(useApi: "base", path: "/login", parameters: parameters))
    }
    
    //MARK: - 회원가입 API 호출
    /// 회원가입 API 호출
    /// - Parameter parameters:
    ///   - userType: 일반 사용자(General). 개인 소유자(Personal)
    ///   - email: 일반 사용자 ID
    ///   - userName: 개인 소유자 ID
    ///   - password: 비밀번호
    ///   - name: 이름
    ///   - phoneNumber: 휴대전화번호
    ///   - termsAgree: 서비스 이용약관 동의 여부
    ///   - privacyAgree: 개인정보 처리방침 동의 여부
    /// - Returns: User Model
    public func requestSignUp(parameters: [String:Any]) -> Future<User, AFError> {
        
        return apiClient.request(route: APIRouter.post(useApi: "base", path: "/join", parameters: parameters))
    }
    
    //MARK: - 아이디(이메일) 확인 API 호출
    /// 아이디 조회 API 호출
    /// - Parameter userId:
    ///   - 일반 사용자: email
    ///   - 개인 소유주: username
    /// - Returns: User Model
    public func requestCheckId(userId: String) -> Future<User, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/check/\(userId)", parameters: [:], contentType: "json"))
    }
    
    //MARK: - 아이디(이메일) 찾기 API 호출
    /// Description
    /// - Parameter parameters:
    ///   -
    /// - Returns: description
    public func requestFindId(parameters: [String:String]) -> Future<User, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "base", path: "/find/id", parameters: parameters, contentType: "json"))
    }
    
    //MARK: - 인증번호 요청 API 호출
    /// SMS 인증번호 요청 API 호출
    /// - Parameter phoneNumber: 휴대전화번호
    /// - Returns: 인증번호(String)
    public func requestSMSAuth(phoneNumber: String) -> Future<String, AFError> {

        return apiClient.requestText(route: APIRouter.get(useApi: "base", path: "/sms/\(phoneNumber)", parameters: [:], contentType: "text"))
    }
    
    //MARK: - 서비스 이용약관 내용 API 호출
    /// 서비스 이용약관 내용 API 호출
    /// - Returns: HTML Text
    public func requestTerms() -> Future<String, AFError> {

        return apiClient.requestText(route: APIRouter.get(useApi: "base", path: "/policy/service", parameters: [:], contentType: "text"))
    }
    
    //MARK: - 개인정보 처리방침 내용 API 호출
    /// 개인정보 처리방침 내용 API 호출
    /// - Returns: HTML Text
    public func requestPrivacy() -> Future<String, AFError> {

        return apiClient.requestText(route: APIRouter.get(useApi: "base", path: "/policy/privacy", parameters: [:], contentType: "text"))
    }
}
