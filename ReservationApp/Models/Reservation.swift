//
//  Reservation.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import FirebaseFirestore

/// Reservation model - supports both Timestamp and String date formats
struct Reservation: Codable, Identifiable {
    @DocumentID var id: String?
    var customerId: String          // Customer ID (User.uid)
    var customerName: String?       // Customer name (optional for old data)
    var customerPhone: String?      // Customer phone
    var businessId: String          // Business ID (User.uid)
    var businessName: String?       // Business name (optional for old data)
    var serviceType: String         // Service type (Haircut, Checkup, etc.)
    var date: Timestamp            // Reservation date
    var timeSlot: String           // Time slot (e.g., "14:00")
    var duration: Int?             // Duration (minutes) - optional for old data
    var status: ReservationStatus  // Status (pending, confirmed, etc.)
    var notes: String?             // Notes
    var createdAt: Timestamp       // Creation date
    var updatedAt: Timestamp?      // Update date
    var aiRecommended: Bool?       // Recommended by AI?
    var proposedDate: Timestamp?   // Business proposed new date
    var proposedTimeSlot: String?  // Business proposed new time
    
    // Computed property for display
    var displayBusinessName: String {
        businessName ?? "İşletme"
    }
    
    var displayCustomerName: String {
        customerName ?? "Müşteri"
    }
    
    var displayDuration: Int {
        duration ?? 30
    }
    
    // Unique ID for ForEach - uses id if available, otherwise generates from other fields
    var uniqueID: String {
        id ?? "\(customerId)_\(businessId)_\(timeSlot)_\(date.dateValue().timeIntervalSince1970)"
    }
    
    // CodingKeys to map Firestore fields to Swift properties
    enum CodingKeys: String, CodingKey {
        case id
        case customerId = "user_id"           // Firestore uses user_id
        case customerName = "user_name"       // Firestore uses user_name
        case customerPhone = "user_phone"     // Firestore uses user_phone
        case businessId = "business_id"
        case businessName = "business_name"   // May not exist in old schema
        case serviceType = "service_name"     // Firestore uses service_name
        case date
        case timeSlot = "time"                // Firestore uses time
        case duration
        case status
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case aiRecommended = "ai_recommended"
        case proposedDate = "proposed_date"
        case proposedTimeSlot = "proposed_time_slot"
    }
    
    // Custom decoder to handle both Timestamp and String dates
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode standard fields
        id = try container.decodeIfPresent(String.self, forKey: .id)
        customerId = try container.decode(String.self, forKey: .customerId)
        customerName = try container.decodeIfPresent(String.self, forKey: .customerName)
        customerPhone = try container.decodeIfPresent(String.self, forKey: .customerPhone)
        businessId = try container.decode(String.self, forKey: .businessId)
        businessName = try container.decodeIfPresent(String.self, forKey: .businessName)
        serviceType = try container.decode(String.self, forKey: .serviceType)
        timeSlot = try container.decode(String.self, forKey: .timeSlot)
        duration = try container.decodeIfPresent(Int.self, forKey: .duration)
        status = try container.decode(ReservationStatus.self, forKey: .status)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        aiRecommended = try container.decodeIfPresent(Bool.self, forKey: .aiRecommended)
        proposedTimeSlot = try container.decodeIfPresent(String.self, forKey: .proposedTimeSlot)
        
        // Handle date - could be Timestamp or String
        if let timestamp = try? container.decode(Timestamp.self, forKey: .date) {
            date = timestamp
        } else if let dateString = try? container.decode(String.self, forKey: .date) {
            date = Reservation.parseDate(dateString)
        } else {
            date = Timestamp()
        }
        
        // Handle createdAt - could be Timestamp or String
        if let timestamp = try? container.decode(Timestamp.self, forKey: .createdAt) {
            createdAt = timestamp
        } else if let dateString = try? container.decode(String.self, forKey: .createdAt) {
            createdAt = Reservation.parseDate(dateString)
        } else {
            createdAt = Timestamp()
        }
        
        // Handle updatedAt - optional, could be Timestamp or String
        if let timestamp = try? container.decode(Timestamp.self, forKey: .updatedAt) {
            updatedAt = timestamp
        } else if let dateString = try? container.decodeIfPresent(String.self, forKey: .updatedAt) {
            updatedAt = Reservation.parseDate(dateString)
        } else {
            updatedAt = nil
        }
        
        // Handle proposedDate - optional, could be Timestamp or String
        if let timestamp = try? container.decode(Timestamp.self, forKey: .proposedDate) {
            proposedDate = timestamp
        } else if let dateString = try? container.decodeIfPresent(String.self, forKey: .proposedDate) {
            proposedDate = Reservation.parseDate(dateString)
        } else {
            proposedDate = nil
        }
    }
    
    // Helper to parse date strings
    private static func parseDate(_ dateString: String) -> Timestamp {
        let formatters: [DateFormatter] = [
            {
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                return f
            }(),
            {
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                return f
            }(),
            {
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-dd"
                return f
            }()
        ]
        
        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return Timestamp(date: date)
            }
        }
        
        return Timestamp()
    }
    
    // Standard init for creating new reservations
    init(
        id: String? = nil,
        customerId: String,
        customerName: String,
        customerPhone: String? = nil,
        businessId: String,
        businessName: String? = nil,
        serviceType: String,
        date: Timestamp,
        timeSlot: String,
        duration: Int? = nil,
        status: ReservationStatus,
        notes: String? = nil,
        createdAt: Timestamp,
        updatedAt: Timestamp? = nil,
        aiRecommended: Bool? = nil,
        proposedDate: Timestamp? = nil,
        proposedTimeSlot: String? = nil
    ) {
        self.id = id
        self.customerId = customerId
        self.customerName = customerName
        self.customerPhone = customerPhone
        self.businessId = businessId
        self.businessName = businessName
        self.serviceType = serviceType
        self.date = date
        self.timeSlot = timeSlot
        self.duration = duration
        self.status = status
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.aiRecommended = aiRecommended
        self.proposedDate = proposedDate
        self.proposedTimeSlot = proposedTimeSlot
    }
}
