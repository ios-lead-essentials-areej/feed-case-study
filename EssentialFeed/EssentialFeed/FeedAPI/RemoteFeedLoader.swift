//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by areej sadaqa on 20/04/2026.
//

import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse)
    case failure(Error)
}
///we set it as public, because other modules will conform to it
public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

///we set it as public, because other modules will use it and creat
/// make it final: to prevent subclassing
public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        ///mapping the domain error with our enum type error
        client.get(from: url) { result in
            
            switch result {
            case .success:
                completion(.invalidData)
            case .failure:
                completion(.connectivity)
            }
        }
    }
}
