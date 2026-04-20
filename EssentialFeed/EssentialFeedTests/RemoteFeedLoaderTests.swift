//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by areej sadaqa on 20/04/2026.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
        return client.get(from: URL(string: "https://a-url.com")!)
      
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    func get(from url: URL) {
        requestedURL = url
    }
    var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestsDataFromURL() {
        let Client = HTTPClientSpy()
        _ = RemoteFeedLoader(client: Client)
        
        XCTAssertNil(Client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        //arrange <Given>
        let Client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: Client)
        
        //Act <when we invoke>
        sut.load()
        
        //Assert
        XCTAssertNotNil(Client.requestedURL)
    }

}

