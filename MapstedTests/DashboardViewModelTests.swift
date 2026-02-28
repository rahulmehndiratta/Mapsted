//
//  DashboardViewModelTests.swift
//  Mapsted
//
//  Created by RahulM on 28/02/26.
//

import Foundation
import Testing
@testable import Mapsted

final class MockAPIClient: APIClientProtocol {
    private let buildingResult: APIResult<[BuildingInfo]>
    private let analyticsResult: APIResult<[DeviceUsage]>

    init(
        buildingResult: APIResult<[BuildingInfo]>,
        analyticsResult: APIResult<[DeviceUsage]>
    ) {
        self.buildingResult = buildingResult
        self.analyticsResult = analyticsResult
    }

    func fetchBuildingData() async -> APIResult<[BuildingInfo]> {
        buildingResult
    }

    func fetchAnalyticsData() async -> APIResult<[DeviceUsage]> {
        analyticsResult
    }
}

struct DashboardViewModelTests {

    // MARK: - Fixtures

    private func makeBuildings() -> [BuildingInfo] {
        [
            BuildingInfo(buildingId: 1, buildingName: "Building A", city: "San Jose", state: "CA", country: "USA"),
            BuildingInfo(buildingId: 2, buildingName: "Building B", city: "New York", state: "NY", country: "USA"),
            BuildingInfo(buildingId: 3, buildingName: "Building C", city: "Toronto", state: "ON", country: "Canada")
        ]
    }

    private func makeDevices() -> [DeviceUsage] {
        let apple = DeviceUsage(
            manufacturer: "Apple",
            marketName: nil,
            codename: nil,
            model: nil,
            usageStatistics: UsageStatistics(sessionInfos: [
                SessionInfo(buildingId: 1, purchases: [
                    Purchase(itemId: 100, itemCategoryId: 10, cost: 2),
                    Purchase(itemId: 200, itemCategoryId: 20, cost: 3)
                ]),
                SessionInfo(buildingId: 2, purchases: [
                    Purchase(itemId: 100, itemCategoryId: 10, cost: 5),
                    Purchase(itemId: 200, itemCategoryId: 20, cost: 1)
                ])
            ])
        )

        let samsung = DeviceUsage(
            manufacturer: "Samsung",
            marketName: nil,
            codename: nil,
            model: nil,
            usageStatistics: UsageStatistics(sessionInfos: [
                SessionInfo(buildingId: 3, purchases: [
                    Purchase(itemId: 100, itemCategoryId: 10, cost: 7)
                ])
            ])
        )

        return [samsung, apple] // intentionally unsorted to verify sorting
    }

    // MARK: - Tests

    @Test @MainActor
    func loadData_success_setsDataAndDefaultSelections() async {
        let client = MockAPIClient(
            buildingResult: .success(makeBuildings()),
            analyticsResult: .success(makeDevices())
        )
        let vm = DashboardViewModel(apiClient: client)

        await vm.loadData()

        #expect(vm.isLoading == false)
        #expect(vm.isOffline == false)
        #expect(vm.loadError == nil)
        #expect(vm.buildings.count == 3)
        #expect(vm.devices.count == 2)

        // Defaults should be set (first item from sorted options)
        #expect(vm.selectedManufacturer == vm.manufacturerOptions.first)
        #expect(vm.selectedCategoryId == vm.categoryOptions.first)
        #expect(vm.selectedCountry == vm.countryOptions.first)
        #expect(vm.selectedState == vm.stateOptions.first)
        #expect(vm.selectedItemId == vm.itemOptions.first)
    }

    @Test @MainActor
    func options_areUniqueAndSorted() async {
        let client = MockAPIClient(
            buildingResult: .success(makeBuildings()),
            analyticsResult: .success(makeDevices())
        )
        let vm = DashboardViewModel(apiClient: client)
        await vm.loadData()

        #expect(vm.manufacturerOptions == ["Apple", "Samsung"])
        #expect(vm.countryOptions == ["Canada", "USA"])
        #expect(vm.stateOptions == ["CA", "NY", "ON"])
        #expect(vm.categoryOptions == [10, 20])
        #expect(vm.itemOptions == [100, 200])
    }

    @Test @MainActor
    func computedValues_matchExpectedTotals() async {
        let client = MockAPIClient(
            buildingResult: .success(makeBuildings()),
            analyticsResult: .success(makeDevices())
        )
        let vm = DashboardViewModel(apiClient: client)
        await vm.loadData()

        vm.selectedManufacturer = "Apple"
        vm.selectedCategoryId = 10
        vm.selectedCountry = "USA"
        vm.selectedState = "CA"
        vm.selectedItemId = 100

        #expect(abs(vm.manufacturerTotal - 11) < 0.0001)
        #expect(abs(vm.categoryTotal - 14) < 0.0001)
        #expect(abs(vm.countryTotal - 11) < 0.0001)
        #expect(abs(vm.stateTotal - 5) < 0.0001)
        #expect(vm.itemPurchaseCount == 3)
        #expect(vm.buildingWithMostTotalPurchasesName == "Building C") 
    }

    @Test @MainActor
    func buildingWithMostTotalPurchases_returnsUnknownWhenBuildingMissing() async {
        let devices = [
            DeviceUsage(
                manufacturer: "Apple",
                marketName: nil,
                codename: nil,
                model: nil,
                usageStatistics: UsageStatistics(sessionInfos: [
                    SessionInfo(buildingId: 999, purchases: [
                        Purchase(itemId: 1, itemCategoryId: 1, cost: 10)
                    ])
                ])
            )
        ]

        let client = MockAPIClient(
            buildingResult: .success([]),
            analyticsResult: .success(devices)
        )
        let vm = DashboardViewModel(apiClient: client)
        await vm.loadData()

        #expect(vm.buildingWithMostTotalPurchasesName == AppStrings.General.unknownBuilding)
    }

    @Test @MainActor
    func loadData_buildingsFailure_setsBuildingsPrefixedError_andStillLoadsAnalytics() async {
        let client = MockAPIClient(
            buildingResult: .failure(NSError(domain: "test", code: 1)),
            analyticsResult: .success(makeDevices())
        )
        let vm = DashboardViewModel(apiClient: client)

        await vm.loadData()

        #expect(vm.isOffline == false)
        #expect(vm.devices.count == 2)
        #expect(vm.selectedManufacturer != nil) // still defaulted from analytics
        #expect((vm.loadError ?? "").hasPrefix(AppStrings.Errors.buildingsPrefix))
    }

    @Test @MainActor
    func loadData_bothFailure_combinesErrorsWithPrefixes() async {
        let client = MockAPIClient(
            buildingResult: .failure(NSError(domain: "test", code: 1)),
            analyticsResult: .failure(NSError(domain: "test", code: 2))
        )
        let vm = DashboardViewModel(apiClient: client)

        await vm.loadData()

        let error = vm.loadError ?? ""
        #expect(error.contains(AppStrings.Errors.buildingsPrefix))
        #expect(error.contains(AppStrings.Errors.analyticsPrefix))
        #expect(error.contains("\n"))
    }

    @Test @MainActor
    func loadData_noConnection_setsOfflineAndShowsNoConnectionMessage() async {
        let client = MockAPIClient(
            buildingResult: .failure(APIClientError.noConnection),
            analyticsResult: .failure(APIClientError.noConnection)
        )
        let vm = DashboardViewModel(apiClient: client)

        await vm.loadData()

        #expect(vm.isOffline == true)
        #expect(vm.loadError == AppStrings.Errors.noConnection)
    }
}

