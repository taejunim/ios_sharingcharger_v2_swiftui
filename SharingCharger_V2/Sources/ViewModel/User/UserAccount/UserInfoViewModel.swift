//
//  UserInfoViewModel.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/09.
//

import Foundation

class UserInfoViewModel: ObservableObject {
    private let userAPI = UserAPIService()  //사용자 API Service
    @Published var viewUtil = ViewUtil() //View Util
    
    @Published var result: String = ""  //결과 상태
    @Published var viewPath: String = ""
    @Published var viewTitle: String = ""
    @Published var isShowToast: Bool = false    //Toast 팝업 호출 여부
    
    @Published var isValidation: Bool = false   //유효성 검사 여부
    @Published var showFindAccountPopup: Bool = false
    @Published var isFindAccount: Bool = false
    
    @Published var isSigned: Bool = false
    @Published var isNewPassword: Bool = false
    
    @Published var name: String = ""             //이름
    @Published var email: String = ""            //이메일 - 아이디
    @Published var phone: String = ""            //전화번호
    @Published var authNumber: String = ""       //인증번호
    
    
    @Published var isAuthRequest: Bool = false  //인증 요청 여부
    @Published var isReRequest: Bool = false    //인증 재요청 여부
    @Published var receivedAuthNumber: String = ""  //API 호출 인증번호
    @Published var isAuthComplete: Bool = false //인증 완료 여부
    
    @Published var isStartTimer: Bool = false   //타이머 시작 여부
    @Published var minutesRemaining: Int = 3    //타이머 분 시간 설정(기본값: 3)
    @Published var secondsRemaining: Int = 0    //타이머 초 시간 설정(기본값: 0)
    
    @Published var currentPassword: String = "" //현재 비밀번호
    @Published var newPassword: String = ""    //비밀번호
    @Published var confirmNewPassword: String = "" //비밀번호 확인
    
    @Published var searchId: [String:String] = [:]    //조회한 아이디 정보
    @Published var searchIds: [[String:String]] = []    //조회한 아이디 정보 목록
    
