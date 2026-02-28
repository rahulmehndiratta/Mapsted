//
//  MapstedAPIClient.swift
//  Mapsted
//
//  Created by RahulM on 28/02/26.
//

import Foundation

/// Production implementation of APIClientProtocol for Mapsted APIs.
final class MapstedAPIClient: APIClientProtocol {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    private enum Endpoint {
        static let building = AppConstants.Network.buildingEndpoint
        static let analytics = AppConstants.Network.analyticsEndpoint
    }

    init(baseURL: URL = AppConstants.Network.baseURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = JSONDecoder()
    }

    func fetchBuildingData() async -> APIResult<[BuildingInfo]> {
        let url = baseURL.appendingPathComponent(Endpoint.building)
        return await fetch(url, as: [BuildingInfo].self)
    }

    func fetchAnalyticsData() async -> APIResult<[DeviceUsage]> {
        let url = baseURL.appendingPathComponent(Endpoint.analytics)
        return await fetch(url, as: [DeviceUsage].self)
    }

    private func fetch<T: Decodable>(_ url: URL, as type: T.Type) async -> APIResult<T> {
        do {
            let (data, response) = try await session.data(from: url)
            guard let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) else {
                return .failure(APIClientError.badResponse)
            }
            let decoded = try decoder.decode(T.self, from: data)
            return .success(decoded)
        } catch {
            if let urlError = error as? URLError,
               urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost {
                return .failure(APIClientError.noConnection)
            }
            return .failure(error)
        }
    }
}

enum APIClientError: LocalizedError, Equatable {
    case badResponse
    case noConnection

    var errorDescription: String? {
        switch self {
        case .badResponse:
            return AppStrings.Errors.unexpectedResponse
        case .noConnection:
            return AppStrings.Errors.noConnection
        }
    }
}
