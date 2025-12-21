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
    // Stats
    @Published var todayAppointments: Int = 0
    @Published var monthlyAppointments: Int = 0
    @Published var totalCustomers: Int = 0
    @Published var averageRating: Double = 0.0
    
    // Business Info
    @Published var businessName: String = ""
    @Published var businessCategory: String = ""
    @Published var isLoading = false
    
    // Availability
    @Published var selectedDate = Date()
    @Published var availabilitySlots: [TimeSlot] = []
    @Published var isSlotLoading = false
    
    private let reservationManager = ReservationManager.shared
    private let authManager = AuthManager.shared
    private var allReservations: [Reservation] = [] // Cache
    
    init() {
        loadStats()
        loadBusinessDetails()
        loadAvailability()
    }
    
    func loadBusinessDetails() {
        guard let businessId = authManager.currentUser?.uid else { return }
        
        Firestore.firestore().collection("businesses")
            .whereField("businessId", isEqualTo: businessId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self, let doc = snapshot?.documents.first else { return }
                
                let data = doc.data()
                DispatchQueue.main.async {
                    self.businessName = data["name"] as? String ?? ""
                    self.businessCategory = data["category"] as? String ?? ""
                }
            }
    }
    
    func loadStats() {
        guard let businessId = authManager.currentUser?.uid else { return }
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
    
    func loadAvailability() {
        guard let businessId = authManager.currentUser?.uid else { return }
        isSlotLoading = true
        
        // Get both reservations and blocked slots
        let group = DispatchGroup()
        var fetchedReservations: [Reservation] = []
        var fetchedBlockedSlots: [BlockedSlot] = []
        
        // Fetch reservations
        group.enter()
        reservationManager.getBusinessReservations(businessId: businessId) { result in
            if case .success(let reservations) = result {
                fetchedReservations = reservations
            }
            group.leave()
        }
        
        // Fetch blocked slots
        group.enter()
        BlockedSlotManager.shared.getBlockedSlots(businessId: businessId, date: selectedDate) { result in
            if case .success(let slots) = result {
                fetchedBlockedSlots = slots
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.isSlotLoading = false
            self?.allReservations = fetchedReservations
            self?.generateSlots(
                for: self?.selectedDate ?? Date(),
                reservations: fetchedReservations,
                blockedSlots: fetchedBlockedSlots
            )
        }
    }
    
    func generateSlots(for date: Date, reservations: [Reservation], blockedSlots: [BlockedSlot]) {
        let calendar = Calendar.current
        
        // Filter reservations for this day (only real bookings, not blocked)
        let daysReservations = reservations.filter { res in
            return calendar.isDate(res.date.dateValue(), inSameDayAs: date) &&
                   res.status != .cancelled && res.status != .noShow && res.status != .blocked
        }
        
        // Create a set of blocked times for quick lookup
        let blockedTimes = Set(blockedSlots.map { $0.time })
        let blockedTimeToId = Dictionary(uniqueKeysWithValues: blockedSlots.map { ($0.time, $0.id) })
        
        // Generate slots 09:00 - 22:00
        var slots: [TimeSlot] = []
        let startHour = 9
        let endHour = 22
        
        for hour in startHour..<endHour {
            for minute in [0, 30] {
                let timeString = String(format: "%02d:%02d", hour, minute)
                
                // Check status
                var status: SlotStatus = .free
                var slotId: String? = nil
                
                // First check if blocked
                if blockedTimes.contains(timeString) {
                    status = .blocked
                    slotId = blockedTimeToId[timeString]
                }
                // Then check if booked
                else if daysReservations.contains(where: { $0.timeSlot == timeString }) {
                    status = .booked
                }
                
                slots.append(TimeSlot(time: timeString, status: status, reservationId: slotId))
            }
        }
        
        self.availabilitySlots = slots
    }
    
    func toggleSlot(slot: TimeSlot) {
        guard let businessId = authManager.currentUser?.uid else { return }
        
        // 1. If booked -> Cannot toggle
        if slot.status == .booked { return }
        
        // 2. If blocked -> Unblock
        if slot.status == .blocked, let slotId = slot.reservationId {
            isSlotLoading = true
            BlockedSlotManager.shared.unblockSlot(documentId: slotId) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isSlotLoading = false
                    switch result {
                    case .success:
                        self?.loadAvailability()
                    case .failure(let error):
                        print("❌ Error unblocking slot: \(error)")
                    }
                }
            }
            return
        }
        
        // 3. If free -> Block
        if slot.status == .free {
            isSlotLoading = true
            BlockedSlotManager.shared.blockSlot(
                businessId: businessId,
                date: selectedDate,
                time: slot.time
            ) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isSlotLoading = false
                    switch result {
                    case .success:
                        self?.loadAvailability()
                    case .failure(let error):
                        print("❌ Error blocking slot: \(error)")
                    }
                }
            }
        }
    }
    
    private func calculateStats(from reservations: [Reservation]) {
        let today = Calendar.current.startOfDay(for: Date())
        let calendar = Calendar.current
        
        todayAppointments = reservations.filter { reservation in
            calendar.isDate(reservation.date.dateValue(), inSameDayAs: today)
        }.count
        
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        monthlyAppointments = reservations.filter { reservation in
            reservation.date.dateValue() >= startOfMonth
        }.count
        
        let uniqueCustomerIds = Set(reservations.map { $0.customerId })
        totalCustomers = uniqueCustomerIds.count
        
        averageRating = 4.5
        
        print("✅ Stats loaded: Today=\(todayAppointments), Month=\(monthlyAppointments), Customers=\(totalCustomers)")
    }
}

// MARK: - Models
struct TimeSlot: Identifiable {
    let id = UUID()
    let time: String
    var status: SlotStatus
    var reservationId: String?
}

enum SlotStatus {
    case free
    case booked
    case blocked
}