    //MARK: - 아이디 찾기 실행
    func requestFindId() {
        viewUtil.isLoading = true   //로딩 시작
        searchIds.removeAll()       //조회한 아이디 목록 정보 초기화
        
        let parameters: [String:String] = [
            "name": name,       //사용자 이름
            "phone": phone      //사용자 전화번호
        ]
        
        //아이디(이메일) 찾기 API 호출
        let request = userAPI.requestFindId(parameters: parameters)
        request.execute(
            //아이디 찾기 성공
            onSuccess: { (findId) in
                self.result = "success"
                self.viewUtil.isLoading = false //로딩 종료
                
                //아이디 찾기 화면일 경우
                if self.viewPath == "findAccount"{
                    //값이 없을 경우
                    if findId.count == 0 {
                        self.isFindAccount = false //false일 경우 fail 창
                    }
                    //값이 있을 경우
                    else{
                        self.isFindAccount = true   //true일 경우 결과 창
                        
                        for index in 0..<findId.count {
                            let findId = findId[index]
                            self.searchId = [
                                "username": findId.username!    //아이디(이메일)
                            ]
                            self.searchIds.append(self.searchId)    //조회한 아이디를 배열에 저장
                        }
                    }
                }
                //비밀번호 변경 화면일 경우
                else if self.viewPath == "changePassword"{
                    //아이디가 조회되지 않을 경우
                    if findId.count == 0 {
                        self.viewUtil.showToast(isShow: true, message: "fail.findId".message()) //조회 실패 메시지
                        self.isNewPassword = false  //비밀번호 변경 완료 화면으로 넘어가지 않음
                    }else{
                        //조회된 아이디 수만큼 출력
                        for index in 0..<findId.count {
                            let findId = findId[index]
                            self.searchId = [
                                "username": findId.username!    //아이디(이메일)
                            ]
                            self.searchIds.append(self.searchId)    //조회한 아이디를 배열에 저장

                            if self.email == findId.username!{
                                self.isNewPassword = true   //아이디가 일치할 경우
                            }else{
                                self.isNewPassword = false //아이디가 일치하지 않을 경우
                                self.viewUtil.showToast(isShow: true, message: "fail.findId".message()) //조회 실패 메시지
                            }
                        }
                    }
                }
                
            },
            
            //아이디(이메일) 찾기 API 호출 실패
            onFailure: { (error) in
                self.isFindAccount = false
                switch error {
                    //에러
                    case .responseSerializationFailed:
                        self.result = "fail"
                        //일시적인 서버 오류 및 네트워크 오류
                    default:
                        self.showFindAccountPopup = false
                        self.result = "server error"
                        self.viewUtil.showToast(isShow: true, message: "server.error".message())    //서버 에러 메시지 출력
                    break
                }
                //비밀번호 변경 화면일 경우
                if self.viewPath == "changePassword"{
                    self.viewUtil.showToast(isShow: true, message: "fail.findId".message()) //조회 실패 메시지 출력
                    self.isNewPassword = false   //비밀번호 변경 완료 화면으로 넘어가지 않음
                }
                
                self.viewUtil.isLoading = false //로딩 종료
                
            }
        )
    }
    //MARK: - 비밀번호 변경 실행(로그인 한 상태)
    func requestChangePassword(completion: @escaping (String) -> Void){
        viewUtil.isLoading = true   //로딩 시작
        
        let parameters: [String:String] = [
            "currentPassword": currentPassword,     //현재 비밀번호
            "password": newPassword                 //새 비밀번호
        ]
        let userId = UserDefaults.standard.string(forKey: "userId") ?? "User ID"
        
        //아이디(이메일) 찾기 API 호출
        let request = userAPI.requestChangePassword(userId:userId,parameters: parameters)
        request.execute(
            //아이디 찾기 성공
            onSuccess: { (findId) in
                
                self.result = "success"
                
                self.viewUtil.showToast(isShow: true, message: "success.change.password".message())//비밀번호 변경 완료 메시지
                
                completion(self.result)
            },
            
            //아이디(이메일) 찾기 API 호출 실패
            onFailure: { (error) in
                
                switch error {
                    //에러
                case .responseSerializationFailed:
                    self.result = "fail"
                    self.viewUtil.showToast(isShow: true, message: "fail.change.password".message())//비밀번호 변경 실패 메시지
                    //일시적인 서버 오류 및 네트워크 오류
                default:
                    self.showFindAccountPopup = false
                    self.result = "server error"
                    self.viewUtil.showToast(isShow: true, message: "server.error".message())    //서버 에러 메시지 출력
                    break
                }
                self.viewUtil.isLoading = false //로딩 종료
                
                completion(self.result)
            }
        )
    }
    //MARK: - 비밀번호 초기화 후 변경 실행(로그인 안한 상태)
    func requestResetPassword(completion: @escaping (String) -> Void){
        viewUtil.isLoading = true   //로딩 시작
        
        let parameters: [String:String] = [
            "password": newPassword        //새 비밀번호 확인
        ]
        
        //아이디(이메일) 찾기 API 호출
        let request = userAPI.requestResetPassword(userId:email,parameters: parameters)
        request.execute(
            //아이디 찾기 성공
            onSuccess: { (findId) in
                self.result = "success"
             
                self.viewUtil.showToast(isShow: true, message: "success.change.password".message())//비밀번호 변경 완료 메시지
                
                completion(self.result)
            },
            
            //아이디(이메일) 찾기 API 호출 실패
            onFailure: { (error) in
                
                switch error {
                    //에러
                case .responseSerializationFailed:
                    self.result = "fail"
                    self.viewUtil.showToast(isShow: true, message: "fail.change.password".message())//비밀번호 변경 실패 메시지
                    //일시적인 서버 오류 및 네트워크 오류
                default:
                    self.showFindAccountPopup = false
                    self.result = "server error"
                    self.viewUtil.showToast(isShow: true, message: "server.error".message())    //서버 에러 메시지 출력
                    break
                }
                self.viewUtil.isLoading = false //로딩 종료
                
                completion(self.result)
            }
        )
    }
    
