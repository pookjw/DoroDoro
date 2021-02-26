//
//  APIService.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import Foundation
import RxSwift
import RxAlamofire
import Alamofire

final class APIService {
    // MARK: - Public Properties
    static public let shared: APIService = .init()
    public let addrLinkEvent: PublishSubject<AddrLinkResultsData> = .init()
    public let addrEngEvent: PublishSubject<AddrEngResultsData> = .init()
    public let addrLinkErrorEvent: PublishSubject<AddrLinkApiError> = .init()
    public let addrEngErrorEvent: PublishSubject<AddrEngApiError> = .init()
    
    // MARK: - Public Methods
    
    // 도로명주소 요청 API
    public func requestAddrLinkEvent(keyword: String,
                                currentPage: Int = 1,
                                countPerPage: Int = 10) {
        // 도로명주소 요청
        RxAlamofire.requestData(.get,
                                addrLinkApiURL,
                                parameters: ["confmKey": Keys.addrLinkApiKey,
                                             "currentPage": currentPage,
                                             "countPerPage": countPerPage,
                                             "keyword": keyword,
                                             "resultType": "json"])
            .withUnretained(self)
            .subscribe(onNext: { (obj, response) in
                guard response.0.statusCode == 200 else {
                    obj.addrLinkErrorEvent.onNext(.responseError)
                    return
                }
                
                let decoder: JSONDecoder = .init()
                
                guard let decoded: _AddrLinkData = try? decoder.decode(_AddrLinkData.self, from: response.1) else {
                    obj.addrLinkErrorEvent.onNext(.jsonError)
                    return
                }
                
                if let resultError: AddrLinkApiError = AddrLinkApiError(rawValue: decoded.results.common.errorCode),
                   resultError != .normal {
                    obj.addrLinkErrorEvent.onNext(resultError)
                    return
                }
                
                guard decoded.results.juso != nil else {
                    obj.addrLinkErrorEvent.onNext(.unknownError)
                    return
                }
                
                guard !decoded.results.juso.isEmpty else {
                    obj.addrLinkErrorEvent.onNext(.noResults)
                    return
                }
                
                obj.addrLinkEvent.onNext(decoded.results)
            })
            .disposed(by: disposeBag)
    }
    
    public func requestAddrLink(keyword: String,
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
    
    public func requestAddrLink(keyword: String,
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
    
    // 영문주소 API
    
    public func requestAddrEngEvent(keyword: String,
                               currentPage: Int = 1,
                               countPerPage: Int = 1) {
        RxAlamofire.requestData(.get,
                                addrEngApiURL,
                                parameters: ["confmKey": Keys.addrEngApiKey,
                                             "currentPage": currentPage,
                                             "countPerPage": countPerPage,
                                             "keyword": keyword,
                                             "resultType": "json"])
            .withUnretained(self)
            .subscribe(onNext: { (obj, response) in
                guard response.0.statusCode == 200 else {
                    obj.addrEngErrorEvent.onNext(.responseError)
                    return
                }
                
                let decoder: JSONDecoder = .init()
                
                guard let decoded: _AddrEngData = try? decoder.decode(_AddrEngData.self, from: response.1) else {
                    obj.addrEngErrorEvent.onNext(.jsonError)
                    return
                }
                
                if let resultError: AddrEngApiError = AddrEngApiError(rawValue: decoded.results.common.errorCode),
                   resultError != .normal {
                    obj.addrEngErrorEvent.onNext(resultError)
                    return
                }
                
                guard decoded.results.juso != nil else {
                    obj.addrEngErrorEvent.onNext(.unknownError)
                    return
                }
                
                guard !decoded.results.juso.isEmpty else {
                    obj.addrEngErrorEvent.onNext(.noResults)
                    return
                }
                
                obj.addrEngEvent.onNext(decoded.results)
            })
            .disposed(by: disposeBag)
    }
    
    public func requestAddrEng(keyword: String,
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
    
    public func requestAddrEng(keyword: String,
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
    
    // MARK: - Private Properties
    private let addrLinkApiURL: URL = URL(string: "https://www.juso.go.kr/addrlink/addrLinkApi.do")!
    private let addrEngApiURL: URL = URL(string: "https://www.juso.go.kr/addrlink/addrEngApi.do")!
    private var disposeBag: DisposeBag = .init()
    
    // MARK: - Private Methods
    private init() {
        bind()
    }
    
    private func bind() {
//        Observable
//            .zip(addrLinkEvent, addrEngEvent)
//            .withUnretained(self)
//            .subscribe(onNext: { (obj, result) in
//                obj.requestEvent.onNext(result.0 + result.1)
//            })
//            .disposed(by: disposeBag)
    }
}

fileprivate struct _AddrLinkData: Decodable {
    fileprivate let results: AddrLinkResultsData
}

fileprivate struct _AddrEngData: Decodable {
    fileprivate let results: AddrEngResultsData
}
