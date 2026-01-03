//
//  MyReservationsViewModel.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import Combine
import FirebaseFirestore

class MyReservationsViewModel: ObservableObject {
    @Published var reservations: [Reservation] = []
    @Published var isLoading = false
    
    private let reservationManager = ReservationManager.shared
    private let authManager = AuthManager.shared
    private let voiceService = VoiceServiceManager.shared
    
    func loadReservations(customerId: String) {
        print("\n" + String(repeating: "🔄", count: 25))
        print("🔄 VIEWMODEL: LOADING RESERVATIONS FROM FIREBASE")
        print(String(repeating: "🔄", count: 25))
        print("Customer ID: \(customerId)")
        print("Is Loading: \(isLoading)")
        print("Current reservations count: \(reservations.count)")
        print(String(repeating: "🔄", count: 25) + "\n")
        
        isLoading = true
        
        // Fetch from Firebase directly
        reservationManager.getCustomerReservations(customerId: customerId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let reservations):
                    print("\n" + String(repeating: "✅", count: 25))
                    print("🎉 VIEWMODEL: RESERVATIONS LOADED FROM FIREBASE!")
                    print("   Count: \(reservations.count)")
                    
                    if reservations.isEmpty {
                        print("   ⚠️ Array is EMPTY - No reservations for customer: \(customerId)")
                    } else {
                        print("   📋 Reservations received:")
                        reservations.prefix(3).enumerated().forEach { index, reservation in
                            var statusIcon: String
                            switch reservation.status {
                            case .pending: statusIcon = "⏳"
                            case .confirmed: statusIcon = "✅"
                            case .completed: statusIcon = "✔️"
                            case .noShow: statusIcon = "👻"
                            case .cancelled: statusIcon = "❌"
                            case .blocked: statusIcon = "⛔"
                            }
                            print("      \(index + 1). \(statusIcon) [\(reservation.status.rawValue)] \(reservation.displayBusinessName): \(reservation.serviceType)")
                            print("         Created: \(reservation.createdAt.dateValue())")
                            print("         Appointment: \(reservation.date.dateValue()) at \(reservation.timeSlot)")
                        }
                        if reservations.count > 3 {
                            print("      ... and \(reservations.count - 3) more")
                        }
                    }
                    print(String(repeating: "✅", count: 25) + "\n")
                    
                    // Filter out blocked reservations (they are internal business slots, not customer bookings)
                    self?.reservations = reservations.filter { $0.status != .blocked }
                    print("📝 ViewModel reservations array updated. New count: \(self?.reservations.count ?? 0)")
                    
                case .failure(let error):
                    print("\n" + String(repeating: "❌", count: 25))
                    print("💥 VIEWMODEL: FAILED TO LOAD RESERVATIONS!")
                    print("   Error: \(error.localizedDescription)")
                    print("   Customer ID: \(customerId)")
                    print(String(repeating: "❌", count: 25) + "\n")
                    self?.reservations = []
                }
            }
        }
    }
    
    func cancelReservation(reservation: Reservation) {
        guard let reservationId = reservation.id else {
            print("❌ Cannot cancel: Reservation has no ID")
            return
        }
        
        print("🔄 Cancelling reservation: \(reservationId)")
        
        reservationManager.cancelReservation(reservationId: reservationId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Reservation cancelled successfully")
                    // Reload reservations to update UI
                    if let customerId = self?.authManager.currentUser?.uid {
                        self?.loadReservations(customerId: customerId)
                    }
                    
                case .failure(let error):
                    print("❌ Failed to cancel reservation: \(error)")
                }
            }
        }
    }
}



