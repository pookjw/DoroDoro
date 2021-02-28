//
//  DoroDoroAPITests.swift
//  DoroDoroTests
//
//  Created by Jinwoo Kim on 2/25/21.
//

import XCTest
import Combine
@testable import DoroDoro

final internal class DoroDoroAPITests: XCTestCase {
    override internal func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    // MARK: - 도로명주소 API 요청 테스트
    
    internal func testRequestAddrLinkEvent() {
        var cancellableBag: Set<AnyCancellable> = .init()
        let expectation: XCTestExpectation = .init(description: "Requesting... (\(#function))")
        
        APIService.shared.addrLinkEvent
            .sink(receiveValue: { result in
                XCTAssertNotNil(result.juso)
                expectation.fulfill()
            })
            .store(in: &cancellableBag)
        
        APIService.shared.addrLinkErrorEvent
            .sink(receiveValue: { error in
                XCTFail(error.localizedDescription)
                expectation.fulfill()
            })
            .store(in: &cancellableBag)
        
        APIService.shared.requestAddrLinkEvent(keyword: "성수동")
        
        wait(for: [expectation], timeout: 10)
    }
    
    internal func testRequestAddrLink() {
        let expectation: XCTestExpectation = .init(description: "Requesting... (\(#function))")
        
        APIService.shared.requestAddrLink(keyword: "성수동") { (result, error) in
            XCTAssertNil(error, error!.localizedDescription)
            XCTAssertNotNil(result)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    internal func testRequestAddrLinkSync() {
        let (result, error): (AddrLinkResultsData?, AddrLinkApiError?) = APIService.shared.requestAddrLink(keyword: "성수동")
        
        XCTAssertNil(error, error!.localizedDescription)
        XCTAssertNotNil(result)
    }
    
    // MARK: - 영문주소 API 요청 테스트
    
    internal func testRequestAddrEngEvent() {
        var cancellableBag: Set<AnyCancellable> = .init()
        let expectation: XCTestExpectation = .init(description: "Requesting... (\(#function))")
        
        APIService.shared.addrEngEvent
            .sink(receiveValue: { result in
                XCTAssertNotNil(result.juso)
                expectation.fulfill()
            })
            .store(in: &cancellableBag)
        
        APIService.shared.addrEngErrorEvent
            .sink(receiveValue: { error in
                XCTFail(error.localizedDescription)
                expectation.fulfill()
            })
            .store(in: &cancellableBag)
        
        APIService.shared.requestAddrEngEvent(keyword: "성수동")
        
        wait(for: [expectation], timeout: 10)
    }
    
    internal func testRequestAddrEng() {
        let expectation: XCTestExpectation = .init(description: "Requesting... (\(#function))")
        
        APIService.shared.requestAddrEng(keyword: "성수동") { (result, error) in
            XCTAssertNil(error, error!.localizedDescription)
            XCTAssertNotNil(result)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    internal func testRequestAddrEngSync() {
        let (result, error): (AddrEngResultsData?, AddrEngApiError?) = APIService.shared.requestAddrEng(keyword: "성수동")
        
        XCTAssertNil(error, error!.localizedDescription)
        XCTAssertNotNil(result)
    }
    
    // MARK: - 좌표제공 API 요청 테스트
    internal func testRequestAddrCoordEvent() {
        var cancellableBag: Set<AnyCancellable> = .init()
        let expectation: XCTestExpectation = .init(description: "Requesting... (\(#function))")
        
        APIService.shared.addrLinkEvent
            .sink(receiveValue: { result in
                XCTAssertNotNil(result.juso)
                APIService.shared.requestCoordEvent(data: result.juso[0].convertToAddrCoordSearchData())
            })
            .store(in: &cancellableBag)
        
        APIService.shared.addrLinkErrorEvent
            .sink(receiveValue: { error in
                XCTFail(error.localizedDescription)
                expectation.fulfill()
            })
            .store(in: &cancellableBag)
        
        APIService.shared.addrCoordEvent
            .sink(receiveValue: { result in
                XCTAssertNotNil(result.juso)
                expectation.fulfill()
            })
            .store(in: &cancellableBag)
        
        APIService.shared.addrCoordErrorEvent
            .sink(receiveValue: { error in
                XCTFail(error.localizedDescription)
                expectation.fulfill()
            })
            .store(in: &cancellableBag)
        
        APIService.shared.requestAddrLinkEvent(keyword: "성수동")
        
        wait(for: [expectation], timeout: 10)
    }
    
    internal func testRequestAddrCoord() {
        let expectation: XCTestExpectation = .init(description: "Requesting... (\(#function))")
        
        APIService.shared.requestAddrLink(keyword: "성수동") { (result, error) in
            XCTAssertNil(error, error!.localizedDescription)
            XCTAssertNotNil(result)
            
            APIService.shared.requestCoord(data: result!.juso[0].convertToAddrCoordSearchData()) { (result, error) in
                XCTAssertNil(error, error!.localizedDescription)
                XCTAssertNotNil(result)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    internal func testRequestAddrCoordSync() {
        let (result1, error1): (AddrLinkResultsData?, AddrLinkApiError?) = APIService.shared.requestAddrLink(keyword: "성수동")
        
        XCTAssertNil(error1, error1!.localizedDescription)
        XCTAssertNotNil(result1)
        
        let (result2, error2): (AddrCoordResultsData?, AddrCoordApiError?) = APIService.shared.requestCoord(data: result1!.juso[0].convertToAddrCoordSearchData())
        XCTAssertNil(error2, error2!.localizedDescription)
        XCTAssertNotNil(result2)
    }
}
