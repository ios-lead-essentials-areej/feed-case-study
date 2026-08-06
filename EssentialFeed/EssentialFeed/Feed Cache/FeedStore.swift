//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by areej sadaqa on 13/05/2026.
//

import Foundation

/// CachedFeed is similar to Swift.Optional Standard, the absence of it will be declared by using it as Optional, found -> some, empty -> none
/// instead of struct with public init, we can make it typealias with tuple value
public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    typealias DeletionResult = Result<Void,Error>
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    typealias InsertionResult = Result<Void,Error>
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    typealias RetrivalResult = Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (FeedStore.RetrivalResult) -> Void
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}
