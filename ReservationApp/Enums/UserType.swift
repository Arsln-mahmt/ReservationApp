//
//  UserType.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation

/// User type - Customer or Business owner
enum UserType: String, Codable, CaseIterable {
    case customer = "customer"  // Customer (makes reservations)
    case business = "business"  // Business (receives reservations)
    
    var displayName: String {
        switch self {
        case .customer:
            return "Müşteri"
        case .business:
            return "İşletme"
        }
    }
}
