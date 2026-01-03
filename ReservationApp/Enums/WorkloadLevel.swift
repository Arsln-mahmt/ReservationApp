//
//  WorkloadLevel.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import SwiftUI

/// Workload level (for AI prediction)
enum WorkloadLevel: String, Codable {
    case low = "low"            // Low
    case medium = "medium"      // Medium
    case high = "high"          // High
    case veryHigh = "very_high" // Very high
    
    var displayName: String {
        switch self {
        case .low:
            return "Düşük"
        case .medium:
            return "Orta"
        case .high:
            return "Yoğun"
        case .veryHigh:
            return "Çok Yoğun"
        }
    }
    
    var color: Color {
        switch self {
        case .low:
            return .green
        case .medium:
            return .yellow
        case .high:
            return .orange
        case .veryHigh:
            return .red
        }
    }
    
    var emoji: String {
        switch self {
        case .low:
            return "😊"
        case .medium:
            return "😐"
        case .high:
            return "😰"
        case .veryHigh:
            return "🔥"
        }
    }
}
