//
//  Reservation.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import FirebaseFirestore

/// Reservation model
struct Reservation: Codable, Identifiable {
    @DocumentID var id: String?
    var customerId: String          // Customer ID (User.uid)
    var customerName: String        // Customer name
    var customerPhone: String?      // Customer phone
    var businessId: String          // Business ID (User.uid)
    var businessName: String        // Business name
    var serviceType: String         // Service type (Haircut, Checkup, etc.)
    var date: Timestamp            // Reservation date
    var timeSlot: String           // Time slot (e.g., "14:00")
    var duration: Int              // Duration (minutes)
    var status: ReservationStatus  // Status (pending, confirmed, etc.)
    var notes: String?             // Notes
    var createdAt: Timestamp       // Creation date
    var updatedAt: Timestamp?      // Update date
    var aiRecommended: Bool?       // Recommended by AI?
}
