//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by areej sadaqa on 20/04/2026.
//

import EssentialFeed
import XCTest

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
        sut.load { _ in }

        //Assert
        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        //arrange <Given>
        let url: URL = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        //Act <when we invoke>
        sut.load { _ in }
        sut.load { _ in }

        //Assert
        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut,
               toCompleteWithError: .connectivity,
               when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
            
        })
    }

    func test_load_deliversErrorOnNo200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach({ index, code in
            expect(sut,
                   toCompleteWithError: .invalidData,
                   when: {
                client.complete(withStatusCode: code, at: index)
                
            })
        })
    }

    //we want to test our payload json data in many cases (invalid json, empty json, existed json)
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
        let (sut, client) = makeSUT()
        
      ///we want to capture the result json, but now .load func only capture errors, so we need to change it into results
    }
    
    func test_load_deliversNoItemOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut,
               toCompleteWithError: .invalidData,
               when: {
            let invalidJson = Data.init("Invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJson)
            
        })
    }
    
    // MARK: - Helpers

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (
        sut: RemoteFeedLoader,
        client: HTTPClientSpy
    ) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    //to handle duplication logic, only action and error is diff
    private func expect(_ sut: RemoteFeedLoader,
    toCompleteWithError error: RemoteFeedLoader.Error,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) { ///adding file and line so when it fails-> filed to the exact line  of code not on tne assertion here
        var capturedErrors = [RemoteFeedLoader.Result]()
        sut.load { capturedErrors.append($0) }
        
        action()
        
        XCTAssertEqual(capturedErrors, [.failure(error)], file: file, line: line)
    }

    private class HTTPClientSpy: HTTPClient {
        //the spy's job is to capture the messages (invocations) in a clear and comprehensice way, how many times the messages was invoked, with what parameters and in which order.
        // we can combine into one signle arrY (Invoking behaviour message)
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }

        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }

        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
    }
}
