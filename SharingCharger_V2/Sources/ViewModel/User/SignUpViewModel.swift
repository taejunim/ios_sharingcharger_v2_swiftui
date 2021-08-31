//
//  SignUpViewModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/05.
//

import SwiftUI
import Foundation
import Combine

class SignUpViewModel: ObservableObject {
    private let userAPI = UserAPIService()  //사용자 API Service
    @Published var viewUtil = ViewUtil() //View Util
    
    @Published var result: String = ""  //결과 상태
    @Published var isShowToast: Bool = false    //Toast 팝업 호출 여부
    @Published var isValidation: Bool = false   //유효성 검사 여부
    
    @Published var name: String = ""    //이름
    @Published var email: String = ""   //이메일 - 아이디
    @Published var phoneNumber: String = "" //전화번호
    @Published var authNumber: String = ""  //인증번호
    @Published var password: String = ""    //비밀번호
    @Published var confirmPassword: String = "" //비밀번호 확인
    
    @Published var isDuplicateCheck: Bool = false   //중복 확인 여부
    @Published var duplicateStaus: String = "" //중복 상태
    @Published var confirmId: String = "" //중복 확인 완료 ID
    
    @Published var isAuthRequest: Bool = false  //인증 요청 여부
    @Published var isReRequest: Bool = false    //인증 재요청 여부
    @Published var receivedAuthNumber: String = ""  //API 호출 인증번호
    @Published var isAuthComplete: Bool = false //인증 완료 여부
    
    @Published var isTermsContent: Bool = false //서비스 이용약관 보기 여부
    @Published var isPrivacyContent: Bool = false   //개인정보 처리방침 보기 여부
    @Published var isTermsAgree: Bool = false   //서비스 이용약관 동의 여부
    @Published var isPrivacyAgree: Bool = false //개인정보 처리방침 동의 여부
    
    @Published var isGetContent: Bool = false  //약관 정보 호출 여부
    @Published var termsContent: String = ""    //서비스 이용약관 내용
    @Published var privacyContent: String = ""  //개인정보 처리방침 내용

    @Published var isStartTimer: Bool = false   //타이머 시작 여부
    @Published var minutesRemaining: Int = 3    //타이머 분 시간 설정(기본값: 3)
    @Published var secondsRemaining: Int = 0    //타이머 초 시간 설정(기본값: 0)
    
    //MARK: - 회원가입 실행
    func signUp(completion: @escaping (String) -> Void) {
        viewUtil.isLoading = true   //로딩 시작
        
        let parameters: [String:Any] = [
            "userType": "General",  //사용자 타입 - 일반 사용자(General)
            //"userType": "Personal",  //사용자 타입 - 개인 소유주(Personal)
            "email": email, //일반 사용자 ID
            "username": "", //개인 소유자 ID
            "password": password,   //비밀번호
            "name": name,   //사용자 이름
            "phone": phoneNumber,   //휴대전화번호
            "servicePolicyFlag": isTermsAgree,  //서비스 이용약관 동의 여부
            "privacyPolicyFlag": isPrivacyAgree //개인정보 처리방침 동의 여부
        ]
        
        //회원가입 API 호출
        let request = userAPI.requestSignUp(parameters: parameters)
        request.execute(
            //회원가입 성공
            onSuccess: { (signUp) in
                self.result = "success"
                self.viewUtil.showToast(isShow: true, message: "success.signup".message())  //회원가입 성공 메시지 출력
                self.viewUtil.isLoading = false //로딩 종료
                
                completion(self.result)
            },
            //회원가입 실패
            onFailure: { (error) in
                switch error {
                //유효하지 않는 ID 또는 잘못된 비밀번호 엽력 오류
                case .responseSerializationFailed:
                    self.result = "fail"
                    self.viewUtil.showToast(isShow: true, message: "fail.signup".message()) //회원가입 실패 메시지 출력
                //일시적인 서버 오류 및 네트워크 오류
                default:
                    self.result = "server error"
                    self.viewUtil.showToast(isShow: true, message: "server.error".message())    //서버 에러 메시지 출력
                    break
                }

                self.viewUtil.isLoading = false //로딩 종료
                
                completion(self.result)
            }
        )
    }
    
