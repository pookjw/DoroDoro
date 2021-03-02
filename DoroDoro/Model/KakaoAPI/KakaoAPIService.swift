//
//  KakaoAPIService.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation
import Combine
import Alamofire

final internal class KakaoAPIService {
    // MARK: - Internal Properties
    static internal let shared: KakaoAPIService = .init()
    internal let addressEvent: PassthroughSubject<KakaoAddressResultData, Never> = .init()
    internal let addressErrorEvent: PassthroughSubject<KakaoAddressAPIError, Never> = .init()
    
    internal enum AddressAnalyzeType: String {
        case similar, exact
    }
    
    // MARK: - Internal Methods
    
    // MARK: - 주소 검색 API
    internal func requestAddressEvent(query: String,
                                      analyzeType: AddressAnalyzeType = .similar,
                                      page: Int = 1,
                                      size: Int = 10) {
        
        guard let addressAPIURL: URL = addressAPIURL else {
            addressErrorEvent.send(.unknownError)
            return
        }
        
        AF.request(addressAPIURL,
                   method: .get,
                   parameters: ["query": query,
                                "analyze_type": analyzeType,
                                "page": String(page),
                                "size": size],
                   headers: ["Authorization": "KakaoAK \(KakaoAPIKeys.restAPIKey)"])
            .response(queue: DispatchQueue.global(qos: .background)) { [weak self] response in
                guard response.response?.statusCode == 200 else {
                    self?.addressErrorEvent.send(.responseError)
                    return
                }
                
                guard let data: Data = response.data else {
                    self?.addressErrorEvent.send(.responseError)
                    return
                }
                
                let decoder: JSONDecoder = .init()
                
                guard let decoded: KakaoAddressResultData = try? decoder.decode(KakaoAddressResultData.self, from: data) else {
                    self?.addressErrorEvent.send(.jsonError)
                    return
                }
                
                guard !decoded.documents.isEmpty else {
                    self?.addressErrorEvent.send(.noResults)
                    return
                }
                
                self?.addressEvent.send(decoded)
            }
    }
    
    // MARK: - Private Properties
    private let addressAPIURL: URL? = URL(string: "https://dapi.kakao.com/v2/local/search/address.json")
}
