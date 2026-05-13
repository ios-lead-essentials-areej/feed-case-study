//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by areej sadaqa on 13/05/2026.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias insertionCompletion = (Error?) -> Void

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping insertionCompletion)
}
