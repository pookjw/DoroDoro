//
//  DoroDoroAPIErrorTests.swift
//  DoroDoroTests
//
//  Created by Jinwoo Kim on 2/26/21.
//

import XCTest
import Combine
@testable import DoroDoro

final internal class DoroDoroAPIErrorTests: XCTestCase {
    override internal func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    // MARK: - 도로명주소 API 요청 오류 테스트
    
    internal func testRequestAddrLinkEvent() {
        var cancellableBag: Set<AnyCancellable> = .init()
        let expactation: XCTestExpectation = .init(description: "Requesting... (\(#function))")
        
        APIService.shared.addrLinkEvent
            .sink(receiveValue: { result in
                XCTFail()
            })
            .store(in: &cancellableBag)
        
        APIService.shared.addrLinkErrorEvent
            .sink(receiveValue: { error in
                XCTAssertEqual(error, .noResults)
                expactation.fulfill()
            })
            .store(in: &cancellableBag)
        
        APIService.shared.requestAddrLinkEvent(keyword: "썽쑤똥")
        
        wait(for: [expactation], timeout: 10)
    }
    
    internal func testRequestAddrLink() {
        let expactation: XCTestExpectation = .init(description: "Requesting... (\(#function))")
        
        APIService.shared.requestAddrLink(keyword: "123") { (result, error) in
            XCTAssertNil(result)
            XCTAssertEqual(error, .wrongKeyword)
            expactation.fulfill()
        }
        
        wait(for: [expactation], timeout: 10)
    }
    
    internal func testRequestAddrLinkSync() {
        let (result, error): (AddrLinkResultsData?, AddrLinkApiError?) = APIService.shared.requestAddrLink(keyword: "아")
        
        XCTAssertNil(result)
        XCTAssertEqual(error, .tooShortKeyword)
    }
    
    // MARK: - 영문주소 API 요청 오류 테스트
    
    internal func testRequestAddrEngEvent() {
        var cancellableBag: Set<AnyCancellable> = .init()
        let expectation: XCTestExpectation = .init(description: "Requesting... (\(#function))")
        
        APIService.shared.addrEngEvent
            .sink(receiveValue: { result in
                XCTFail()
            })
            .store(in: &cancellableBag)
        
        APIService.shared.addrEngErrorEvent
            .sink(receiveValue: { error in
                XCTAssertEqual(error, .tooLongIntegerKeyword)
                expectation.fulfill()
            })
            .store(in: &cancellableBag)
        
        APIService.shared.requestAddrEngEvent(keyword: "성수동1278720170270")
        
        wait(for: [expectation], timeout: 10)
    }
    
    internal func testRequestAddrEng() {
        let expectation: XCTestExpectation = .init(description: "Requesting... (\(#function))")
        
        APIService.shared.requestAddrEng(keyword: "") { (result, error) in
            XCTAssertNil(result)
            XCTAssertEqual(error, .emptyKeyword)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    internal func testRequestAddrEngSync() {
        let (result, error): (AddrEngResultsData?, AddrEngApiError?) = APIService.shared.requestAddrEng(keyword: "성수동%")
        
        XCTAssertNil(result)
        XCTAssertEqual(error, .keywordContainsSQLReservedCharacter)
    }
}
