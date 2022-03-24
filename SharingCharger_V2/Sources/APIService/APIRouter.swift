//
//  APIRouter.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/02.
//

import Alamofire

/// API 연동을 위한 요청 URL 변환
enum APIRouter: URLRequestConvertible {
    
    //MARK: - Request Method
    case get(useApi: String, path: String, parameters: [String:String], contentType: String)    //GET
    case post(useApi: String, path: String, parameters: [String:Any], contentType: String)  //POST
    case put(useApi: String, path: String, parameters: [String:Any])   //PUT
    case patch(useApi: String, path: String, parameters: [String:Any])   //PATCH

    //static let baseApiUrl: String = "http://211.253.37.97:52340/api/v1"   //전기차 공유 충전기 개발 API URL
    static let baseApiUrl: String = "https://monttak.co.kr/api/v1"   //전기차 공유 충전기 운영 API URL
    static let addressApiUrl: String = "https://dapi.kakao.com/v2/local"    //주소 검색 API - Kakao API
    static let kakaoAPIKey: String = "KakaoAK 4332dce3f2f8d3ee87e31884c5c5523d" //Kakao API Key
    
    //MARK: - Base URL
    private var baseURL: String {
        switch self {
        case .get(let useApi, _, _, _):
            switch useApi {
            case "base":
                return APIRouter.baseApiUrl
            case "address":
                return APIRouter.addressApiUrl
            default:
                return APIRouter.baseApiUrl
            }
        case .post(let useApi, _, _, _):
            switch useApi {
            case "base":
                return APIRouter.baseApiUrl
            case "address":
                return APIRouter.addressApiUrl
            default:
                return APIRouter.baseApiUrl
            }
        case .put(let useApi, _, _):
            switch useApi {
            case "base":
                return APIRouter.baseApiUrl
            case "address":
                return APIRouter.addressApiUrl
            default:
                return APIRouter.baseApiUrl
            }
        case .patch(let useApi, _, _):
            switch useApi {
            case "base":
                return APIRouter.baseApiUrl
            case "address":
                return APIRouter.addressApiUrl
            default:
                return APIRouter.baseApiUrl
            }
        }
    }
    
    //MARK: - HTTP Method
    private var method: HTTPMethod {
        switch self {
        case .get:
            return .get
        case .post:
            return .post
        case .put:
            return .put
        case .patch:
            return .patch
        }
    }
    
    //MARK: - Path
    private var path: String {
        switch self {
        case .get( _, let path, _, _):
            return path
        case .post( _, let path, _, _):
            return path
        case .put( _, let path, _):
            return path
        case .patch( _, let path, _):
            return path
        }
    }
    
    //MARK: - Parameters
    private var parameters: Parameters? {
        switch self {
        case .get( _, _, let parameters, _):
            return parameters
        case .post( _, _, let parameters, _):
            return parameters
        case .put( _, _, let parameters):
            return parameters
        case .patch( _, _, let parameters):
            return parameters
        }
    }
        
    // MARK: - URL 요청 변환
    /// 요청 URL 변환
    /// - Throws: URLRequest
    /// - Returns: URLRequest
    func asURLRequest() throws -> URLRequest {
        //MARK: - URL
        let url = try baseURL.asURL()   //API URL
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))  //Base URL + Path
        
        //MARK: - Method
        urlRequest.httpMethod = method.rawValue

        //MARK: - Headers
        switch self {
        case .get(let useApi, _, _, let contentType):
            //Content-Type에 따른 Headers 설정
            if contentType == "json" {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            }
            else if contentType == "text" {
                urlRequest.setValue("text/plain;charset=UTF-8", forHTTPHeaderField: "Content-Type")
            }
            
            if useApi  == "address" {
                urlRequest.setValue(APIRouter.kakaoAPIKey, forHTTPHeaderField: "Authorization")
            }
        case .post( _, _, _, let contentType):
            if contentType == "json" {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            }
            else if contentType == "text" {
                urlRequest.setValue("text/plain;charset=UTF-8", forHTTPHeaderField: "Content-Type")
            }
        case .put:
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        case .patch:
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        }

        //MARK: - Parameters
        switch self {
        case .get( _, _, let parameters, _):
            urlRequest = try URLEncodedFormParameterEncoder().encode(parameters, into: urlRequest)
        case .post( _, _, let parameters, _):
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])   //JSON Parsing
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        case .put( _, _, let parameters):
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])   //JSON Parsing
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        case .patch( _, _, let parameters):
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])   //JSON Parsing
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        }
        
        return urlRequest
    }
}
