//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by areej sadaqa on 16/05/2026.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
