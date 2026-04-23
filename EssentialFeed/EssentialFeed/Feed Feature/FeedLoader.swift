//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

///To solve all issue we can make our Error generic and add associated types
///but we're only making LoadFeedResult equatable just because of the test, and this is a production code
///complicates alot our production codes , prod has no req of equatable 

public enum LoadFeedResult<Error: Swift.Error> {
	case success([FeedItem])
	case failure(Error)
}

///To git rid of these equatable requirement -> which needed in the XCTAsserts tests
///so we need to not capture results anymore and compare the values we need to unwrap the Result type and compare the values inside the Results 
extension LoadFeedResult: Equatable where Error: Equatable {}

protocol FeedLoader {
    associatedtype Error: Swift.Error
    
	func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
