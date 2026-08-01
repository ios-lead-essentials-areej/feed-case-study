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
         
         expect(sut, toLoad: [])
     }
     
     // load method should delivers items saved on separate instances, proving that we're storing things to disk and another instance can fetch that data from disk, which also proves that we're storing data across application runs
     // coreData unit tests uses an in memory representation of the data, so having tow instaces would generate tow separate memory spaces completely isolated, now in integration we can actually save data to disk and use another instance to fetch it proving that the whole caching dance works accordingly
     
     func test_load_deliversItemsSavedOnASeparateInstance() {
         let sutToPerformSave = makeSUT()
         let sutToPerformLoad = makeSUT()
         let feed = uniqueImageFeed().models
         
         save(feed, with: sutToPerformSave)
         
         expect(sutToPerformLoad, toLoad: feed)
     }
     
     func test_save_overridesItemsSavedOnASeparateInstance() {
         let sutToPerformFirstSave = makeSUT()
         let sutToPerformLastSave = makeSUT()
         let sutToPerformLoad = makeSUT()
         let firstFeed = uniqueImageFeed().models
         let latestFeed = uniqueImageFeed().models
         
         save(firstFeed, with: sutToPerformFirstSave)
         save(latestFeed, with: sutToPerformLastSave)
         
         expect(sutToPerformLoad, toLoad: latestFeed)
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
     
     private func save(_ feed: [FeedImage], with loader: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
         let saveExp = expectation(description: "Wait for save completion")
         loader.save(feed) { saveError in
             XCTAssertNil(saveError, "Expected to save feed successfully", file: file, line: line)
             saveExp.fulfill()
         }
         wait(for: [saveExp], timeout: 1.0)
     }
     
     private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
         let exp = expectation(description: "Wait for load completion")
         sut.load { result in
             switch result {
             case let .success(loadedFeed):
                 XCTAssertEqual(loadedFeed, expectedFeed, file: file, line: line)
                 
             case let .failure(error):
                 XCTFail("Expected successful feed result, got \(error) instead", file: file, line: line)
             }
             
             exp.fulfill()
         }
         wait(for: [exp], timeout: 1.0)
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
