//
//  UserType.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation

/// Kullanıcı tipi - Müşteri veya İşletme
enum UserType: String, Codable, CaseIterable {
    case customer = "customer"  // Müşteri (rezervasyon yapan)
    case business = "business"  // İşletme (rezervasyon alan)
    
    var displayName: String {
        switch self {
        case .customer:
            return "Müşteri"
        case .business:
            return "İşletme"
        }
    }
}
