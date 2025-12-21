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
    @Published var availableTimeSlots: [String] = []
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
        print("⏱️ Service duration: \(service.duration) minutes")
        print("🏢 Business ID: \(business.businessId)")
        
        isLoadingSlots = true
        selectedTimeSlot = nil
        
        reservationManager.getAvailableTimeSlots(
            businessId: business.businessId,
            date: selectedDate,
            duration: service.duration
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingSlots = false
                
                switch result {
                case .success(let slots):
                    if slots.isEmpty {
                        print("⚠️ No slots returned from manager, generating manually!")
                        self?.generateManualSlots()
                    } else {
                        self?.availableTimeSlots = slots
                        print("✅ Found \(slots.count) available time slots")
                        print("📝 First 5: \(slots.prefix(5).joined(separator: ", "))")
                    }
                    
                case .failure(let error):
                    print("❌ Failed to load time slots: \(error.localizedDescription)")
                    print("⚠️ Generating manual slots as fallback")
                    self?.generateManualSlots()
                }
            }
        }
    }
    
    private func generateManualSlots() {
        // Generate manual time slots as absolute fallback
        availableTimeSlots = [
            "09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
            "12:00", "12:30", "13:00", "13:30", "14:00", "14:30",
            "15:00", "15:30", "16:00", "16:30", "17:00", "17:30"
        ]
        print("✅ Generated \(availableTimeSlots.count) manual time slots")
        print("📝 Slots: \(availableTimeSlots)")
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