    //MARK: - 아이디(이메일) 중복 확인 실행
    func duplicateCheck() {
        isDuplicateCheck = true //중복확인 여부
        duplicateStaus = "" //중복 상태 초기화
        confirmId = ""  //중복확인 완료 ID
        
        //아이디(이메일) 입력 여부 확인
        if !email.isEmpty {
            //아이디(이메일) 유효성 여부 확인
            if isIdValid() {
                //아이디(이메일) 확인 API 호출
                let request = userAPI.requestCheckId(userId: email)
                request.execute(
                    onSuccess: { (checkId) in
                        self.duplicateStaus = "duplicate"   //중복 상태
                        self.viewUtil.showToast(isShow: true, message: "duplicate.id".message())    //중복 아이디(이메일) 메시지 출력
                    },
                    onFailure: { (error) in
                        switch error {
                        //유효하지 않는 ID 또는 잘못된 비밀번호 엽력 오류
                        case .responseSerializationFailed:
                            self.duplicateStaus = "non duplicate"   //비중복 상태
                            self.confirmId = self.email //중복확인 완료 ID
                            self.viewUtil.showToast(isShow: true, message: "non.duplicate.id".message())    //사용 가능한 아이디(이메일) 메시지 출력
                        //일시적인 서버 오류 및 네트워크 오류
                        default:
                            self.duplicateStaus = "server error"    //서버 에러
                            self.viewUtil.showToast(isShow: true, message: "server.error".message())    //서버 에러 메시지 출력
                            break
                        }
                    }
                )
            }
            else {
                viewUtil.showToast(isShow: true, message: "input.invalid.email".message())  //유효하지 않는 아이디(이메일) 메시지 출력
            }
        }
        else {
            viewUtil.showToast(isShow: true, message: "input.empty.email".message()) //아이디(이메일) 미입력 메시지 출력
        }
    }
    
    //MARK: - 인증 요청 실행
    func authRequest() {
        //휴대전화번호 입력 여부 확인
        if !phoneNumber.isEmpty {
            if isPhoneNumberValid() {
                minutesRemaining = 3    //타이머 분 시간 초기화
                secondsRemaining = 0    //타이머 초 시간 초기화

                //인증번호 API 호출 후 인증 시작
                getAuthNumber(completion: { (authNumber) in
                    //인증번호 호출 성공
                    if authNumber != "error" {
                        self.isStartTimer = true    //인증 타이머 시작
                        self.isAuthRequest = true   //인증 시작
                        self.receivedAuthNumber = authNumber    //API 호출을 통해 받은 인증번호
                    }
                    //인증번호 호출 실패
                    else {
                        self.isShowToast = true
                        self.viewUtil.showToast(isShow: self.isShowToast, message: "server.error".message())    //에러 메시지 호출
                    }
                })
            }
            else {
                isShowToast = true
                viewUtil.showToast(isShow: isShowToast, message: "input.invalid.phone".message())   //유효하지 않은 전화번호 메시지 출력
            }
        }
        else {
            isShowToast = true
            viewUtil.showToast(isShow: isShowToast, message: "input.empty.phone".message()) //휴대전화번호 미입력 메시지 출력
        }
    }
    
    //MARK: - 인증번호 API 호출
    func getAuthNumber(completion: @escaping (String) -> Void) {
        //SMS 인증번호 API 호출
        let request = userAPI.requestSMSAuth(phoneNumber: phoneNumber)
        request.execute(
            onSuccess: { (authNumber) in
                completion(authNumber)
                print(authNumber)
            },
            onFailure: { (error) in
                completion("error")
            }
        )
    }
    
    //MARK: - 인증 시간 카운트다운 실행
    func authTimer() {
        if isStartTimer {
            //초 단위가 0인 경우
            if secondsRemaining == 0 {
                //분 단위가 0보다 클 경우
                if minutesRemaining > 0 {
                    minutesRemaining -= 1   //타이머 1분 감소
                    secondsRemaining = 59   //타이머 59초 설정
                }
                else {
                    self.receivedAuthNumber = ""    //API 호출 인증번호 초기화
                    self.isStartTimer = false   //타이머 종료
                    self.isReRequest = true //재요청 여부
                    
                    viewUtil.showToast(isShow: isShowToast, message: "auth.fail".message()) //인증 실패 메시지
                }
            }
            else {
                secondsRemaining -= 1   //타이머 1초 감소
            }
        }
    }
    
