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

private class FeedItemMapper {
    private struct Root: Decodable {
        let items: [Item]
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL // the correct key from API
        
        var item: FeedItem { //so now the FeeItem doesnt know about our api knowlege, it's an implementation details that is leaking into more abstract, higher level module
            return FeedItem(id: id,
                            description: description,
                            location: location,
                            imageURL: image)
        }
    }

    static var OK_200: Int { return 200 }
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map {$0.item }
    }
}
