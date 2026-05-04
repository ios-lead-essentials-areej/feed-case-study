//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by areej sadaqa on 04/05/2026.
//

import XCTest
import EssentialFeed

///Replacing subclass strategy with protocol base strategy for mocking the URL session
/// but it complicates production code, extra protocols only for test no need for it, which matches exactly the interface 
protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

final class URLSessionHTTPClient {
    let session: HTTPSession
    
    init(session: HTTPSession) {
        self.session = session
    }
    
    ///this is an issue to make our test we're modifiying the production code here but it should not
    func get(from url: URL, completionHandler: @escaping (HTTPClientResult) -> Void ) {
        session.dataTask(with: url, completionHandler: { _ ,_, error in
            if let error = error {
                completionHandler(.failure(error))
            }
        }).resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    ///here to test if the client is statring 'resuming'
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = HTTPSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://any-url.com")!
        let session = HTTPSessionSpy()
        let task = URLSessionDataTaskSpy()
        let error = NSError(domain: "any error", code: 1)
        session.stub(url: url, error: error)
        
        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected Failutre with error \(error) and got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private class HTTPSessionSpy: HTTPSession {
        private var stubs = [URL: Sub]()
        
        private struct Sub {
            let task: HTTPSessionTask
            let error: Error?
        }
        
        func stub(url: URL, task: HTTPSessionTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Sub(task: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> HTTPSessionTask {
            guard let sub = stubs[url] else {
               fatalError("Couldn't find stub for \(url)")
            }
            completionHandler(nil, nil, sub.error)
            return sub.task
        }
    }
    
    private class FakeURLSessionDataTask: HTTPSessionTask {
        ///also we had to override resume() here but we don't need it
        func resume() {
        }
    }
    private class URLSessionDataTaskSpy: HTTPSessionTask {
        var resumeCallCount = 0
        
        func resume() {
            resumeCallCount += 1
        }
    }
}
