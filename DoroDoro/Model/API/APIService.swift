//
//  APIService.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import Foundation
import Combine
import Alamofire

final internal class APIService {
    // MARK: - Internal Properties
    static internal let shared: APIService = .init()
    internal let addrLinkEvent: PassthroughSubject<AddrLinkResultsData, Never> = .init()
    internal let addrEngEvent: PassthroughSubject<AddrEngResultsData, Never> = .init()
    internal let addrLinkErrorEvent: PassthroughSubject<AddrLinkApiError, Never> = .init()
    internal let addrEngErrorEvent: PassthroughSubject<AddrEngApiError, Never> = .init()
    internal let addrCoordEvent: PassthroughSubject<AddrCoordResultsData, Never> = .init()
    internal let addrCoordErrorEvent: PassthroughSubject<AddrCoordApiError, Never> = .init()
    
    // MARK: - Internal Methods
    
    // MARK: - 도로명주소 요청 API
    internal func requestAddrLinkEvent(keyword: String,
                                currentPage: Int = 1,
                                countPerPage: Int = 10) {
        AF.request(addrLinkApiURL,
                   method: .get,
                   parameters: ["confmKey": Keys.addrLinkApiKey,
                                "currentPage": currentPage,
                                "countPerPage": countPerPage,
                                "keyword": keyword,
                                "resultType": "json"])
            .response(queue: DispatchQueue.global(qos: .background)) { [weak self] response in
                guard response.response?.statusCode == 200 else {
                    self?.addrLinkErrorEvent.send(.responseError)
                    return
                }
                
                guard let data: Data = response.data else {
                    self?.addrLinkErrorEvent.send(.responseError)
                    return
                }
                
                let decoder: JSONDecoder = .init()
                
                guard let decoded: _AddrLinkData = try? decoder.decode(_AddrLinkData.self, from: data) else {
                    self?.addrLinkErrorEvent.send(.jsonError)
                    return
                }
                
                if let resultError: AddrLinkApiError = AddrLinkApiError(rawValue: decoded.results.common.errorCode),
                   resultError != .normal {
                    self?.addrLinkErrorEvent.send(resultError)
                    return
                }
                
                guard decoded.results.juso != nil else {
                    self?.addrLinkErrorEvent.send(.unknownError)
                    return
                }
                
                guard !decoded.results.juso.isEmpty else {
                    self?.addrLinkErrorEvent.send(.noResults)
                    return
                }
                
                self?.addrLinkEvent.send(decoded.results)
            }
    }
    
    internal func requestAddrLink(keyword: String,
                                currentPage: Int = 1,
                                countPerPage: Int = 10,
                                completion: @escaping ((AddrLinkResultsData?, AddrLinkApiError?) -> Void)) {
        AF.request(addrLinkApiURL,
                   method: .get,
                   parameters: ["confmKey": Keys.addrLinkApiKey,
                                "currentPage": currentPage,
                                "countPerPage": countPerPage,
                                "keyword": keyword,
                                "resultType": "json"])
            .response(queue: DispatchQueue.global(qos: .background)) { response in
                guard response.response?.statusCode == 200 else {
                    completion(nil, .responseError)
                    return
                }
                
                guard let data: Data = response.data else {
                    completion(nil, .responseError)
                    return
                }
                
                let decoder: JSONDecoder = .init()
                
                guard let decoded: _AddrLinkData = try? decoder.decode(_AddrLinkData.self, from: data) else {
                    completion(nil, .jsonError)
                    return
                }
                
                if let resultError: AddrLinkApiError = AddrLinkApiError(rawValue: decoded.results.common.errorCode),
                   resultError != .normal {
                    completion(nil, resultError)
                    return
                }
                
                guard decoded.results.juso != nil else {
                    completion(nil, .unknownError)
                    return
                }
                
                guard !decoded.results.juso.isEmpty else {
                    completion(nil, .noResults)
                    return
                }
                
                completion(decoded.results, nil)
            }
    }
    
