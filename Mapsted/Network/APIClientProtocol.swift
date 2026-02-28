//
//  APIClientProtocol.swift
//  Mapsted
//
//  Created by RahulM on 28/02/26.
//

import Foundation

/// Result type for async API calls.
enum APIResult<T> {
    case success(T)
    case failure(Error)
}

/// Protocol for fetching app data. Implementations can be real network or mock.
protocol APIClientProtocol: AnyObject {
    /// Fetches building information from GetBuildingData endpoint.
    func fetchBuildingData() async -> APIResult<[BuildingInfo]>

    /// Fetches analytics (device/purchase) data from GetAnalyticData endpoint.
    func fetchAnalyticsData() async -> APIResult<[DeviceUsage]>
}
