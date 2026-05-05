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
    
    struct UnexpectedValuesRepresentation: Error {}
    
    ///this is an issue to make our test we're modifiying the production code here but it should not
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void ) {
        //the issue of our tests now its sensitive to the correct url passing because we intercept only our url, but to enhance we can intercept all reqests regarding the url
        //also we want our assertion to be more precise about the error when they fail.
        session.dataTask(with: url, completionHandler: { _ ,_, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }).resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    
    //invoked before each test methods
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    //invoked after each test methods
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_performsGetRequestWithURL() {
       
        let url = anyURL()
        let exp = expectation(description: "wait for completion")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) {_ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError()
        
        let receivedError: NSError? = resultErrorFor(data: nil, response: nil, error: requestError)
                
        XCTAssertEqual(receivedError?.domain, requestError.domain)
        XCTAssertEqual(receivedError?.code, requestError.code)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        
        XCTAssertNotNil(resultErrorFor(data: nil,
                                       response: nil,
                                       error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil,
                                       response: nonHTTPURLResponse(),
                                       error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil,
                                       response: anyHTTPURLResponse(),
                                       error: nil))
        
        XCTAssertNotNil(resultErrorFor(data: anyData(),
                                       response: nil,
                                       error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(),
                                       response: nil,
                                       error: anyNSError()))
        
        XCTAssertNotNil(resultErrorFor(data: nil,
                                       response: nonHTTPURLResponse(),
                                       error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil,
                                       response: anyHTTPURLResponse(),
                                       error: anyNSError()))
        
        XCTAssertNotNil(resultErrorFor(data: anyData(),
                                       response: nonHTTPURLResponse(),
                                       error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(),
                                       response: anyHTTPURLResponse(),
                                       error: anyNSError()))
        
        XCTAssertNotNil(resultErrorFor(data: anyData(),
                                       response: nonHTTPURLResponse(),
                                       error: nil))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyData() -> Data {
        return Data.init("any data".utf8)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(),
                           mimeType: nil,
                           expectedContentLength: 0,
                           textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
       return HTTPURLResponse(url: anyURL(),
                        statusCode: 200,
                        httpVersion: nil,
                              headerFields: nil)!
    }
    
    private func resultErrorFor(data: Data?,
                                response: URLResponse?,
                                error: Error?,
                                file: StaticString = #filePath,
                                line: UInt = #line) -> NSError? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "wait for completion")
        
        var receivedError: Error?
        
        sut.get(from: anyURL()) { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected Failutre, got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError as NSError?
    }
    
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