    internal func requestAddrLink(keyword: String,
                                currentPage: Int = 1,
                                countPerPage: Int = 10) -> (AddrLinkResultsData?, AddrLinkApiError?) {
        let semaphore = DispatchSemaphore(value: 0)
        var result: (AddrLinkResultsData?, AddrLinkApiError?) = (nil, nil)

        AF.request(addrLinkApiURL,
                   method: .get,
                   parameters: ["confmKey": Keys.addrLinkApiKey,
                                "currentPage": currentPage,
                                "countPerPage": countPerPage,
                                "keyword": keyword,
                                "resultType": "json"])
            .response(queue: DispatchQueue.global(qos: .background)) { [weak semaphore] response in
                
                defer {
                    semaphore?.signal()
                }
                
                guard response.response?.statusCode == 200 else {
                    result = (nil, .responseError)
                    return
                }
                
                guard let data: Data = response.data else {
                    result = (nil, .responseError)
                    return
                }
                
                let decoder: JSONDecoder = .init()
                
                guard let decoded: _AddrLinkData = try? decoder.decode(_AddrLinkData.self, from: data) else {
                    result = (nil, .jsonError)
                    return
                }
                
                if let resultError: AddrLinkApiError = AddrLinkApiError(rawValue: decoded.results.common.errorCode),
                   resultError != .normal {
                    result = (nil, resultError)
                    return
                }
                
                guard decoded.results.juso != nil else {
                    result = (nil, .unknownError)
                    return
                }
                
                guard !decoded.results.juso.isEmpty else {
                    result = (nil, .noResults)
                    return
                }
                
                result = (decoded.results, nil)
            }
        
        semaphore.wait()
        
        return result
    }
    
    // MARK: - 영문주소 API
    
    internal func requestAddrEngEvent(keyword: String,
                               currentPage: Int = 1,
                               countPerPage: Int = 1) {
        AF.request(addrEngApiURL,
                   method: .get,
                   parameters: ["confmKey": Keys.addrEngApiKey,
                                "currentPage": currentPage,
                                "countPerPage": countPerPage,
                                "keyword": keyword,
                                "resultType": "json"])
            .response(queue: DispatchQueue.global(qos: .background)) { [weak self] response in
                guard response.response?.statusCode == 200 else {
                    self?.addrEngErrorEvent.send(.responseError)
                    return
                }
                
                guard let data: Data = response.data else {
                    self?.addrEngErrorEvent.send(.responseError)
                    return
                }
                
                let decoder: JSONDecoder = .init()
                
                guard let decoded: _AddrEngData = try? decoder.decode(_AddrEngData.self, from: data) else {
                    self?.addrEngErrorEvent.send(.jsonError)
                    return
                }
                
                if let resultError: AddrEngApiError = AddrEngApiError(rawValue: decoded.results.common.errorCode),
                   resultError != .normal {
                    self?.addrEngErrorEvent.send(resultError)
                    return
                }
                
                guard decoded.results.juso != nil else {
                    self?.addrEngErrorEvent.send(.unknownError)
                    return
                }
                
                guard !decoded.results.juso.isEmpty else {
                    self?.addrEngErrorEvent.send(.noResults)
                    return
                }
                
                self?.addrEngEvent.send(decoded.results)
            }
    }
    
    internal func requestAddrEng(keyword: String,
                                currentPage: Int = 1,
                                countPerPage: Int = 10,
                                completion: @escaping ((AddrEngResultsData?, AddrEngApiError?) -> Void)) {
        AF.request(addrEngApiURL,
                   method: .get,
                   parameters: ["confmKey": Keys.addrEngApiKey,
                                "currentPage": currentPage,
                                "countPerPage": countPerPage,
                                "keyword": keyword,
                                "resultType": "json"])
            .response(queue: DispatchQueue.global(qos: .background)) { response in
                guard response.response?.statusCode == 200 else {
                    completion(nil, .responseError)
                    return
                }
                
                guard let data: Data = response.data else {
                    completion(nil, .responseError)
                    return
                }
                
                let decoder: JSONDecoder = .init()
                
                guard let decoded: _AddrEngData = try? decoder.decode(_AddrEngData.self, from: data) else {
                    completion(nil, .jsonError)
                    return
                }
                
                if let resultError: AddrEngApiError = AddrEngApiError(rawValue: decoded.results.common.errorCode),
                   resultError != .normal {
                    completion(nil, resultError)
                    return
                }
                
                guard decoded.results.juso != nil else {
                    completion(nil, .unknownError)
                    return
                }
                
                guard !decoded.results.juso.isEmpty else {
                    completion(nil, .noResults)
                    return
                }
                
                completion(decoded.results, nil)
            }
    }
    
