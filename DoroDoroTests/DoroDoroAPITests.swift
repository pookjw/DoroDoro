//
//  DoroDoroAPITests.swift
//  DoroDoroTests
//
//  Created by Jinwoo Kim on 2/25/21.
//

import XCTest
import RxSwift
@testable import DoroDoro

final internal class DoroDoroAPITests: XCTestCase {
    override internal func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    // MARK: - 도로명주소 API 요청 테스트
    
    internal func testRequestAddrLinkEvent() {
        let disposeBag: DisposeBag = .init()
        let expectation: XCTestExpectation = .init(description: "Requesting... (\(#function))")
        
        APIService.shared.addrLinkEvent
            .subscribe(onNext: { result in
                XCTAssertNotNil(result.juso)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        APIService.shared.addrLinkErrorEvent
            .subscribe(onNext: { error in
                XCTFail(error.localizedDescription)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
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
        let disposeBag: DisposeBag = .init()
        let expectation: XCTestExpectation = .init(description: "Requesting... (\(#function))")
        
        APIService.shared.addrEngEvent
            .subscribe(onNext: { result in
                XCTAssertNotNil(result.juso)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        APIService.shared.addrEngErrorEvent
            .subscribe(onNext: { error in
                XCTFail(error.localizedDescription)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
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
}
