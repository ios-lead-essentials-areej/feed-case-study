//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by areej sadaqa on 20/04/2026.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        return HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
}

class HTTPClient {
    static var shared = HTTPClient()
    func get(from url: URL) {}
}

class HTTPClientSpy: HTTPClient {
    override func get(from url: URL) {
        requestedURL = url
    }
    var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestsDataFromURL() {
        let Client = HTTPClientSpy()
        HTTPClient.shared = Client
        _ = RemoteFeedLoader()
        
        XCTAssertNil(Client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        //arrange <Given>
        let Client = HTTPClientSpy()
        HTTPClient.shared = Client
        let sut = RemoteFeedLoader()
        
        //Act <when we invoke>
        sut.load()
        
        //Assert
        XCTAssertNotNil(Client.requestedURL)
    }

}

