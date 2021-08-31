//
//  APIClient.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/02.
//

import Foundation
import Alamofire
import PromisedFuture

/// Alomfire를 통한 API 연동
class APIClient {
    //let semaphore = DispatchSemaphore(value: 0)
    //semaphore.signal()
    //semaphore.wait()
    
    //MARK: - API Request 연동 (Type: JSON)
    /// JSON Response API Request 연동 - Alamofire
    /// - Parameters:
    ///   - route: URL Request
    ///   - decoder: JSON Decoder
    /// - Returns: Future<T, AFError>
    @discardableResult
    public func request<T: Decodable>(route: APIRouter, decoder: JSONDecoder = JSONDecoder()) -> Future<T, AFError> {
        
        return Future { (completion) in
            let request = AF.request(route)

            request.responseDecodable(
                decoder: decoder,
                completionHandler: { (response: DataResponse<T, AFError>) in
                    switch response.result {
                    //API 연동 성공
                    case .success(let value):
                        completion(.success(value))
                    //API 연동 실패
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            )
        }
    }
    
    //MARK: - API Request 연동 (Type: Text)
    /// Text Response API Request 연동 - Alamofire
    /// - Parameters:
    ///   - route: URL Request
    /// - Returns: Future<String, AFError>
    @discardableResult
    public func requestText(route: APIRouter) -> Future<String, AFError> {
        
        return Future { (completion) in
            let request = AF.request(route)

            request.responseString(
                completionHandler: { (response: DataResponse<String, AFError>) in
                    switch response.result {
                    //API 연동 성공
                    case .success(let value):
                        completion(.success(value))
                    //API 연동 실패
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            )
        }
    }

//    public func request2<T: Decodable>(route: APIRouter, decoder: JSONDecoder = JSONDecoder()) -> Future<T, AFError> {
//
//        let future = Future<T, AFError> { (completion) in
//            let request = AF.request(route)
//
//            request.responseDecodable(decoder: decoder, completionHandler: { (response: DataResponse<T, AFError>) in
//                switch response.result {
//                //API 연동 성공
//                case .success(let value):
//                    completion(.success(value))
//                //API 연동 실패
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//            })
//        }
//
//        return future
//    }
}
