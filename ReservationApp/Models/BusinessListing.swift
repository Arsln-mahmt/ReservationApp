//
//  BusinessListing.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import FirebaseFirestore

/// Business listing model for home screen
struct BusinessListing: Codable, Identifiable {
    @DocumentID var id: String?
    var businessId: String           // Reference to User (business)
    var name: String                 // Business name
    var category: String             // Category (Salon, Clinic, etc.)
    var city: String                 // City name
    var address: String              // Full address
    var rating: Double?              // Average rating
    var reviewCount: Int?            // Number of reviews
    var imageURL: String?            // Cover image URL
    var description: String?         // Short description
    var priceRange: String?          // Price range (e.g., "$$", "$$$")
    var isOpen: Bool?                // Currently open or closed
    var distance: Double?            // Distance from user (km)
    
    // Google Places Integration
    var googlePlaceId: String?       // Google Places ID (if from Google)
    var isGoogleListing: Bool        // Is this from Google Places?
    var isClaimed: Bool              // Has business owner claimed this?
    var claimedBy: String?           // User ID who claimed
    var hasActiveServices: Bool      // Does this business have services configured?
    
    // Rich Details (Stored from Google or User Input)
    var phoneNumber: String?
    var website: String?
    var openingHours: [String]?      // Weekly hours text
    var photos: [String]?            // Additional photo URLs
    
    // Computed unique identifier for SwiftUI lists
    var uniqueID: String {
        return id ?? googlePlaceId ?? UUID().uuidString
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case businessId
        case name
        case category
        case city
        case address
        case rating
        case reviewCount
        case imageURL
        case description
        case priceRange
        case isOpen
        case distance
        case googlePlaceId
        case isGoogleListing
        case isClaimed
        case claimedBy
        case hasActiveServices
        case phoneNumber
        case website
        case openingHours
        case photos
    }
    
    init(id: String? = nil, businessId: String, name: String, category: String, city: String, address: String, rating: Double? = nil, reviewCount: Int? = nil, imageURL: String? = nil, description: String? = nil, priceRange: String? = nil, isOpen: Bool? = nil, distance: Double? = nil, googlePlaceId: String? = nil, isGoogleListing: Bool = false, isClaimed: Bool = false, claimedBy: String? = nil, hasActiveServices: Bool = false, phoneNumber: String? = nil, website: String? = nil, openingHours: [String]? = nil, photos: [String]? = nil) {
        // Use googlePlaceId as id for Google businesses if id is not provided
        self.id = id ?? googlePlaceId
        self.businessId = businessId
        self.name = name
        self.category = category
        self.city = city
        self.address = address
        self.rating = rating
        self.reviewCount = reviewCount
        self.imageURL = imageURL
        self.description = description
        self.priceRange = priceRange
        self.isOpen = isOpen
        self.distance = distance
        self.googlePlaceId = googlePlaceId
        self.isGoogleListing = isGoogleListing
        self.isClaimed = isClaimed
        self.claimedBy = claimedBy
        self.hasActiveServices = hasActiveServices
        self.phoneNumber = phoneNumber
        self.website = website
        self.openingHours = openingHours
        self.photos = photos
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedId = try container.decodeIfPresent(String.self, forKey: .id)
        let decodedGooglePlaceId = try container.decodeIfPresent(String.self, forKey: .googlePlaceId)
        
        // Use googlePlaceId as id if id is not present
        id = decodedId ?? decodedGooglePlaceId
        
        businessId = try container.decode(String.self, forKey: .businessId)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        // Handle missing city for legacy data
        city = try container.decodeIfPresent(String.self, forKey: .city) ?? "İstanbul"
        address = try container.decode(String.self, forKey: .address)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        reviewCount = try container.decodeIfPresent(Int.self, forKey: .reviewCount)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        priceRange = try container.decodeIfPresent(String.self, forKey: .priceRange)
        isOpen = try container.decodeIfPresent(Bool.self, forKey: .isOpen)
        distance = try container.decodeIfPresent(Double.self, forKey: .distance)
        googlePlaceId = decodedGooglePlaceId
        isGoogleListing = try container.decodeIfPresent(Bool.self, forKey: .isGoogleListing) ?? false
        isClaimed = try container.decodeIfPresent(Bool.self, forKey: .isClaimed) ?? false
        claimedBy = try container.decodeIfPresent(String.self, forKey: .claimedBy)
        hasActiveServices = try container.decodeIfPresent(Bool.self, forKey: .hasActiveServices) ?? false
        
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        website = try container.decodeIfPresent(String.self, forKey: .website)
        openingHours = try container.decodeIfPresent([String].self, forKey: .openingHours)
        photos = try container.decodeIfPresent([String].self, forKey: .photos)
    }
    
    // For preview/testing
    static var sample: BusinessListing {
        BusinessListing(
            id: "1",
            businessId: "bus_1",
            name: "Güzellik Salonu",
            category: "Kuaför & Güzellik",
            city: "Mersin",
            address: "Yenişehir Mahallesi, Atatürk Caddesi No:123",
            rating: 4.5,
            reviewCount: 128,
            imageURL: nil,
            description: "Profesyonel kuaför ve güzellik hizmetleri",
            priceRange: "$$",
            isOpen: true,
            distance: 2.5
        )
    }
}
