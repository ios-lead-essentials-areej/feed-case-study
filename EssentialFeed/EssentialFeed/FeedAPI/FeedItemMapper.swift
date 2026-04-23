//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by areej sadaqa on 23/04/2026.
//

import Foundation

internal final class FeedItemMapper {
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

    private static var OK_200: Int { return 200 }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map {$0.item }
    }
    
}
