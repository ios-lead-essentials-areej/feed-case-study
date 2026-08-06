//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

///To solve all issue we can make our Error generic and add associated types
///but we're only making LoadFeedResult equatable just because of the test, and this is a production code
///complicates alot our production codes , prod has no req of equatable 

public typealias LoadFeedResult = Result<[FeedImage], Error> 

public protocol FeedLoader {    
	func load(completion: @escaping (LoadFeedResult) -> Void)
}
