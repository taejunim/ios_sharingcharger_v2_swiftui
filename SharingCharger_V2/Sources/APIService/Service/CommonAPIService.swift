//
//  CommonAPIService.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/10/08.
//

import Alamofire
import PromisedFuture

// MARK: - [공통 사용 API]
class CommonAPIService {
    let apiClient = APIClient() //API Client - 공통 API 호출
    
    //MARK: - 주소 검색 API 호출
    /// 키워드(장소, 주소, 전화번호)로 장소 검색 API
    /// - Parameter parameters:
    ///   - query: 검색 질의어
    ///   - x: 중심 좌표의 X값 혹은 longitude
    ///   - y:  중심 좌표의 Y값 혹은 latitude
    ///   - radius: 중심 좌표부터의 반경거리. 특정 지역을 중심으로 검색 - 0m~20000m
    ///   - page: 결과 페이지 번호 - 1~45 (기본값: 1)
    ///   - size: 한 페이지에 보여질 문서의 개수 - 1~15 (기본값: 15)
    ///   - sort: 결과 정렬 순서 - distance 또는 accuracy (기본값: accuracy)
    /// - Returns: Address Info Model
    public func requestAddressSearch(parameters: [String:String]) -> Future<AddressInfo, AFError> {
        
        return apiClient.request(route: APIRouter.get(useApi: "address", path: "/search/keyword.json", parameters: parameters, contentType: "json"))
    }
}
