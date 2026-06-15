//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by areej sadaqa on 09/06/2026.
//

import XCTest
import EssentialFeed

// the idea is to integrate all the cache module objects and see how they behave in collaboration or integrations.
// so far we've been testing them in isolation by using test doubles but now e need to see how they behave when collaborating with real instances of the production types.
 class EssentialFeedCacheIntegrationTests: XCTestCase {

     override func setUp() {
         super.setUp()
         
         setupEmptyStoreState()
     }
     
     override func tearDown() {
         super.tearDown()
         
         undoStoreSideEffects()
     }
     
     func test_load_deliversNoItemsOnEmptyCache() {
         let sut = makeSUT()
         
         let exp = expectation(description: "Wait for load completion")
         sut.load { result in
             switch result {
             case let .success(imageFeed):
                 XCTAssertEqual(imageFeed, [], "Expected empty feed")
                 
             case let .failure(error):
                 XCTFail("Expected successful feed result, got \(error) instead")
             }
             
             exp.fulfill()
         }
         wait(for: [exp], timeout: 1.0)
     }
     
     // MARK: Helpers
     
     // here we're integrating CoreDataFeedStore with LocalFeedLoader
     private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
         let storeBundle = Bundle(for: CoreDataFeedStore.self)
         let storeURL = testSpecificStoreURL()
         let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
         let sut = LocalFeedLoader(store: store, currentDate: Date.init)
         trackForMemoryLeaks(store, file: file, line: line)
         trackForMemoryLeaks(sut, file: file, line: line)
         return sut
     }
     
     private func setupEmptyStoreState() {
         deleteStoreArtifacts()
     }
     
     private func undoStoreSideEffects() {
         deleteStoreArtifacts()
     }
     
     private func deleteStoreArtifacts() {
         try? FileManager.default.removeItem(at: testSpecificStoreURL())
     }
     
     //we're using physical file URL to make sure we can create and load coreData SQLite artifacts to disk, which can slow down the tests
     //in Unit/Isolated tests, we prefer to run operations in-memory when possible, which should be ultra-fast 
     private func testSpecificStoreURL() -> URL {
         return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
     }
     
     private func cachesDirectory() -> URL {
         return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
     }
 }
