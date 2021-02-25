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
    public let requestEvent: PublishSubject<String> = .init()
    
    // MARK: - Public Methods
    public func request(keyword: String, page: Int = 1) {
        // 도로명주소 요청
        RxAlamofire.requestData(.get,
                                addrLinkApiURL,
                                parameters: ["confmKey": AddrLinkApiKey,
                                             "currentPage": page,
                                             "countPerPage": 10,
                                             "keyword": keyword,
                                             "resultType": "json"])
            .map { String(data: $0.1, encoding: .utf8) ?? "" }
            .withUnretained(self)
            .subscribe(onNext: { (obj, result) in
                obj.addrLinkEvent.onNext(result)
            })
            .disposed(by: disposeBag)
        
        RxAlamofire.requestData(.get,
                                addrEngApi,
                                parameters: ["confmKey": AddrEngApiKey,
                                             "currentPage": page,
                                             "countPerPage": 10,
                                             "keyword": keyword,
                                             "resultType": "json"])
            .map { String(data: $0.1, encoding: .utf8) ?? "" }
            .withUnretained(self)
            .subscribe(onNext: { (obj, result) in
                obj.addrEngEvent.onNext(result)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Properties
    private let addrLinkApiURL: URL = URL(string: "https://www.juso.go.kr/addrlink/addrLinkApi.do")!
    private let addrEngApi: URL = URL(string: "https://www.juso.go.kr/addrlink/addrEngApi.do")!
    private let addrLinkEvent: PublishSubject<String> = .init()
    private let addrEngEvent: PublishSubject<String> = .init()
    private var disposeBag: DisposeBag = .init()
    
    // MARK: - Private Methods
    private init() {
        bind()
    }
    
    private func bind() {
        Observable
            .zip(addrLinkEvent, addrEngEvent)
            .withUnretained(self)
            .subscribe(onNext: { (obj, result) in
                obj.requestEvent.onNext(result.0 + result.1)
            })
            .disposed(by: disposeBag)
    }
}
