//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by areej sadaqa on 20/04/2026.
//

import Foundation

///we set it as public, because other modules will conform to it
public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}

///we set it as public, because other modules will use it and creat
/// make it final: to prevent subclassing
public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Error) -> Void = { _ in }) {
        ///mapping the domain error with our enum type error
        client.get(from: url) { error in
            completion(.connectivity)
        }
    }
}
