//
//  AppEnvironment.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import Combine

class AppEnvironment: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var userType: UserType = .customer
    
    static let shared = AppEnvironment()
    
    private init() {}
}