    //MARK: - 인증 요청 실행
    func authRequest() {
        //휴대전화번호 입력 여부 확인
        if !phone.isEmpty {
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
        let request = userAPI.requestSMSAuth(phoneNumber: phone)
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
    //MARK: - 이름 유효성 검사
    func isNameValid() -> Bool {
        let regExp = "^[가-힣ㄱ-ㅎㅏ-ㅣ]{2,10}$"  //한글 (2~10자)
        let predicate = NSPredicate(format: "SELF MATCHES %@", regExp)
        
        return predicate.evaluate(with: name)
    }
    //MARK: - 휴대전화번호 유효성 검사
    func isPhoneNumberValid() -> Bool {
        let regExp = "^[0-9]{10,11}$" //숫자 (10~11자)
        let predicate = NSPredicate(format: "SELF MATCHES %@", regExp)
        
        return predicate.evaluate(with: phone)
    }
    //MARK: - 인증번호 유효성 검사
    func isAuthNumberValid() -> Bool {
        let regExp = "^[0-9]{6,6}$" //숫자 (6자)
        let predicate = NSPredicate(format: "SELF MATCHES %@", regExp)
        
        return predicate.evaluate(with: authNumber)
    }
    //MARK: - 아이디(이메일) 유효성 검사
    func isIdValid() -> Bool {
        let regExp = "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,64}" //아매알 형식
        let predicate = NSPredicate(format: "SELF MATCHES %@", regExp)
        
        return predicate.evaluate(with: email)
    }
    //MARK: - 비밀번호 유효성 검사
    func isCurrentPasswordValid() -> Bool {
        let regExp = "^(?=.*[a-zA-Z])(?=.*\\d)(?=.*[!@#$%^&*?])(?=.*[0-9])[a-zA-Z\\d!@#$%^&*?]{6,20}"   //영문, 숫자, 특수문자 (6~20자)
        let predicate = NSPredicate(format: "SELF MATCHES %@", regExp)
        
        return predicate.evaluate(with: currentPassword)
    }
    //MARK: - 비밀번호 유효성 검사
    func isPasswordValid() -> Bool {
        let regExp = "^(?=.*[a-zA-Z])(?=.*\\d)(?=.*[!@#$%^&*?])(?=.*[0-9])[a-zA-Z\\d!@#$%^&*?]{6,20}"   //영문, 숫자, 특수문자 (6~20자)
        let predicate = NSPredicate(format: "SELF MATCHES %@", regExp)
        
        return predicate.evaluate(with: newPassword)
    }
    
    //MARK: - 비밀번호 확인 유효성 검사
    func isConfirmPasswordValid() -> Bool {
        let regExp = "^(?=.*[a-zA-Z])(?=.*\\d)(?=.*[!@#$%^&*?])(?=.*[0-9])[a-zA-Z\\d!@#$%^&*?]{6,20}"   //영문, 숫자, 특수문자 (6~20자)
        let predicate = NSPredicate(format: "SELF MATCHES %@", regExp)
        
        return predicate.evaluate(with: confirmNewPassword)
    }
 
    //MARK: - 유효성 검사
    func validationCheck() -> Bool {
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
        if viewPath == "changePassword"{ //비밀번호 변경 화면일 때
            
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
        }
        
        //휴대전화번호 입력 여부 확인
        if phone.isEmpty {
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
        
        
        return true
    }
    //MARK: - 비밀번호 유효성 검사
    func passwordValidationCheck() -> Bool {
        isValidation = true
        
        //로그인한 상태일 떄
        if isSigned == true{
            //현재 비밀번호 입력 여부 확인
            if currentPassword.isEmpty {
                viewUtil.showToast(isShow: true, message: "input.empty.currentPassword".message())
                return false
            }
            else {
                //현재 비밀번호 유효성 검사
                guard isCurrentPasswordValid() else {
                    viewUtil.showToast(isShow: true, message: "input.invalid.currentPassword".message())
                    return false
                }
            }
        }
       
        //새 비밀번호 입력 여부 확인
        if newPassword.isEmpty {
            viewUtil.showToast(isShow: true, message: "input.empty.newPassword".message())
            return false
        }
        else {
            //비밀번호 유효성 검사
            guard isPasswordValid() else {
                viewUtil.showToast(isShow: true, message: "input.invalid.newPassword".message())
                return false
            }
        }
        
        //비밀번호 확인 입력 여부 확인
        if confirmNewPassword.isEmpty {
            viewUtil.showToast(isShow: true, message: "input.empty.confirmNewPassword".message())
            return false
        }
        else {
            //비밀번호 확인 유효성 검사
            guard isConfirmPasswordValid() else {
                viewUtil.showToast(isShow: true, message: "input.invalid.confirmNewPassword".message())
                return false
            }
        }
        //입력한 비밀번호 일치 여부 확인
        if newPassword != confirmNewPassword {
            confirmNewPassword = ""
            viewUtil.showToast(isShow: true, message: "mismatch.password".message())
            return false
        }
        
        return true
    }
    //MARK: - 화면 초기화
    func viewReset() {
        
        isValidation = false
        
        result = ""  //결과 상태
        isShowToast = false    //Toast 팝업 호출 여부
        isValidation = false   //유효성 검사 여부
        
        name = ""    //이름
        phone = "" //전화번호
        authNumber = ""  //인증번호
        email = ""  //아이디(이메일)
        
        
        isAuthRequest = false  //인증 요청 여부
        isReRequest = false    //인증 재요청 여부
        receivedAuthNumber = ""  //API 호출 인증번호
        isAuthComplete = false //인증 완료 여부
        
        
        isStartTimer = false
        minutesRemaining = 3    //타이머 분 시간 설정(기본값: 3)
        secondsRemaining = 0    //타이머 초 시간 설정(기본값: 0)
    }
    //MARK: - 화면 초기화
    func changePwViewReset() {
        isValidation = false
        
        result = ""  //결과 상태
        
        currentPassword = ""
        newPassword = ""
        confirmNewPassword = ""
    }
}
