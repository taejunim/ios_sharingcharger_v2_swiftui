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
    case post(useApi: String, path: String, parameters: [String:Any])  //POST
    case get(useApi: String, path: String, parameters: [String:String], contentType: String)    //GET

    //MARK: - Base URL
    static let baseUrl: String = "http://211.253.37.97:52340/api/v1"   //전기차 공유 충전기 API URL
    
    //MARK: - HTTP Method
    private var method: HTTPMethod {
        switch self {
        case .post:
            return .post
        case .get:
            return .get
        }
    }
    
    //MARK: - Path
    private var path: String {
        switch self {
        case .post(_, let path, _):
            return path
        case .get(_, let path, _, _):
            return path
        }
    }
    
    //MARK: - Parameters
    private var parameters: Parameters? {
        switch self {
        case .post(_, _, let parameters):
            return parameters
        case .get(_, _, let parameters, _):
            return parameters
        }
    }
        
    // MARK: - URL 요청 변환
    /// 요청 URL 변환
    /// - Throws: URLRequest
    /// - Returns: URLRequest
    func asURLRequest() throws -> URLRequest {
        //MARK: - URL
        let url = try APIRouter.baseUrl.asURL()   //API URL
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))  //Base URL + Path
        
        //MARK: - Method
        urlRequest.httpMethod = method.rawValue

        //MARK: - Headers
        switch self {
        case .post:
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        case .get(_, _, _, let contentType):
            //Content-Type에 따른 Headers 설정
            if contentType == "json" {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            }
            else if contentType == "text" {
                urlRequest.setValue("text/plain;charset=UTF-8", forHTTPHeaderField: "Content-Type")
            }
        }

        //MARK: - Parameters
        switch self {
        case .post(_, _, let parameters):
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])   //JSON Parsing
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        case .get(_, _, let parameters, _):
            urlRequest = try URLEncodedFormParameterEncoder().encode(parameters, into: urlRequest)
        }
        
        return urlRequest
    }
}