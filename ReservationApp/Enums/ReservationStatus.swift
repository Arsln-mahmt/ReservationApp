//
//  ReservationStatus.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import SwiftUI

/// Rezervasyon durumu
enum ReservationStatus: String, Codable, CaseIterable {
    case pending = "pending"        // Beklemede (henüz onaylanmadı)
    case confirmed = "confirmed"    // Onaylandı
    case completed = "completed"    // Tamamlandı
    case cancelled = "cancelled"    // İptal edildi
    case noShow = "no_show"        // Gelmedi
    
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
        }
    }
}
