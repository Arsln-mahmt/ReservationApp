//
//  ReservationStatus.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import SwiftUI

/// Reservation status
enum ReservationStatus: String, Codable, CaseIterable {
    case pending = "pending"        // Pending (not yet confirmed)
    case confirmed = "confirmed"    // Confirmed
    case completed = "completed"    // Completed
    case cancelled = "cancelled"    // Cancelled
    case noShow = "no_show"        // No show
    case blocked = "blocked"       // Blocked by business
    
    var displayName: String {
        switch self {
        case .pending:
            return "Beklemede"
        case .confirmed:
            return "Onaylandı"
        case .completed:
            return "Tamamlandı"
        case .cancelled:
            return "İptal Edildi"
        case .noShow:
            return "Gelmedi"
        case .blocked:
            return "Kapalı"
        }
    }
    
    var color: Color {
        switch self {
        case .pending:
            return .orange
        case .confirmed:
            return .blue
        case .completed:
            return .green
        case .cancelled:
            return .red
        case .noShow:
            return .gray
        case .blocked:
            return .red.opacity(0.8)
        }
    }
}
