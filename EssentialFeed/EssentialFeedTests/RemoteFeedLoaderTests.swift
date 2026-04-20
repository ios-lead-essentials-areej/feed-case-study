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
        //this mean we're mixing responsiblities, responsibility of invoking a method in an object, and responsibility of locating this object
        //if you're using a shared property I know how to locate this object in mem. which I don't need that, if we inject we've more control on our code
        //we should refactor it to composition -> through injection
    }
}

class HTTPClient {
    static var shared = HTTPClient() // this means it's a global var not singleton anymore
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