    //MARK: - 인증번호 확인 실행
    func checkAuthNumber() {
        isShowToast = true  //Toast 팝업 호출 여부
        
        if !authNumber.isEmpty {
            if isAuthNumberValid() {
                //입력한 인증번호와 API 호출 인증번호 비교
                if authNumber == receivedAuthNumber {
                    isAuthComplete = true   //인증 완료
                    isStartTimer = false    //타이머 종료
                    isAuthRequest = false   //인증 종료
                    
                    viewUtil.showToast(isShow: isShowToast, message: "auth.complete".message()) //인증번호 일치 메시지
                }
                else {
                    viewUtil.showToast(isShow: isShowToast, message: "auth.mismatch.number".message())  //인증번호 불일치 메시지
                }
            }
            else {
                viewUtil.showToast(isShow: isShowToast, message: "input.invalid.auth.number".message()) //인증번호 유효성 메시지
            }
        }
        else {
            viewUtil.showToast(isShow: isShowToast, message: "input.empty.auth.number".message())   //인증번호 미입력 메시지
        }
    }
    
    //MARK: - 서비스 이용약관 내용 호출
    func getTermsContent() {
        //인증 진행 여부 확인
        if !isStartTimer {
            //서비스 이용약관 내용 API 호출
            let request = userAPI.requestTerms()
            request.execute(
                //호출 성공
                onSuccess: { (content) in
                    self.isGetContent = true    //내용 호출 성공
                    self.termsContent = content //서비스 이용약관 내용
                    self.isTermsContent = true  //서비스 이용약관 보기
                },
                //호출 실패
                onFailure: { (error) in
                    self.isGetContent = false   //내용 호출 실패
                    self.isTermsContent = true  //서비스 이용약관 보기
                }
            )
        }
        //인증 진행 중인 경우 메시지 출력
        else {
            isShowToast = true
            viewUtil.showToast(isShow: isShowToast, message: "auth.in.progress".message())   //인증 진행 중 메시지
        }
    }
    
    //MARK: - 개인정보 처리방침 내용 호출
    func getPrivacyContent() {
        //인증 진행 여부 확인
        if !isStartTimer {
            //개인정보 처리방침 내용 API 호출
            let request = userAPI.requestPrivacy()
            request.execute(
                //호출 성공
                onSuccess: { (content) in
                    self.isGetContent = true    //내용 호출 성공
                    self.privacyContent = content   //개인정보 처리방침 내용
                    self.isPrivacyContent = true    //개인정보 처리방침 보기
                },
                //호출 실패
                onFailure: { (error) in
                    self.isGetContent = false   //내용 호출 실패
                    self.isPrivacyContent = true    //개인정보 처리방침 보기
                }
            )
        }
        //인증 진행 중인 경우 메시지 출력
        else {
            isShowToast = true
            viewUtil.showToast(isShow: isShowToast, message: "auth.in.progress".message())   //인증 진행 중 메시지
        }
    }
    
    //MARK: - 이름 유효성 검사
    func isNameValid() -> Bool {
        let regExp = "^[가-힣ㄱ-ㅎㅏ-ㅣ]{2,10}$"  //한글 (2~10자)
        let predicate = NSPredicate(format: "SELF MATCHES %@", regExp)
        
        return predicate.evaluate(with: name)
    }
    
    //MARK: - 아이디(이메일) 유효성 검사
    func isIdValid() -> Bool {
        let regExp = "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,64}" //아매알 형식
        let predicate = NSPredicate(format: "SELF MATCHES %@", regExp)
        
        return predicate.evaluate(with: email)
    }
    
    //MARK: - 휴대전화번호 유효성 검사
    func isPhoneNumberValid() -> Bool {
        let regExp = "^[0-9]{10,11}$" //숫자 (10~11자)
        let predicate = NSPredicate(format: "SELF MATCHES %@", regExp)
        
        return predicate.evaluate(with: phoneNumber)
    }
    
    //MARK: - 인증번호 유효성 검사
    func isAuthNumberValid() -> Bool {
        let regExp = "^[0-9]{6,6}$" //숫자 (6자)
        let predicate = NSPredicate(format: "SELF MATCHES %@", regExp)
        
        return predicate.evaluate(with: authNumber)
    }
    
    //MARK: - 비밀번호 유효성 검사
    func isPasswordValid() -> Bool {
        let regExp = "^(?=.*[a-zA-Z])(?=.*\\d)(?=.*[!@#$%^&*?])(?=.*[0-9])[a-zA-Z\\d!@#$%^&*?]{6,20}"   //영문, 숫자, 특수문자 (6~20자)
        let predicate = NSPredicate(format: "SELF MATCHES %@", regExp)

        return predicate.evaluate(with: password)
    }
    
