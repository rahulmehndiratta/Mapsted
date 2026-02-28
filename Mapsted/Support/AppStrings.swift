//
//  AppStrings.swift
//  Mapsted
//
//  Created by RahulM on 28/02/26.
//

import Foundation

enum AppStrings {
    enum General {
        static let appTitle = "Analytics Dashboard"
        static let unknownBuilding = "—"
        static let somethingWentWrong = "Something went wrong."
        static let retry = "Retry"
        static let loading = "Loading…"
        static let close = "Close"
    }

    enum Header {
        static let testCaseTitle = "Mapsted Test case #8"
        static let authorName = "Rahul"
        static let date = "28-Feb-2026"
    }

    enum Sections {
        static let purchaseCosts = "Purchase Costs"
        static let purchaseCostsByLocation = "Purchase Costs by Location"
        static let numberOfPurchases = "Number of Purchases"
        static let mostTotalPurchases = "Most Total Purchases"
    }

    enum Fields {
        static let manufacturer = "Manufacturer"
        static let category = "Category"
        static let country = "Country"
        static let stateProvince = "State / Province"
        static let item = "Item"
        static let mostTotalPurchases = "Most Total Purchases"
        static let building = "Building"
        static let total = "Total"
        static let purchases = "Purchases"
        static let name = "Name"
    }

    enum Placeholders {
        static let selectManufacturer = "manufacturer"
        static let selectCategory = "Select category"
        static let selectCountry = "Select country"
        static let selectState = "Select state"
        static let selectItem = "Select item"
    }

    enum Sheets {
        static let selectManufacturerTitle = "Select Manufacturer"
        static let selectCategoryTitle = "Select Category"
        static let selectCountryTitle = "Select Country"
        static let selectStateTitle = "Select State / Province"
        static let selectItemTitle = "Select Item"
    }

    enum Errors {
        static let unexpectedResponse = "Unexpected server response."
        static let noConnection = "No internet connection. Please check your network and try again."
        static let buildingsPrefix = "Buildings: "
        static let analyticsPrefix = "Analytics: "
    }
}

