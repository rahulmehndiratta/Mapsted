//
//  DashboardViewModel.swift
//  Mapsted
//
//  Created by RahulM on 28/02/26.
//

import Foundation
import Combine

/// Single purchase row with all fields needed for filtering (manufacturer, location, item, category).
struct FlattenedPurchase {
    let manufacturer: String
    let buildingId: Int
    let itemId: Int
    let itemCategoryId: Int
    let cost: Double
}

/// ViewModel state for the dashboard screen.
@MainActor
final class DashboardViewModel: ObservableObject {
    // MARK: - Loaded data
    @Published private(set) var buildings: [BuildingInfo] = []
    @Published private(set) var devices: [DeviceUsage] = []
    @Published private(set) var isLoading = false
    @Published private(set) var loadError: String?
    @Published private(set) var isOffline = false

    // MARK: - Selections (dropdowns)
    @Published var selectedManufacturer: String?
    @Published var selectedCategoryId: Int?
    @Published var selectedCountry: String?
    @Published var selectedState: String?
    @Published var selectedItemId: Int?

    // MARK: - Dependencies
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClientFactory.makeDefault()) {
        self.apiClient = apiClient
    }

    // MARK: - Dropdown options (unique values from data)

    var manufacturerOptions: [String] {
        Array(Set(devices.map(\.manufacturer))).sorted()
    }

    var categoryOptions: [Int] {
        Array(Set(flattenedPurchases.map(\.itemCategoryId))).sorted()
    }

    var countryOptions: [String] {
        Array(Set(buildings.map(\.country))).sorted()
    }

    var stateOptions: [String] {
        Array(Set(buildings.map(\.state))).sorted()
    }

    var itemOptions: [Int] {
        Array(Set(flattenedPurchases.map(\.itemId))).sorted()
    }

    // MARK: - Flattened purchases (manufacturer + building + item + category + cost)

    private var flattenedPurchases: [FlattenedPurchase] {
        var list: [FlattenedPurchase] = []
        for device in devices {
            for session in device.usageStatistics.sessionInfos {
                for purchase in session.purchases {
                    list.append(FlattenedPurchase(
                        manufacturer: device.manufacturer,
                        buildingId: session.buildingId,
                        itemId: purchase.itemId,
                        itemCategoryId: purchase.itemCategoryId,
                        cost: purchase.cost
                    ))
                }
            }
        }
        return list
    }

    private func building(for buildingId: Int) -> BuildingInfo? {
        buildings.first { $0.buildingId == buildingId }
    }

    // MARK: - Computed values (right column)

    /// Total purchase costs for the selected manufacturer (e.g. Samsung).
    var manufacturerTotal: Double {
        guard let manufacturer = selectedManufacturer else { return 0 }
        return flattenedPurchases
            .filter { $0.manufacturer == manufacturer }
            .reduce(0, { $0 + $1.cost })
    }

    /// Total purchase costs for the selected item category (e.g. item_category_id = 7).
    var categoryTotal: Double {
        guard let categoryId = selectedCategoryId else { return 0 }
        return flattenedPurchases
            .filter { $0.itemCategoryId == categoryId }
            .reduce(0, { $0 + $1.cost })
    }

    /// Total purchase costs in the selected country.
    var countryTotal: Double {
        guard let country = selectedCountry else { return 0 }
        let buildingIdsInCountry = Set(buildings.filter { $0.country == country }.map(\.buildingId))
        return flattenedPurchases
            .filter { buildingIdsInCountry.contains($0.buildingId) }
            .reduce(0, { $0 + $1.cost })
    }

    /// Total purchase costs in the selected state.
    var stateTotal: Double {
        guard let state = selectedState else { return 0 }
        let buildingIdsInState = Set(buildings.filter { $0.state == state }.map(\.buildingId))
        return flattenedPurchases
            .filter { buildingIdsInState.contains($0.buildingId) }
            .reduce(0, { $0 + $1.cost })
    }

    /// Number of times the selected item was purchased.
    var itemPurchaseCount: Int {
        guard let itemId = selectedItemId else { return 0 }
        return flattenedPurchases.filter { $0.itemId == itemId }.count
    }

    /// Building name that had the most total purchase costs.
    var buildingWithMostTotalPurchasesName: String {
        var totals: [Int: Double] = [:]
        for p in flattenedPurchases {
            totals[p.buildingId, default: 0] += p.cost
        }
        guard let topBuildingId = totals.max(by: { $0.value < $1.value })?.key,
              let building = building(for: topBuildingId) else {
            return AppStrings.General.unknownBuilding
        }
        return building.buildingName
    }

    // MARK: - Actions

    func loadData() async {
        isLoading = true
        loadError = nil
        isOffline = false
        defer { isLoading = false }

        async let buildingResult = apiClient.fetchBuildingData()
        async let analyticsResult = apiClient.fetchAnalyticsData()

        switch await buildingResult {
        case .success(let list):
            buildings = list
        case .failure(let error):
            if let apiError = error as? APIClientError, apiError == .noConnection {
                isOffline = true
                loadError = error.localizedDescription
            } else {
                loadError = AppStrings.Errors.buildingsPrefix + error.localizedDescription
            }
        }

        switch await analyticsResult {
        case .success(let list):
            devices = list
            // Set default selections if none
            if selectedManufacturer == nil, let first = manufacturerOptions.first { selectedManufacturer = first }
            if selectedCategoryId == nil, let first = categoryOptions.first { selectedCategoryId = first }
            if selectedCountry == nil, let first = countryOptions.first { selectedCountry = first }
            if selectedState == nil, let first = stateOptions.first { selectedState = first }
            if selectedItemId == nil, let first = itemOptions.first { selectedItemId = first }
        case .failure(let error):
            if let apiError = error as? APIClientError, apiError == .noConnection {
                isOffline = true
                loadError = error.localizedDescription
            } else {
                if loadError != nil { loadError! += "\n" }
                loadError = (loadError ?? "") + AppStrings.Errors.analyticsPrefix + error.localizedDescription
            }
        }
    }
}
