//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by areej sadaqa on 19/05/2026.
//

import Foundation

// Policy is a rule and with no identity, and we separate business logic with identity by calling them entities, so entities are models with identity and valude objects are models with no identity, in this case the policy has no identity, its just encapsulate a rule and we don't need an instance of FeedCachePolicy, it can be static

final class FeedCachePolicy {
    private init() {}
    
    // but having currentDate dependencies can make it not deterministic on each use of FeedCachePolicy
    // so instead we can make it method injection
    private static let calender = Calendar(identifier: .gregorian)
 
    private static var maxCacheAgeInDays: Int {
        return 7
    }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calender.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
