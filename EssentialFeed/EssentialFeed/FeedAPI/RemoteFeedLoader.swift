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
    
    public func load(completion: @escaping (Result) -> Void) {
        ///mapping the domain error with our enum type error
        client.get(from: url) { result in
            
            switch result {
            case let .success(data, response):
                do {
                    let items = try FeedItemMapper.map(data, response)
                    completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
