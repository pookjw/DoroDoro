//
//  AddrAPIErrorTests.swift
//  DoroDoroTests
//
//  Created by Jinwoo Kim on 2/26/21.
//

import XCTest
import Combine
@testable import DoroDoroAPI
@testable import DoroDoro

final internal class AddrAPIErrorTests: XCTestCase {
    override internal func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    // MARK: - 도로명주소 API 요청 오류 테스트
    
    internal func testRequestAddrLinkEvent() {
        var cancellableBag: Set<AnyCancellable> = .init()
        let expactation: XCTestExpectation = .init(description: "Requesting... (\(#function))")
        
        AddrAPIService.shared.linkEvent
            .sink(receiveValue: { result in
                XCTFail()
            })
            .store(in: &cancellableBag)
        
        AddrAPIService.shared.linkErrorEvent
            .sink(receiveValue: { error in
                XCTAssertEqual(error, .noResults)
                expactation.fulfill()
            })
            .store(in: &cancellableBag)
        
        AddrAPIService.shared.requestLinkEvent(keyword: "썽쑤똥")
        
        wait(for: [expactation], timeout: 10)
    }
    
    internal func testRequestAddrLink() {
        let expactation: XCTestExpectation = .init(description: "Requesting... (\(#function))")
        
        AddrAPIService.shared.requestLink(keyword: "123") { (result, error) in
            XCTAssertNil(result)
            XCTAssertEqual(error, .wrongKeyword)
            expactation.fulfill()
        }
        
        wait(for: [expactation], timeout: 10)
    }
    
    internal func testRequestAddrLinkSync() {
        let (result, error): (AddrLinkResultsData?, AddrLinkAPIError?) = AddrAPIService.shared.requestLink(keyword: "아")
        
        XCTAssertNil(result)
        XCTAssertEqual(error, .tooShortKeyword)
    }
    
    // MARK: - 영문주소 API 요청 오류 테스트
    
    internal func testRequestAddrEngEvent() {
        var cancellableBag: Set<AnyCancellable> = .init()
        let expectation: XCTestExpectation = .init(description: "Requesting... (\(#function))")
        
        AddrAPIService.shared.engEvent
            .sink(receiveValue: { result in
                XCTFail()
            })
            .store(in: &cancellableBag)
        
        AddrAPIService.shared.engErrorEvent
            .sink(receiveValue: { error in
                XCTAssertEqual(error, .tooLongIntegerKeyword)
                expectation.fulfill()
            })
            .store(in: &cancellableBag)
        
        AddrAPIService.shared.requestEngEvent(keyword: "성수동1278720170270")
        
        wait(for: [expectation], timeout: 10)
    }
    
    internal func testRequestAddrEng() {
        let expectation: XCTestExpectation = .init(description: "Requesting... (\(#function))")
        
        AddrAPIService.shared.requestEng(keyword: "") { (result, error) in
            XCTAssertNil(result)
            XCTAssertEqual(error, .emptyKeyword)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    internal func testRequestAddrEngSync() {
        let (result, error): (AddrEngResultsData?, AddrEngAPIError?) = AddrAPIService.shared.requestEng(keyword: "성수동%")
        
        XCTAssertNil(result)
        XCTAssertEqual(error, .keywordContainsSQLReservedCharacter)
    }
}
