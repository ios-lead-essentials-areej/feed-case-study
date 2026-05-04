//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by areej sadaqa on 04/05/2026.
//

import XCTest

final class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url, completionHandler: { _ ,_, _ in })
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_createDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(session.recievedURLs, [url])
    }
    
    // MARK: - Helpers
    
    private class URLSessionSpy: URLSession {
        var recievedURLs = [URL]()
  
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
            recievedURLs.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {}
}
