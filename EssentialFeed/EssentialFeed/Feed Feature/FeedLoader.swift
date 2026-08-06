//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

///To solve all issue we can make our Error generic and add associated types
///but we're only making LoadFeedResult equatable just because of the test, and this is a production code
///complicates alot our production codes , prod has no req of equatable 


public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    
	func load(completion: @escaping (Result) -> Void)
}