    internal func requestAddrEng(keyword: String,
                                currentPage: Int = 1,
                                countPerPage: Int = 10) -> (AddrEngResultsData?, AddrEngApiError?) {
        let semaphore = DispatchSemaphore(value: 0)
        var result: (AddrEngResultsData?, AddrEngApiError?) = (nil, nil)

        AF.request(addrEngApiURL,
                   method: .get,
                   parameters: ["confmKey": Keys.addrEngApiKey,
                                "currentPage": currentPage,
                                "countPerPage": countPerPage,
                                "keyword": keyword,
                                "resultType": "json"])
            .response(queue: DispatchQueue.global(qos: .background)) { [weak semaphore] response in
                
                defer {
                    semaphore?.signal()
                }
                
                guard response.response?.statusCode == 200 else {
                    result = (nil, AddrEngApiError.responseError)
                    return
                }
                
                guard let data: Data = response.data else {
                    result = (nil, AddrEngApiError.responseError)
                    return
                }
                
                let decoder: JSONDecoder = .init()
                
                guard let decoded: _AddrEngData = try? decoder.decode(_AddrEngData.self, from: data) else {
                    result = (nil, AddrEngApiError.jsonError)
                    return
                }
                
                if let resultError: AddrEngApiError = AddrEngApiError(rawValue: decoded.results.common.errorCode),
                   resultError != .normal {
                    result = (nil, resultError)
                    return
                }
                
                guard decoded.results.juso != nil else {
                    result = (nil, AddrEngApiError.unknownError)
                    return
                }
                
                guard !decoded.results.juso.isEmpty else {
                    result = (nil, .noResults)
                    return
                }
                
                result = (decoded.results, nil)
            }
        
        semaphore.wait()
        
        return result
    }
    
    // MARK: - 좌표제공 API
    internal func requestCoordEvent(data: AddrCoordSearchData) {
        AF.request(addrCoordApiURL,
                   method: .get,
                   parameters: ["confmKey": Keys.addrCoordApiKey,
                                "admCd": data.admCd,
                                "rnMgtSn": data.rnMgtSn,
                                "udrtYn": data.udrtYn,
                                "buldMnnm": data.buldMnnm,
                                "buldSlno": data.buldSlno,
                                "resultType": "json"])
            .response(queue: DispatchQueue.global(qos: .background)) { [weak self] response in
                guard response.response?.statusCode == 200 else {
                    self?.addrCoordErrorEvent.send(.responseError)
                    return
                }
                
                guard let data: Data = response.data else {
                    self?.addrCoordErrorEvent.send(.responseError)
                    return
                }
                
                let decoder: JSONDecoder = .init()
                
                guard let decoded: _AddrCoordData = try? decoder.decode(_AddrCoordData.self, from: data) else {
                    self?.addrCoordErrorEvent.send(.jsonError)
                    return
                }
                
                if let resultError: AddrCoordApiError = AddrCoordApiError(rawValue: decoded.results.common.errorCode),
                   resultError != .normal {
                    self?.addrCoordErrorEvent.send(resultError)
                    return
                }
                
                guard decoded.results.juso != nil else {
                    self?.addrCoordErrorEvent.send(.unknownError)
                    return
                }
                
                guard !decoded.results.juso.isEmpty else {
                    self?.addrCoordErrorEvent.send(.noResults)
                    return
                }
                
                self?.addrCoordEvent.send(decoded.results)
            }
    }
    
