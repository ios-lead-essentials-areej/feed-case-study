//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by areej sadaqa on 25/05/2026.
//

import CoreData

@objc(ManagedCache)
 class ManagedCache: NSManagedObject {
    @NSManaged  var timestamp: Date
    @NSManaged  var feed: NSOrderedSet
}

extension ManagedCache {
     static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    //It enforces the invariant your store depends on: at most one ManagedCache exists at a time.
     static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context) //fetch → ManagedCache? (the existing cache, if any)
            .map(context.delete) // Optional.map: if non-nil, delete it; if nil, do nothing
        return ManagedCache(context: context)  // insert a fresh, empty one
    }
    
     var localFeed: [LocalFeedImage] {
        return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
    }
}
