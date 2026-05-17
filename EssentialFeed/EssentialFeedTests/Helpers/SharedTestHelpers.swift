//
//  SharedTestHelpers.swift
//  EssentialFeed
//
//  Created by areej sadaqa on 17/05/2026.
//

import Foundation
import EssentialFeed

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 1)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}
