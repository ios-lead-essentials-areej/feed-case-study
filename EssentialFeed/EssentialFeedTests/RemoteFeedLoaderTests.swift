//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by areej sadaqa on 20/04/2026.
//

import XCTest

import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestsDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        //arrange <Given>
        let url: URL = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        //Act <when we invoke>
        sut.load()
        
        //Assert
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        //arrange <Given>
        let url: URL = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        //Act <when we invoke>
        sut.load()
        sut.load()
        
        //Assert
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        client.error = NSError(domain: "Test", code: 0)
        
        var capturedError: RemoteFeedLoader.Error?
        sut.load { error in
            capturedError = error
        }
        
        XCTAssertEqual(capturedError, .connectivity)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader,
                                                                           client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var error: Error?
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            if let error = error {
                completion(error)
            }
            requestedURLs.append(url)
        }
    }
}

