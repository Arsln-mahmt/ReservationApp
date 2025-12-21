//
//  BusinessAppointmentsViewModel.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import FirebaseFirestore
import Combine

enum AppointmentFilter {
    case all
    case today
    case upcoming
    case completed
}

class BusinessAppointmentsViewModel: ObservableObject {
    @Published var appointments: [Reservation] = []
    @Published var selectedFilter: AppointmentFilter = .all
    @Published var isLoading = false
    
    private let reservationManager = ReservationManager.shared
    private let authManager = AuthManager.shared
    
    var filteredAppointments: [Reservation] {
        // Filter out blocked slots from the list view
        let baseList = appointments.filter { $0.status != .blocked }
        
        switch selectedFilter {
        case .all:
            return baseList
        case .today:
            return baseList.filter { Calendar.current.isDateInToday($0.date.dateValue()) }
        case .upcoming:
            return baseList.filter { $0.date.dateValue() > Date() && $0.status != .completed }
        case .completed:
            return baseList.filter { $0.status == .completed }
        }
    }
    
    init() {
        loadAppointments()
    }
    
    func loadAppointments() {
        guard let businessId = authManager.currentUser?.uid else {
            print("❌ No business user logged in")
            return
        }
        
        isLoading = true
        print("🔍 Loading appointments for business: \(businessId)")
        
        // Use Firebase directly instead of backend
        reservationManager.getBusinessReservations(businessId: businessId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let reservations):
                    self?.appointments = reservations
                    print("✅ Loaded \(reservations.count) appointments for business from Firebase")
                    
                case .failure(let error):
                    print("❌ Failed to load appointments: \(error)")
                    self?.appointments = []
                }
            }
        }
    }
}

