//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by areej sadaqa on 20/04/2026.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init() {
        let Client = HTTPClient()
        let sut = RemoteFeedLoader()
//        sut.loader()
        
        XCTAssertNil(Client.requestedURL, )
    }

}
