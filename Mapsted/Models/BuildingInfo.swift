//
//  BuildingInfo.swift
//  Mapsted
//
//  Created by RahulM on 28/02/26.
//

import Foundation

/// Represents a single building from the GetBuildingData API.
struct BuildingInfo: Codable, Identifiable, Hashable {
    let buildingId: Int
    let buildingName: String
    let city: String
    let state: String
    let country: String

    var id: Int { buildingId }

    enum CodingKeys: String, CodingKey {
        case buildingId = "building_id"
        case buildingName = "building_name"
        case city
        case state
        case country
    }
}
