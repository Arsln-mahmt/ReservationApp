//
//  Business.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import FirebaseFirestore

/// Business detail model
struct Business: Codable, Identifiable {
    @DocumentID var id: String?
    var ownerId: String                    // Owner (User.uid)
    var name: String                       // Business name
    var category: String                   // Category (Salon, Clinic, Restaurant, etc.)
    var description: String                // Description
    var address: String                    // Address
    var phoneNumber: String                // Phone number
    var email: String                      // Email
    var imageURL: String?                  // Business image
    var workingHours: [String: WorkingHours] // Working hours
    var services: [Service]                // Offered services
    var rating: Double?                    // Average rating (out of 5)
    var totalReviews: Int?                 // Total number of reviews
    var createdAt: Timestamp              // Creation date
}

/// Service model
struct Service: Codable, Identifiable {
    @DocumentID var id: String?
    var businessId: String          // Business ID
    var name: String                // Service name (Haircut, Coloring, etc.)
    var description: String?        // Description
    var duration: Int               // Duration (minutes)
    var price: Double               // Price
    var isActive: Bool              // Is service active?
    var createdAt: Timestamp        // Creation date
    
    // For preview/testing
    static var sample: Service {
        Service(
            id: "1",
            businessId: "bus_1",
            name: "Saç Kesimi",
            description: "Profesyonel saç kesimi hizmeti",
            duration: 30,
            price: 150.0,
            isActive: true,
            createdAt: Timestamp()
        )
    }
}
