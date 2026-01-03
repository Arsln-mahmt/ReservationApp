//
//  BookingViewModel.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import Combine

class BookingViewModel: ObservableObject {
    let business: BusinessListing
    let service: Service
    
    @Published var selectedDate = Date()
    @Published var selectedTimeSlot: String?
    @Published var availableTimeSlots: [BookingTimeSlot] = []
    @Published var notes = ""
    
    @Published var isLoadingSlots = false
    @Published var isCreating = false
    @Published var showSuccessAlert = false
    @Published var showErrorAlert = false
    @Published var errorMessage: String?
    
    private let reservationManager = ReservationManager.shared
    
    init(business: BusinessListing, service: Service) {
        self.business = business
        self.service = service
        loadAvailableTimeSlots()
    }
    
    func loadAvailableTimeSlots() {
        print("🔄 Loading time slots for \(business.name)")
        print("📅 Selected date: \(selectedDate)")
        
        isLoadingSlots = true
        selectedTimeSlot = nil
        
        // Use standard hours 09:00 - 22:00
        // We'll generate the full list manually here if Util is not accessible, 
        // to ensure we cover all hours even if ReservationManager logic differs
        var allPossibleSlots: [String] = []
        for hour in 9..<22 {
            for minute in [0, 30] {
                allPossibleSlots.append(String(format: "%02d:%02d", hour, minute))
            }
        }
        
        reservationManager.getAvailableTimeSlots(
            businessId: business.businessId,
            date: selectedDate,
            duration: service.duration
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingSlots = false
                
                switch result {
                case .success(let availableStrings):
                    // Map to model: If it's in the 'availableStrings' list, it is available.
                    // If NOT, it means it's booked/blocked/cancelled(maybe).
                    self?.availableTimeSlots = allPossibleSlots.map { time in
                        BookingTimeSlot(time: time, isAvailable: availableStrings.contains(time))
                    }
                    print("✅ Processed \(self?.availableTimeSlots.count ?? 0) slots (Total)")
                    
                case .failure(let error):
                    print("❌ Failed to load time slots: \(error.localizedDescription)")
                    self?.generateManualSlots()
                }
            }
        }
    }
    
    private func generateManualSlots() {
        // Fallback: All slots available
        var slots: [BookingTimeSlot] = []
        for hour in 9..<22 {
            for minute in [0, 30] {
                let time = String(format: "%02d:%02d", hour, minute)
                slots.append(BookingTimeSlot(time: time, isAvailable: true))
            }
        }
        availableTimeSlots = slots
        print("✅ Generated \(availableTimeSlots.count) manual slots")
    }
    
    func createReservation(customerId: String, customerName: String, customerPhone: String?) {
        print("\n🚀🚀🚀 CREATE RESERVATION CALLED")
        print("   isCreating: \(isCreating)")
        print("   selectedTimeSlot: \(selectedTimeSlot ?? "nil")")
        
        // CRITICAL CHECK 1: Already creating?
        if isCreating {
            print("⚠️ Already creating a reservation, ignoring duplicate call")
            return
        }
        
        // CRITICAL CHECK 2: Time slot selected?
        guard let timeSlot = selectedTimeSlot else {
            print("❌ ERROR: No time slot selected!")
            errorMessage = "Lütfen bir saat seçin"
            showErrorAlert = true
            return
        }
        
        // CRITICAL CHECK 3: Customer ID valid?
        if customerId.isEmpty {
            print("❌❌❌ CRITICAL ERROR: Customer ID is EMPTY!")
            errorMessage = "Kullanıcı bilgisi bulunamadı. Lütfen tekrar giriş yapın."
            showErrorAlert = true
            return
        }
        
        // Log everything
        print("\n" + String(repeating: "=", count: 50))
        print("🎯 CREATING RESERVATION - START")
        print(String(repeating: "=", count: 50))
        print("📋 Customer Info:")
        print("   ├─ Customer ID: \(customerId)")
        print("   ├─ Customer Name: \(customerName)")
        print("   └─ Customer Phone: \(customerPhone ?? "nil")")
        print("🏢 Business Info:")
        print("   ├─ Business ID: \(business.businessId)")
        print("   └─ Business Name: \(business.name)")
        print("💼 Service Info:")
        print("   ├─ Service: \(service.name)")
        print("   ├─ Duration: \(service.duration) min")
        print("   ├─ Date: \(selectedDate)")
        print("   └─ Time Slot: \(timeSlot)")
        print(String(repeating: "=", count: 50) + "\n")
        
        isCreating = true
        errorMessage = nil
        
        reservationManager.createReservation(
            customerId: customerId,
            customerName: customerName,
            customerPhone: customerPhone,
            businessId: business.businessId,
            businessName: business.name,
            serviceType: service.name,
            date: selectedDate,
            timeSlot: timeSlot,
            duration: service.duration,
            notes: notes.isEmpty ? nil : notes
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isCreating = false
                
                switch result {
                case .success(let reservationId):
                    print("\n" + String(repeating: "✅", count: 25))
                    print("🎉 RESERVATION CREATED SUCCESSFULLY!")
                    print("   Reservation ID: \(reservationId)")
                    print("   Customer ID: \(customerId)")
                    print(String(repeating: "✅", count: 25) + "\n")
                    
                    // Send notification to refresh reservations list
                    print("📢 Sending notification to refresh reservations...")
                    NotificationCenter.default.post(name: NSNotification.Name("RefreshReservations"), object: nil)
                    
                    self?.showSuccessAlert = true
                    
                case .failure(let error):
                    print("\n" + String(repeating: "❌", count: 25))
                    print("💥 FAILED TO CREATE RESERVATION!")
                    print("   Error: \(error.localizedDescription)")
                    print("   Full error: \(error)")
                    print(String(repeating: "❌", count: 25) + "\n")
                    self?.errorMessage = "Randevu oluşturulamadı: \(error.localizedDescription)"
                    self?.showErrorAlert = true
                }
            }
        }
    }
    
    // Reset function to clean up state
    func reset() {
        print("🔄 Resetting BookingViewModel state...")
        selectedDate = Date()
        selectedTimeSlot = nil
        notes = ""
        isCreating = false
        showSuccessAlert = false
        showErrorAlert = false
        errorMessage = nil
        availableTimeSlots = []
        print("✅ BookingViewModel reset complete")
    }
}

// MARK: - Models
struct BookingTimeSlot: Identifiable {
    let id = UUID()
    let time: String
    var isAvailable: Bool
}



