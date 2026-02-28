//
//  AppTheme.swift
//  Mapsted
//
//  Created by RahulM on 28/02/26.
//

import SwiftUI

enum AppTheme {
    /// Background: light blue #A4EBF5
    static let lightBlue = Color(hex: "A4EBF5")
    /// Background: light grey #F3F3F3
    static let lightGrey = Color(hex: "F3F3F3")
    /// Background/border: dark grey #CFD8DC
    static let darkGrey = Color(hex: "CFD8DC")
    /// Text: light grey #7B8D93
    static let textLightGrey = Color(hex: "7B8D93")
    /// Text: dark grey #43484A
    static let textDarkGrey = Color(hex: "43484A")
    /// white color
    static let white = Color(hex: "FFFFFF")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
