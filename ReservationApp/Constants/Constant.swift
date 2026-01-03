//
//  Constant.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation

struct Constant {
    // MARK: - App Info
    static let appName = "ReservationApp"
    static let appVersion = "0.1.0"
    
    // MARK: - Firebase Collections
    static let usersCollection = "users"
    static let businessesCollection = "businesses"
    static let reservationsCollection = "reservations"
    static let servicesCollection = "services"
    static let reviewsCollection = "reviews"
    
    // MARK: - API URLs (AI service)
    static let aiAPIURL = "https://your-ai-api.com/api/v1" // Replace with your FastAPI endpoint
    
    // MARK: - Reservation Settings
    static let defaultReservationDuration = 60 // minutes
    static let timeSlotInterval = 30 // minutes
    static let defaultStartHour = 9 // 9 AM
    static let defaultEndHour = 18 // 6 PM
    static let maxAdvanceBookingDays = 30
    static let minAdvanceBookingHours = 1
}