    internal func requestCoord(data: AddrCoordSearchData,
                                completion: @escaping ((AddrCoordResultsData?, AddrCoordApiError?) -> Void)) {
        AF.request(addrCoordApiURL,
                   method: .get,
                   parameters: ["confmKey": Keys.addrCoordApiKey,
                                "admCd": data.admCd,
                                "rnMgtSn": data.rnMgtSn,
                                "udrtYn": data.udrtYn,
                                "buldMnnm": data.buldMnnm,
                                "buldSlno": data.buldSlno,
                                "resultType": "json"])
            .response(queue: DispatchQueue.global(qos: .background)) { response in
                guard response.response?.statusCode == 200 else {
                    completion(nil, .responseError)
                    return
                }
                
                guard let data: Data = response.data else {
                    completion(nil, .responseError)
                    return
                }
                
                let decoder: JSONDecoder = .init()
                
                guard let decoded: _AddrCoordData = try? decoder.decode(_AddrCoordData.self, from: data) else {
                    completion(nil, .jsonError)
                    return
                }
                
                if let resultError: AddrCoordApiError = AddrCoordApiError(rawValue: decoded.results.common.errorCode),
                   resultError != .normal {
                    completion(nil, resultError)
                    return
                }
                
                guard decoded.results.juso != nil else {
                    completion(nil, .unknownError)
                    return
                }
                
                guard !decoded.results.juso.isEmpty else {
                    completion(nil, .noResults)
                    return
                }
                
                completion(decoded.results, nil)
            }
    }
    
    internal func requestCoord(data: AddrCoordSearchData) -> (AddrCoordResultsData?, AddrCoordApiError?) {
        let semaphore = DispatchSemaphore(value: 0)
        var result: (AddrCoordResultsData?, AddrCoordApiError?) = (nil, nil)

        AF.request(addrCoordApiURL,
                   method: .get,
                   parameters: ["confmKey": Keys.addrCoordApiKey,
                                "admCd": data.admCd,
                                "rnMgtSn": data.rnMgtSn,
                                "udrtYn": data.udrtYn,
                                "buldMnnm": data.buldMnnm,
                                "buldSlno": data.buldSlno,
                                "resultType": "json"])
            .response(queue: DispatchQueue.global(qos: .background)) { [weak semaphore] response in
                
                defer {
                    semaphore?.signal()
                }
                
                guard response.response?.statusCode == 200 else {
                    result = (nil, .responseError)
                    return
                }
                
                guard let data: Data = response.data else {
                    result = (nil, .responseError)
                    return
                }
                
                let decoder: JSONDecoder = .init()
                
                guard let decoded: _AddrCoordData = try? decoder.decode(_AddrCoordData.self, from: data) else {
                    result = (nil, .jsonError)
                    return
                }
                
                if let resultError: AddrCoordApiError = AddrCoordApiError(rawValue: decoded.results.common.errorCode),
                   resultError != .normal {
                    result = (nil, resultError)
                    return
                }
                
                guard decoded.results.juso != nil else {
                    result = (nil, .unknownError)
                    return
                }
                
                guard !decoded.results.juso.isEmpty else {
                    result = (nil, .noResults)
                    return
                }
                
                result = (decoded.results, nil)
            }
        
        semaphore.wait()
        
        return result
    }
    
    // MARK: - Private Properties
    private let addrLinkApiURL: URL = URL(string: "https://www.juso.go.kr/addrlink/addrLinkApi.do")!
    private let addrEngApiURL: URL = URL(string: "https://www.juso.go.kr/addrlink/addrEngApi.do")!
    private let addrCoordApiURL: URL = URL(string: "https://www.juso.go.kr/addrlink/addrCoordApi.do")!
    
    // MARK: - Private Methods
    private init() {}
}

fileprivate struct _AddrLinkData: Decodable {
    fileprivate let results: AddrLinkResultsData
}

fileprivate struct _AddrEngData: Decodable {
    fileprivate let results: AddrEngResultsData
}

fileprivate struct _AddrCoordData: Decodable {
    fileprivate let results: AddrCoordResultsData
}
