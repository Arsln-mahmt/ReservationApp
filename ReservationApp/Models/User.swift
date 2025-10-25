//
//  User.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import FirebaseFirestore

/// User model (Customer or Business)
struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var uid: String                    // Firebase Auth UID
    var email: String                  // Email
    var name: String                   // Full name
    var phoneNumber: String?           // Phone number
    var phoneVerified: Bool?           // Phone verification status (true if verified)
    var userType: UserType            // Customer or Business
    var profileImageURL: String?       // Profile image URL
    var createdAt: Timestamp          // Creation date
    var updatedAt: Timestamp?         // Update date
    
    // Business-specific fields (only filled if userType = business)
    var businessName: String?          // Business name
    var businessAddress: String?       // Business address
    var businessCategory: String?      // Category (Salon, Clinic, etc.)
    var businessDescription: String?   // Business description
    var workingHours: [String: WorkingHours]?  // Working hours
}

/// Working hours model
struct WorkingHours: Codable {
    var isOpen: Bool        // Is open or closed
    var openTime: String    // Opening time (e.g., "09:00")
    var closeTime: String   // Closing time (e.g., "18:00")
}
