//
//  BusinessNotification.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 23.12.2025.
//

import Foundation
import FirebaseFirestore

/// Business notification types
enum BusinessNotificationType: String, Codable {
    case newReservation = "new_reservation"
    case cancelledReservation = "cancelled_reservation"
    case updatedReservation = "updated_reservation"
    case customerMessage = "customer_message"
    case systemAlert = "system_alert"
    
    var icon: String {
        switch self {
        case .newReservation: return "calendar.badge.plus"
        case .cancelledReservation: return "calendar.badge.minus"
        case .updatedReservation: return "calendar.badge.clock"
        case .customerMessage: return "message.fill"
        case .systemAlert: return "bell.fill"
        }
    }
    
    var color: String {
        switch self {
        case .newReservation: return "green"
        case .cancelledReservation: return "red"
        case .updatedReservation: return "orange"
        case .customerMessage: return "blue"
        case .systemAlert: return "purple"
        }
    }
    
    var title: String {
        switch self {
        case .newReservation: return "Yeni Randevu"
        case .cancelledReservation: return "İptal Edilen Randevu"
        case .updatedReservation: return "Güncellenen Randevu"
        case .customerMessage: return "Müşteri Mesajı"
        case .systemAlert: return "Sistem Bildirimi"
        }
    }
}

/// Business notification model
struct BusinessNotification: Codable, Identifiable {
    @DocumentID var id: String?
    var businessId: String              // Business user ID
    var type: BusinessNotificationType  // Notification type
    var title: String                   // Notification title
    var message: String                 // Notification message
    var reservationId: String?          // Related reservation ID (optional)
    var customerId: String?             // Related customer ID (optional)
    var customerName: String?           // Customer name for display
    var serviceName: String?            // Service name
    var appointmentDate: String?        // Appointment date string
    var appointmentTime: String?        // Appointment time string
    var isRead: Bool                    // Read status
    var createdAt: Timestamp            // Creation date
    
    enum CodingKeys: String, CodingKey {
        case id
        case businessId = "business_id"
        case type
        case title
        case message
        case reservationId = "reservation_id"
        case customerId = "customer_id"
        case customerName = "customer_name"
        case serviceName = "service_name"
        case appointmentDate = "appointment_date"
        case appointmentTime = "appointment_time"
        case isRead = "is_read"
        case createdAt = "created_at"
    }
    
    // Computed property for relative time display
    var relativeTime: String {
        let now = Date()
        let created = createdAt.dateValue()
        let interval = now.timeIntervalSince(created)
        
        if interval < 60 {
            return "Az önce"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) dakika önce"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) saat önce"
        } else if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days) gün önce"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            formatter.locale = Locale(identifier: "tr_TR")
            return formatter.string(from: created)
        }
    }
    
    // Standard init
    init(
        id: String? = nil,
        businessId: String,
        type: BusinessNotificationType,
        title: String,
        message: String,
        reservationId: String? = nil,
        customerId: String? = nil,
        customerName: String? = nil,
        serviceName: String? = nil,
        appointmentDate: String? = nil,
        appointmentTime: String? = nil,
        isRead: Bool = false,
        createdAt: Timestamp = Timestamp()
    ) {
        self.id = id
        self.businessId = businessId
        self.type = type
        self.title = title
        self.message = message
        self.reservationId = reservationId
        self.customerId = customerId
        self.customerName = customerName
        self.serviceName = serviceName
        self.appointmentDate = appointmentDate
        self.appointmentTime = appointmentTime
        self.isRead = isRead
        self.createdAt = createdAt
    }
}
