//
//  AnalyticsModels.swift
//  Mapsted
//
//  Created by RahulM on 28/02/26.
//

import Foundation

// MARK: - Device usage (per manufacturer)

/// One device type with its purchase sessions.
struct DeviceUsage: Codable {
    let manufacturer: String
    let marketName: String?
    let codename: String?
    let model: String?
    let usageStatistics: UsageStatistics

    enum CodingKeys: String, CodingKey {
        case manufacturer
        case marketName = "market_name"
        case codename
        case model
        case usageStatistics = "usage_statistics"
    }
}

/// Container for session infos (building + purchases).
struct UsageStatistics: Codable {
    let sessionInfos: [SessionInfo]

    enum CodingKeys: String, CodingKey {
        case sessionInfos = "session_infos"
    }
}

/// One session at a building with a list of purchases.
struct SessionInfo: Codable {
    let buildingId: Int
    let purchases: [Purchase]

    enum CodingKeys: String, CodingKey {
        case buildingId = "building_id"
        case purchases
    }
}

/// Single purchase record (item and cost).
struct Purchase: Codable {
    let itemId: Int
    let itemCategoryId: Int
    let cost: Double

    enum CodingKeys: String, CodingKey {
        case itemId = "item_id"
        case itemCategoryId = "item_category_id"
        case cost
    }
}
