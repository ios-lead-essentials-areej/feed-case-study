//
//  XCTTestCase+MemoryLeakTracking.swift
//  EssentialFeed
//
//  Created by areej sadaqa on 06/05/2026.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath,
                                     line: UInt = #line) {
        addTeardownBlock( { [weak instance] in
            XCTAssertNil(instance, "Instnace should have been deallocated. Potiential memory leak.", file: file, line: line)
        })
    }
}
