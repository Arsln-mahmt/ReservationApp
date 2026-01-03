//
//  Colors.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI
import Combine

extension Color {
    // MARK: - Primary Colors (Orange Theme)
    static let primaryOrange = Color(hex: "#FF6B35")        // Main orange
    static let primaryOrangeDark = Color(hex: "#E55A2B")    // Darker orange
    static let primaryOrangeLight = Color(hex: "#FF8C61")   // Light orange
    
    // MARK: - Secondary Colors
    static let secondaryNavy = Color(hex: "#1A2332")        // Dark navy blue
    static let secondaryBlue = Color(hex: "#2C3E50")        // Medium blue
    static let accentYellow = Color(hex: "#FFA726")         // Accent yellow-orange
    
    // MARK: - Background Colors
    static let bgPrimary = Color(hex: "#FFF8F3")            // Warm cream - turuncu ile uyumlu
    static let bgSecondary = Color(hex: "#FFF5ED")          // Lighter warm tone
    static let bgCard = Color(hex: "#FFFFFF")               // Card background (white)
    static let bgLight = Color(hex: "#FFF5ED")              // Lighter warm tone
    
    // MARK: - Text Colors
    static let textPrimary = Color(hex: "#1A2332")          // Dark text
    static let textSecondary = Color(hex: "#6C757D")        // Gray text
    static let textLight = Color(hex: "#ADB5BD")            // Light gray text
    
    // MARK: - Status Colors
    static let successGreen = Color(hex: "#28A745")         // Success
    static let errorRed = Color(hex: "#DC3545")             // Error
    static let warningOrange = Color(hex: "#FFC107")        // Warning
    static let infoBlue = Color(hex: "#17A2B8")             // Info
    
    // MARK: - Gradient Colors
    static let gradientStart = Color(hex: "#FF6B35")
    static let gradientEnd = Color(hex: "#FFA726")
    
    static let gradientDarkStart = Color(hex: "#1A2332")
    static let gradientDarkEnd = Color(hex: "#2C3E50")
    
    // MARK: - Helper to create Color from HEX
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
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradient Presets
extension LinearGradient {
    static let primaryGradient = LinearGradient(
        colors: [Color.gradientStart, Color.gradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let darkGradient = LinearGradient(
        colors: [Color.gradientDarkStart, Color.gradientDarkEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        colors: [Color.white, Color.bgSecondary],
        startPoint: .top,
        endPoint: .bottom
    )
}
