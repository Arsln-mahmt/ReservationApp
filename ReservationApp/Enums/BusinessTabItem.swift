//
//  BusinessTabItem.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

enum BusinessTabItem: Int, CaseIterable {
    case appointments = 0
    case dashboard = 1
    case settings = 2
    
    var title: String {
        switch self {
        case .appointments:
            return "Randevular"
        case .dashboard:
            return "Ana Sayfa"
        case .settings:
            return "Ayarlar"
        }
    }
    
    var icon: String {
        switch self {
        case .appointments:
            return "calendar"
        case .dashboard:
            return "chart.bar.fill"
        case .settings:
            return "gearshape.fill"
        }
    }
}











