//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by areej sadaqa on 20/04/2026.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        return HTTPClient.shared.requestedURL = URL(string: "https://a-url.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    
    private init() {
       
    }
    var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestsDataFromURL() {
        let Client = HTTPClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(Client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        //arrange <Given>
        let Client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        
        //Act <when we invoke>
        sut.load()
        
        //Assert
        XCTAssertNotNil(Client.requestedURL)
    }

}

