//
//  KakaoAPITests.swift
//  DoroDoroTests
//
//  Created by Jinwoo Kim on 3/1/21.
//

import XCTest
import Combine
@testable import DoroDoroAPI
@testable import DoroDoro

internal final class KakaoAPITests: XCTestCase {
    internal override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    // MARK: - 주고 검색 API 요청 테스트
    
    internal func testRequestAddressEvent() {
        var cancellableBag: Set<AnyCancellable> = .init()
        let expectation: XCTestExpectation = .init(description: "Requesting... (\(#function))")
        
        KakaoAPIService.shared.addressEvent
            .sink(receiveValue: { result in
                expectation.fulfill()
            })
            .store(in: &cancellableBag)
        
        KakaoAPIService.shared.addressErrorEvent
            .sink(receiveValue: { error in
                XCTFail(error.localizedDescription)
            })
            .store(in: &cancellableBag)
        
        KakaoAPIService.shared.requestAddressEvent(query: "전북 삼성동 100")
        
        wait(for: [expectation], timeout: 10)
    }
    
    internal func testRequestCoord2AddressEvent() {
        var cancellableBag: Set<AnyCancellable> = .init()
        let expectation: XCTestExpectation = .init(description: "Requesting... (\(#function))")
        
        KakaoAPIService.shared.coord2AddressEvent
            .sink(receiveValue: { result in
                expectation.fulfill()
            })
            .store(in: &cancellableBag)
        
        KakaoAPIService.shared.coord2AddressErrorEvent
            .sink(receiveValue: { error in
                XCTFail(error.localizedDescription)
            })
            .store(in: &cancellableBag)
        
        KakaoAPIService.shared.requestCoord2AddressEvent(x: "126.974974825074", y: "37.5765916191985")
        
        wait(for: [expectation], timeout: 10)
    }
}
