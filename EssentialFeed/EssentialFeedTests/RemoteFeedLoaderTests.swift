//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by areej sadaqa on 20/04/2026.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load() {
        return client.get(from: url)
      
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
        let url = URL(string: "https://a-url.com")!
        let Client = HTTPClientSpy()
        _ = RemoteFeedLoader(url: url, client: Client)
        
        XCTAssertNil(Client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        //arrange <Given>
        let url: URL = URL(string: "https://a-given-url.com")!
        let Client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: Client)
        
        //Act <when we invoke>
        sut.load()
        
        //Assert
        XCTAssertEqual(Client.requestedURL, url)
    }

}

