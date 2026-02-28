//
//  AppConstants.swift
//  Mapsted
//
//  Created by RahulM on 28/02/26.
//

import Foundation
import CoreGraphics

enum AppConstants {
    enum Layout {
        /// Fixed width for selection dropdown buttons so all rows match.
        static let selectionButtonWidth: CGFloat = 140
        /// Section header height (px).
        static let sectionHeaderHeight: CGFloat = 45
        /// Space between left label and button.
        static let rowLabelToButtonSpacing: CGFloat = 8
        /// Space between button and right value.
        static let rowButtonToValueSpacing: CGFloat = 4
        /// List's default horizontal inset; use negative to cancel for section headers.
        static let listSectionHorizontalInset: CGFloat = 16
    }

    enum Network {
        static let baseURL = URL(string: "http://rnd-interview.mapsted.com/")!
        static let buildingEndpoint = "GetBuildingData/"
        static let analyticsEndpoint = "GetAnalyticData/"
    }

    enum Formatting {
        static let currencyCode = "USD"
        static let maxFractionDigits = 2
        static let minFractionDigits = 2
    }
}
