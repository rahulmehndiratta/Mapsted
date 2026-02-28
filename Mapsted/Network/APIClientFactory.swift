//
//  APIClientFactory.swift
//  Mapsted
//
//  Created by RahulM on 28/02/26.
//

import Foundation

/// Factory that produces API client instances conforming to APIClientProtocol.
enum APIClientFactory {
    /// Returns the default production API client (Mapsted).
    static func makeDefault() -> APIClientProtocol {
        MapstedAPIClient()
    }

    /// Returns a client with custom base URL (e.g. for staging).
    static func make(baseURL: URL) -> APIClientProtocol {
        MapstedAPIClient(baseURL: baseURL)
    }
}
