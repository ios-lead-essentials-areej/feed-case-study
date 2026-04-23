//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by areej sadaqa on 20/04/2026.
//

import Foundation

///we set it as public, because other modules will use it and creat
/// make it final: to prevent subclassing
public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    ///I think the RemoteFeedLoader could get deallocated in some scenarios, for example if, in some UI setup, the user dismisses the current view controller while the loading is still in progress.
    public func load(completion: @escaping (Result) -> Void) {
        ///mapping the domain error with our enum type error
        client.get(from: url) { [weak self] result in
            ///If you don't reference self inside the closure, it won't be retained. So, in this case, self (RemoteFeedLoader) won't be retained.
            ///However, the client closure retains the closure you passed to the RemoteFeedLoader - and the client instance can outlive the RemoteFeedLoader instance (even though you set the RemoteFeedLoader to nil, the client may still exist in memory).
            ///So even though the RemoteFeedLoader was deallocated, the client can still exist and hold a reference to your completion closure and can call it on completion.
            ///
            guard self != nil else { return } ///without this we will get memory leak and failed test (test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated)

            switch result {
            case let .success(data, response):
                completion(FeedItemMapper.map(data, from: response)) //self here might return a raiain cycle
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
