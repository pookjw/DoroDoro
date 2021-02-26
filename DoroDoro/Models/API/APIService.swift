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
                let decoder: JSONDecoder = .init()
                
                // TODO
                let decoded: _AddrLinkData = try! decoder.decode(_AddrLinkData.self, from: response.1)
                obj.addrLinkEvent.onNext(decoded.results)
            })
            .disposed(by: disposeBag)
    }
    
    public func requestAddrLink(keyword: String,
                                currentPage: Int = 1,
                                countPerPage: Int = 10,
                                completion: @escaping ((AddrLinkResultsData?, Error?) -> Void)) {
        AF.request(addrLinkApiURL,
                   method: .get,
                   parameters: ["confmKey": Keys.addrLinkApiKey,
                                "currentPage": currentPage,
                                "countPerPage": countPerPage,
                                "keyword": keyword,
                                "resultType": "json"])
            .response(queue: DispatchQueue.global(qos: .background)) { response in
                let decoder: JSONDecoder = .init()
                
                // TODO
                let decoded: _AddrLinkData = try! decoder.decode(_AddrLinkData.self, from: response.data!)
                
                completion(decoded.results, nil)
            }
    }
    
    public func requestAddrLink(keyword: String,
                                currentPage: Int = 1,
                                countPerPage: Int = 10) -> (AddrLinkResultsData?, Error?) {
        let semaphore = DispatchSemaphore(value: 0)
        var result: (AddrLinkResultsData?, Error?) = (nil, nil)

        AF.request(addrLinkApiURL,
                   method: .get,
                   parameters: ["confmKey": Keys.addrLinkApiKey,
                                "currentPage": currentPage,
                                "countPerPage": countPerPage,
                                "keyword": keyword,
                                "resultType": "json"])
            .response(queue: DispatchQueue.global(qos: .background)) { [weak semaphore] response in
                let decoder: JSONDecoder = .init()

                // TODO
                let decoded: _AddrLinkData = try! decoder.decode(_AddrLinkData.self, from: response.data!)
                result.0 = decoded.results
                
                semaphore?.signal()
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
                let decoder: JSONDecoder = .init()
                
                // TODO
                let decoded: _AddrEngData = try! decoder.decode(_AddrEngData.self, from: response.1)
                obj.addrEngEvent.onNext(decoded.results)
            })
            .disposed(by: disposeBag)
    }
    
    public func requestAddrEng(keyword: String,
                                currentPage: Int = 1,
                                countPerPage: Int = 10,
                                completion: @escaping ((AddrEngResultsData?, Error?) -> Void)) {
        AF.request(addrEngApiURL,
                   method: .get,
                   parameters: ["confmKey": Keys.addrEngApiKey,
                                "currentPage": currentPage,
                                "countPerPage": countPerPage,
                                "keyword": keyword,
                                "resultType": "json"])
            .response(queue: DispatchQueue.global(qos: .background)) { response in
                let decoder: JSONDecoder = .init()
                
                // TODO
                let decoded: _AddrEngData = try! decoder.decode(_AddrEngData.self, from: response.data!)
                
                completion(decoded.results, nil)
            }
    }
    
    public func requestAddrEng(keyword: String,
                                currentPage: Int = 1,
                                countPerPage: Int = 10) -> (AddrEngResultsData?, Error?) {
        let semaphore = DispatchSemaphore(value: 0)
        var result: (AddrEngResultsData?, Error?) = (nil, nil)

        AF.request(addrEngApiURL,
                   method: .get,
                   parameters: ["confmKey": Keys.addrEngApiKey,
                                "currentPage": currentPage,
                                "countPerPage": countPerPage,
                                "keyword": keyword,
                                "resultType": "json"])
            .response(queue: DispatchQueue.global(qos: .background)) { [weak semaphore] response in
                let decoder: JSONDecoder = .init()

                // TODO
                let decoded: _AddrEngData = try! decoder.decode(_AddrEngData.self, from: response.data!)
                result.0 = decoded.results
                
                semaphore?.signal()
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
