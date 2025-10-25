//
//  TimeSlotRecommendation.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation

/// AI time slot recommendation
struct TimeSlotRecommendation: Codable, Identifiable {
    var id: String = UUID().uuidString
    var timeSlot: String        // Recommended time (e.g., "14:00")
    var date: Date              // Date
    var confidence: Double      // Confidence score (0-1)
    var workloadScore: Double   // Workload score
    var reason: String          // Recommendation reason
    var isOptimal: Bool         // Is optimal?
}

/// AI recommendation response
struct AIRecommendationResponse: Codable {
    var recommendations: [TimeSlotRecommendation]
    var metadata: RecommendationMetadata
}

/// Recommendation metadata
struct RecommendationMetadata: Codable {
    var businessId: String
    var analysisDate: Date
    var totalSlotsAnalyzed: Int
}

/// Workload prediction
struct WorkloadPrediction: Codable {
    var businessId: String
    var predictions: [DailyWorkload]
    var averageWorkload: Double         // Average reservations per day
    var peakHours: [String]             // Peak hours
}

/// Daily workload
struct DailyWorkload: Codable, Identifiable {
    var id: String = UUID().uuidString
    var date: Date
    var predictedReservations: Int      // Predicted number of reservations
    var workloadLevel: WorkloadLevel   // Workload level
    var hourlyDistribution: [String: Int] // Hourly distribution
}

/// Reservation analytics
struct ReservationAnalytics: Codable {
    var businessId: String
    var totalReservations: Int          // Total reservations
    var completionRate: Double          // Completion rate
    var cancellationRate: Double        // Cancellation rate
    var peakDays: [String]              // Peak days
    var peakHours: [String]             // Peak hours
    var popularServices: [String]       // Popular services
    var customerRetentionRate: Double   // Customer retention rate
}
