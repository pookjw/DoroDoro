//
//  KakaoAPIService.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation
import Combine
import Alamofire

public final class KakaoAPIService {
    // MARK: - Public Properties
    public static let shared: KakaoAPIService = .init()
    public let addressEvent: PassthroughSubject<KakaoAddressResultData, Never> = .init()
    public let coord2AddressEvent: PassthroughSubject<KakaoCoord2AddressResultData, Never> = .init()
    public let addressErrorEvent: PassthroughSubject<KakaoAddressAPIError, Never> = .init()
    public let coord2AddressErrorEvent: PassthroughSubject<KakaoCoord2AddressAPIError, Never> = .init()
    
    public enum AddressAnalyzeType: String {
        case similar, exact
    }
    
    public enum Coord2AddressInputCoord: String {
        case WGS84, WCONGNAMUL, CONGNAMUL, WTM, TM
    }
    
    // MARK: - public Methods
    public init() {}
    
    // MARK: - 주소 검색 API
    public func requestAddressEvent(query: String,
                                    analyze_type: AddressAnalyzeType = .similar,
                                    page: Int = 1,
                                    size: Int = 10) {
        
        guard let addressAPIURL: URL = addressAPIURL else {
            addressErrorEvent.send(.unknownError)
            return
        }
        
        AF.request(addressAPIURL,
                   method: .get,
                   parameters: ["query": query,
                                "analyze_type": analyze_type,
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
    
    public func requestCoord2AddressEvent(x: String,
                                          y: String,
                                          input_coord: Coord2AddressInputCoord = .WGS84) {
        guard let coord2AddressAPIURL: URL = coord2AddressAPIURL else {
            coord2AddressErrorEvent.send(.unknownError)
            return
        }
        
        AF.request(coord2AddressAPIURL,
                   method: .get,
                   parameters: ["x": x,
                                "y": y,
                                "input_coord": input_coord.rawValue],
                   headers:  ["Authorization": "KakaoAK \(KakaoAPIKeys.restAPIKey)"])
            .response(queue: DispatchQueue.global(qos: .background)) { [weak self] response in
                guard response.response?.statusCode == 200 else {
                    self?.coord2AddressErrorEvent.send(.responseError)
                    return
                }
                
                guard let data: Data = response.data else {
                    self?.coord2AddressErrorEvent.send(.responseError)
                    return
                }
                
                let decoder: JSONDecoder = .init()
                
                guard let decoded: KakaoCoord2AddressResultData = try? decoder.decode(KakaoCoord2AddressResultData.self, from: data) else {
                    self?.coord2AddressErrorEvent.send(.jsonError)
                    return
                }
                
                guard !decoded.documents.isEmpty else {
                    self?.coord2AddressErrorEvent.send(.noResults)
                    return
                }
                
                self?.coord2AddressEvent.send(decoded)
            }
    }
    
    // MARK: - Private Properties
    private let addressAPIURL: URL? = URL(string: "https://dapi.kakao.com/v2/local/search/address.json")
    private let coord2AddressAPIURL: URL? = URL(string: "https://dapi.kakao.com/v2/local/geo/coord2address.json")
}
