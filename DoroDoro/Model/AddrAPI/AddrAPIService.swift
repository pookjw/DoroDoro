//
//  AddrAPIService.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import Foundation
import Combine
import Alamofire

final internal class AddrAPIService {
    // MARK: - Internal Properties
    static internal let shared: AddrAPIService = .init()
    internal let linkEvent: PassthroughSubject<AddrLinkResultsData, Never> = .init()
    internal let engEvent: PassthroughSubject<AddrEngResultsData, Never> = .init()
    internal let coordEvent: PassthroughSubject<AddrCoordResultsData, Never> = .init()
    internal let linkErrorEvent: PassthroughSubject<AddrLinkAPIError, Never> = .init()
    internal let engErrorEvent: PassthroughSubject<AddrEngAPIError, Never> = .init()
    internal let coordErrorEvent: PassthroughSubject<AddrCoordAPIError, Never> = .init()
    
    // MARK: - Internal Methods
    
    // MARK: - 도로명주소 요청 API
    internal func requestLinkEvent(keyword: String,
                                currentPage: Int = 1,
                                countPerPage: Int = 10) {
        
        guard let linkAPIURL: URL = linkAPIURL else {
            linkErrorEvent.send(.unknownError)
            return
        }
        
        AF.request(linkAPIURL,
                   method: .get,
                   parameters: ["confmKey": AddrAPIKeys.linkAPIKey,
                                "currentPage": currentPage,
                                "countPerPage": countPerPage,
                                "keyword": keyword,
                                "resultType": "json"])
            .response(queue: DispatchQueue.global(qos: .background)) { [weak self] response in
                guard response.response?.statusCode == 200 else {
                    self?.linkErrorEvent.send(.responseError)
                    return
                }
                
                guard let data: Data = response.data else {
                    self?.linkErrorEvent.send(.responseError)
                    return
                }
                
                let decoder: JSONDecoder = .init()
                
                guard let decoded: _AddrLinkData = try? decoder.decode(_AddrLinkData.self, from: data) else {
                    self?.linkErrorEvent.send(.jsonError)
                    return
                }
                
                if let resultError: AddrLinkAPIError = AddrLinkAPIError(rawValue: decoded.results.common.errorCode),
                   resultError != .normal {
                    self?.linkErrorEvent.send(resultError)
                    return
                }
                
                guard decoded.results.juso != nil else {
                    self?.linkErrorEvent.send(.unknownError)
                    return
                }
                
                guard !decoded.results.juso.isEmpty else {
                    self?.linkErrorEvent.send(.noResults)
                    return
                }
                
                self?.linkEvent.send(decoded.results)
            }
    }
    
