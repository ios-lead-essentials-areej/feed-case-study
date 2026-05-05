//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by areej sadaqa on 06/05/2026.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    ///this is an issue to make our test we're modifiying the production code here but it should not
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void ) {
        //the issue of our tests now its sensitive to the correct url passing because we intercept only our url, but to enhance we can intercept all reqests regarding the url
        //also we want our assertion to be more precise about the error when they fail.
        session.dataTask(with: url, completionHandler: { data , response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }).resume()
    }
}
