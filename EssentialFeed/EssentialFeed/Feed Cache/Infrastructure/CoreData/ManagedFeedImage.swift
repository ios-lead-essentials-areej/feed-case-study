//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by areej sadaqa on 25/05/2026.
//

import CoreData

@objc(ManagedFeedImage)
 class ManagedFeedImage: NSManagedObject {
    @NSManaged  var id: UUID
    @NSManaged  var imageDescription: String?
    @NSManaged  var location: String?
    @NSManaged  var url: URL
    @NSManaged  var cache: ManagedCache
}

extension ManagedFeedImage {
    /// Local → Managed (the write path)
    /// It creates Core Data objects, so it needs an NSManagedObjectContext: ManagedFeedImage(context:) inserts each object into the context as a side effect.
    /// factory. It returns NSOrderedSet because that's what the feed relationship's type is (ordered, to preserve feed order).
     static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localFeed.map { local in
            let managed = ManagedFeedImage(context: context)
            managed.id = local.id
            managed.imageDescription = local.description
            managed.location = local.location
            managed.url = local.url
            return managed
        })
    }
    
    /// Managed → Local (the read path)
    /// It reads an existing managed object and produces a plain value type. No context needed, no insertion, no side effects —
    /// it's just a projection. It's an instance property because you always have a ManagedFeedImage in hand.
     var local: LocalFeedImage {
        return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }
}