    internal func requestLink(keyword: String,
                                currentPage: Int = 1,
                                countPerPage: Int = 10,
                                completion: @escaping ((AddrLinkResultsData?, AddrLinkAPIError?) -> Void)) {
        
        guard let linkAPIURL: URL = linkAPIURL else {
            completion(nil, .unknownError)
            return
        }
        
        AF.request(linkAPIURL,
                   method: .get,
                   parameters: ["confmKey": AddrAPIKeys.linkAPIKey,
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
                
                if let resultError: AddrLinkAPIError = AddrLinkAPIError(rawValue: decoded.results.common.errorCode),
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
    
    internal func requestLink(keyword: String,
                                currentPage: Int = 1,
                                countPerPage: Int = 10) -> (AddrLinkResultsData?, AddrLinkAPIError?) {
        
        guard let linkAPIURL: URL = linkAPIURL else {
            return (nil, .unknownError)
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: (AddrLinkResultsData?, AddrLinkAPIError?) = (nil, nil)

        AF.request(linkAPIURL,
                   method: .get,
                   parameters: ["confmKey": AddrAPIKeys.linkAPIKey,
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
                
                if let resultError: AddrLinkAPIError = AddrLinkAPIError(rawValue: decoded.results.common.errorCode),
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
    
    internal func requestEngEvent(keyword: String,
                               currentPage: Int = 1,
                               countPerPage: Int = 1) {
        
        guard let engAPIURL: URL = engAPIURL else {
            engErrorEvent.send(.unknownError)
            return
        }
        
        AF.request(engAPIURL,
                   method: .get,
                   parameters: ["confmKey": AddrAPIKeys.engAPIKey,
                                "currentPage": currentPage,
                                "countPerPage": countPerPage,
                                "keyword": keyword,
                                "resultType": "json"])
            .response(queue: DispatchQueue.global(qos: .background)) { [weak self] response in
                guard response.response?.statusCode == 200 else {
                    self?.engErrorEvent.send(.responseError)
                    return
                }
                
                guard let data: Data = response.data else {
                    self?.engErrorEvent.send(.responseError)
                    return
                }
                
                let decoder: JSONDecoder = .init()
                
                guard let decoded: _AddrEngData = try? decoder.decode(_AddrEngData.self, from: data) else {
                    self?.engErrorEvent.send(.jsonError)
                    return
                }
                
                if let resultError: AddrEngAPIError = AddrEngAPIError(rawValue: decoded.results.common.errorCode),
                   resultError != .normal {
                    self?.engErrorEvent.send(resultError)
                    return
                }
                
                guard decoded.results.juso != nil else {
                    self?.engErrorEvent.send(.unknownError)
                    return
                }
                
                guard !decoded.results.juso.isEmpty else {
                    self?.engErrorEvent.send(.noResults)
                    return
                }
                
                self?.engEvent.send(decoded.results)
            }
    }
    
    internal func requestEng(keyword: String,
                                currentPage: Int = 1,
                                countPerPage: Int = 10,
                                completion: @escaping ((AddrEngResultsData?, AddrEngAPIError?) -> Void)) {
        
        guard let engAPIURL: URL = engAPIURL else {
            completion(nil, .unknownError)
            return
        }
        
        AF.request(engAPIURL,
                   method: .get,
                   parameters: ["confmKey": AddrAPIKeys.engAPIKey,
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
                
                if let resultError: AddrEngAPIError = AddrEngAPIError(rawValue: decoded.results.common.errorCode),
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
    
    internal func requestEng(keyword: String,
                                currentPage: Int = 1,
                                countPerPage: Int = 10) -> (AddrEngResultsData?, AddrEngAPIError?) {
        
        guard let engAPIURL: URL = engAPIURL else {
            return (nil, .unknownError)
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: (AddrEngResultsData?, AddrEngAPIError?) = (nil, nil)

        AF.request(engAPIURL,
                   method: .get,
                   parameters: ["confmKey": AddrAPIKeys.engAPIKey,
                                "currentPage": currentPage,
                                "countPerPage": countPerPage,
                                "keyword": keyword,
                                "resultType": "json"])
            .response(queue: DispatchQueue.global(qos: .background)) { [weak semaphore] response in
                
                defer {
                    semaphore?.signal()
                }
                
                guard response.response?.statusCode == 200 else {
                    result = (nil, AddrEngAPIError.responseError)
                    return
                }
                
                guard let data: Data = response.data else {
                    result = (nil, AddrEngAPIError.responseError)
                    return
                }
                
                let decoder: JSONDecoder = .init()
                
                guard let decoded: _AddrEngData = try? decoder.decode(_AddrEngData.self, from: data) else {
                    result = (nil, AddrEngAPIError.jsonError)
                    return
                }
                
                if let resultError: AddrEngAPIError = AddrEngAPIError(rawValue: decoded.results.common.errorCode),
                   resultError != .normal {
                    result = (nil, resultError)
                    return
                }
                
                guard decoded.results.juso != nil else {
                    result = (nil, AddrEngAPIError.unknownError)
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
        
        guard let coordAPIURL: URL = coordAPIURL else {
            coordErrorEvent.send(.unknownError)
            return
        }
        
        AF.request(coordAPIURL,
                   method: .get,
                   parameters: ["confmKey": AddrAPIKeys.coordAPIKey,
                                "admCd": data.admCd,
                                "rnMgtSn": data.rnMgtSn,
                                "udrtYn": data.udrtYn,
                                "buldMnnm": data.buldMnnm,
                                "buldSlno": data.buldSlno,
                                "resultType": "json"])
            .response(queue: DispatchQueue.global(qos: .background)) { [weak self] response in
                guard response.response?.statusCode == 200 else {
                    self?.coordErrorEvent.send(.responseError)
                    return
                }
                
                guard let data: Data = response.data else {
                    self?.coordErrorEvent.send(.responseError)
                    return
                }
                
                let decoder: JSONDecoder = .init()
                
                guard let decoded: _AddrCoordData = try? decoder.decode(_AddrCoordData.self, from: data) else {
                    self?.coordErrorEvent.send(.jsonError)
                    return
                }
                
                if let resultError: AddrCoordAPIError = AddrCoordAPIError(rawValue: decoded.results.common.errorCode),
                   resultError != .normal {
                    self?.coordErrorEvent.send(resultError)
                    return
                }
                
                guard decoded.results.juso != nil else {
                    self?.coordErrorEvent.send(.unknownError)
                    return
                }
                
                guard !decoded.results.juso.isEmpty else {
                    self?.coordErrorEvent.send(.noResults)
                    return
                }
                
                self?.coordEvent.send(decoded.results)
            }
    }
    
    internal func requestCoord(data: AddrCoordSearchData,
                                completion: @escaping ((AddrCoordResultsData?, AddrCoordAPIError?) -> Void)) {
        
        guard let coordAPIURL: URL = coordAPIURL else {
            completion(nil, .unknownError)
            return
        }
        
        AF.request(coordAPIURL,
                   method: .get,
                   parameters: ["confmKey": AddrAPIKeys.coordAPIKey,
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
                
                if let resultError: AddrCoordAPIError = AddrCoordAPIError(rawValue: decoded.results.common.errorCode),
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
    
    internal func requestCoord(data: AddrCoordSearchData) -> (AddrCoordResultsData?, AddrCoordAPIError?) {
        
        guard let coordAPIURL: URL = coordAPIURL else {
            return (nil, .unknownError)
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: (AddrCoordResultsData?, AddrCoordAPIError?) = (nil, nil)

        AF.request(coordAPIURL,
                   method: .get,
                   parameters: ["confmKey": AddrAPIKeys.coordAPIKey,
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
                
                if let resultError: AddrCoordAPIError = AddrCoordAPIError(rawValue: decoded.results.common.errorCode),
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
    private let linkAPIURL: URL? = URL(string: "https://www.juso.go.kr/addrlink/addrLinkApi.do")
    private let engAPIURL: URL? = URL(string: "https://www.juso.go.kr/addrlink/addrEngApi.do")
    private let coordAPIURL: URL? = URL(string: "https://www.juso.go.kr/addrlink/addrCoordApi.do")
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
