//
//  APIService.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import Foundation
import RxSwift
import RxAlamofire

final class APIService {
    // MARK: - Public Properties
    static public let shared: APIService = .init()
    public let addrLinkEvent: PublishSubject<AddrLinkResultsData> = .init()
    public let addrEngEvent: PublishSubject<AddrEngResultsData> = .init()
    
    // MARK: - Public Methods
    public func requestAddrLink(keyword: String,
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
                let decoded: _AddrLinkData = try! decoder.decode(_AddrLinkData.self, from: response.1)
                obj.addrLinkEvent.onNext(decoded.results)
            })
            .disposed(by: disposeBag)
    }
    
    public func requestAddrEng(keyword: String,
                               currentPage: Int = 1,
                               countPerPage: Int = 1) {
        RxAlamofire.requestData(.get,
                                addrEngApi,
                                parameters: ["confmKey": Keys.addrEngApiKey,
                                             "currentPage": currentPage,
                                             "countPerPage": countPerPage,
                                             "keyword": keyword,
                                             "resultType": "json"])
            .withUnretained(self)
            .subscribe(onNext: { (obj, response) in
                let decoder: JSONDecoder = .init()
                let decoded: _AddrEngData = try! decoder.decode(_AddrEngData.self, from: response.1)
                obj.addrEngEvent.onNext(decoded.results)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Properties
    private let addrLinkApiURL: URL = URL(string: "https://www.juso.go.kr/addrlink/addrLinkApi.do")!
    private let addrEngApi: URL = URL(string: "https://www.juso.go.kr/addrlink/addrEngApi.do")!
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
