//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by areej sadaqa on 04/05/2026.
//

import XCTest
import EssentialFeed

final class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    ///this is an issue to make our test we're modifiying the production code here but it should not
    func get(from url: URL, completionHandler: @escaping (HTTPClientResult) -> Void ) {
        //the issue of our tests now its sensitive to the correct url passing because we intercept only our url, but to enhance we can intercept all reqests regarding the url
        //also we want our assertion to be more precise about the error when they fail.
        session.dataTask(with: url, completionHandler: { _ ,_, error in
            if let error = error {
                completionHandler(.failure(error))
            }
        }).resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromURL_performsGetRequestWithURL() {
        URLProtocolStub.startInterceptingRequests()
        
        let url = URL(string: "http://any-url.com")!
        let exp = expectation(description: "wait for completion")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        URLSessionHTTPClient().get(from: url, completionHandler: {_ in })
        
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_failsOnRequestError() {
        //we need to register a class
        URLProtocolStub.startInterceptingRequests()
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                ///The error and the receivedError are different NSError instances, which is a new behavior on iOS 14+.
                ///Since both error instances share the same domain and code, you could compare the errors by those values:
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
                ///Or if you don’t care about the specific error values, you can just make sure it’s not nil:
                XCTAssertNotNil(receivedError)
            default:
                XCTFail("Expected Failutre with error \(error) and got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        //and we need to un register it after we finish because we don't want to be stubbing other tests requests
        //this same a good candidate to move to setup tearDown per method but since its only one test we can leave it
        URLProtocolStub.stopInterceptingRequest()
    }
    
    // MARK: - Helpers
    
    private class URLProtocolStub: URLProtocol {
        //we can intercept all reqests regarding the url,  no need for url
        private static var stub: Sub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Sub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Sub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        //URLProtocol testing network requested is to use the little-known URL Loading System to intercept and handle requests with URLProtocol stubs.
        //it makes us intercept the request and control it
        
        //this func 'canInit' we return true if we can intercept the network request
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        //framwork accept that we are going to handle this request and its going to invoke us to say now it's time for you to start loading the url
        override func startLoading() {
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                // this is URLProtocolClient with punch of methods we can use
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            //after we finish laoding
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            // if we don't implement it will crash
        }
    }
}
