//
//  TabItem.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

enum TabItem: Int, CaseIterable {
    case reservations = 0
    case home = 1
    case profile = 2
    
    var title: String {
        switch self {
        case .reservations:
            return "Rezervasyonlar"
        case .home:
            return "Ana Sayfa"
        case .profile:
            return "Profil"
        }
    }
    
    var icon: String {
        switch self {
        case .reservations:
            return "calendar"
        case .home:
            return "house.fill"
        case .profile:
            return "person.fill"
        }
    }
}











