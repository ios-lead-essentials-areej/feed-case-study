//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by areej sadaqa on 23/04/2026.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}
///we set it as public, because other modules will conform to it
public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