    //MARK: - 비밀번호 확인 유효성 검사
    func isConfirmPasswordValid() -> Bool {
        let regExp = "^(?=.*[a-zA-Z])(?=.*\\d)(?=.*[!@#$%^&*?])(?=.*[0-9])[a-zA-Z\\d!@#$%^&*?]{6,20}"   //영문, 숫자, 특수문자 (6~20자)
        let predicate = NSPredicate(format: "SELF MATCHES %@", regExp)

        return predicate.evaluate(with: confirmPassword)
    }
    
    //MARK: - 유효성 검사
    func validation() -> Bool {
        
        isValidation = true
        
        //이름 입력 여부 확인
        if name.isEmpty {
            viewUtil.showToast(isShow: true, message: "input.empty.name".message())
            return false
        }
        else {
            //이름 유효성 검사
            guard isNameValid() else {
                viewUtil.showToast(isShow: true, message: "input.invalid.name".message())
                return false
            }
        }
        
        //아이디(이메일) 입력 여부 확인
        if email.isEmpty {
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
        
        //중복확인 여부 확인
        if !isDuplicateCheck {
            viewUtil.showToast(isShow: true, message: "no.duplicate.check".message())
            return false
        }
        else {
            //입력한 아이디(이메일)과 중복확인 완료 아이디가 다른 경우
            if email != confirmId {
                isDuplicateCheck = false    //중복확인 여부 초기화
                duplicateStaus = "" //중복 상태 초기화
                confirmId = ""  //중복확인 완료 아이디 초기화
                viewUtil.showToast(isShow: true, message: "mismatch.check.id".message())
                return false
            }
        }
        
        //휴대전화번호 입력 여부 확인
        if phoneNumber.isEmpty {
            viewUtil.showToast(isShow: true, message: "input.empty.phone".message())
            return false
        }
        else {
            //휴대전화번호 유효성 검사
            guard isPhoneNumberValid() else {
                viewUtil.showToast(isShow: true, message: "input.invalid.phone".message())
                return false
            }
        }
        
        //인증 완료 여부 확인
        if !isAuthComplete {
            viewUtil.showToast(isShow: true, message: "auth.not.complete".message())
            return false
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
        
        //비밀번호 확인 입력 여부 확인
        if confirmPassword.isEmpty {
            viewUtil.showToast(isShow: true, message: "input.empty.confirm.password".message())
            return false
        }
        else {
            //비밀번호 확인 유효성 검사
            guard isConfirmPasswordValid() else {
                viewUtil.showToast(isShow: true, message: "input.invalid.password".message())
                return false
            }
        }
        
        //입력한 비밀번호 일치 여부 확인
        if password != confirmPassword {
            confirmPassword = ""
            viewUtil.showToast(isShow: true, message: "mismatch.password".message())
            return false
        }
        
        //서비스 이용약관 동의 여부 확인
        if !isTermsAgree {
            viewUtil.showToast(isShow: true, message: "policy.disagree.terms".message())
            return false
        }
        
        //개인정보 처리방침 동의 여부 확인
        if !isPrivacyAgree {
            viewUtil.showToast(isShow: true, message: "policy.disagree.privacy".message())
            return false
        }
        
        return true
    }
    
    //MARK: - 화면 초기화
    func viewReset() {
        result = ""  //결과 상태
        isShowToast = false    //Toast 팝업 호출 여부
        isValidation = false   //유효성 검사 여부
        
        name = ""    //이름
        email = ""   //이메일 - 아이디
        phoneNumber = "" //전화번호
        authNumber = ""  //인증번호
        password = ""    //비밀번호
        confirmPassword = "" //비밀번호 확인
        
        isDuplicateCheck = false   //중복 확인 여부
        duplicateStaus = "" //중복 상태
        confirmId = "" //중복 확인 완료 ID
        
        isAuthRequest = false  //인증 요청 여부
        isReRequest = false    //인증 재요청 여부
        receivedAuthNumber = ""  //API 호출 인증번호
        isAuthComplete = false //인증 완료 여부
        
        isTermsContent = false //서비스 이용약관 보기 여부
        isPrivacyContent = false   //개인정보 처리방침 보기 여부
        isTermsAgree = false   //서비스 이용약관 동의 여부
        isPrivacyAgree = false //개인정보 처리방침 동의 여부
        
        isGetContent = false  //약관 정보 호출 여부
        termsContent = ""    //서비스 이용약관 내용
        privacyContent = ""  //개인정보 처리방침 내용

        isStartTimer = false
        minutesRemaining = 3    //타이머 분 시간 설정(기본값: 3)
        secondsRemaining = 0    //타이머 초 시간 설정(기본값: 0)
    }
}
