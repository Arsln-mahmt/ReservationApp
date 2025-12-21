//
//  BusinessOverviewViewModel.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import Combine
import FirebaseFirestore

class BusinessOverviewViewModel: ObservableObject {
    @Published var todayAppointments: Int = 0
    @Published var monthlyAppointments: Int = 0
    @Published var totalCustomers: Int = 0
    @Published var averageRating: Double = 0.0
    @Published var isLoading = false
    
    private let reservationManager = ReservationManager.shared
    private let authManager = AuthManager.shared
    
    init() {
        loadStats()
    }
    
    func loadStats() {
        guard let businessId = authManager.currentUser?.uid else {
            print("❌ No business user logged in")
            return
        }
        
        isLoading = true
        
        reservationManager.getBusinessReservations(businessId: businessId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let reservations):
                    self?.calculateStats(from: reservations)
                    
                case .failure(let error):
                    print("❌ Failed to load stats: \(error)")
                }
            }
        }
    }
    
    private func calculateStats(from reservations: [Reservation]) {
        let today = Calendar.current.startOfDay(for: Date())
        let calendar = Calendar.current
        
        // Today's appointments
        todayAppointments = reservations.filter { reservation in
            calendar.isDate(reservation.date.dateValue(), inSameDayAs: today)
        }.count
        
        // Monthly appointments
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        monthlyAppointments = reservations.filter { reservation in
            reservation.date.dateValue() >= startOfMonth
        }.count
        
        // Total unique customers
        let uniqueCustomerIds = Set(reservations.map { $0.customerId })
        totalCustomers = uniqueCustomerIds.count
        
        // Average rating (placeholder - would need reviews collection)
        averageRating = 4.5 // TODO: Calculate from reviews
        
        print("✅ Stats loaded: Today=\(todayAppointments), Month=\(monthlyAppointments), Customers=\(totalCustomers)")
    }
}



