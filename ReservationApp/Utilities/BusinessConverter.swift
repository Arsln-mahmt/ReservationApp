//
//  BusinessConverter.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 15.12.2025.
//

import Foundation

/// Converts Google Places data to BusinessListing
class BusinessConverter {
    
    /// Convert GooglePlace to BusinessListing
    static func convertGooglePlace(
        _ place: GooglePlace,
        city: String? = nil
    ) -> BusinessListing {
        return BusinessListing(
            id: nil,  // Will be set by Firestore if saved
            businessId: place.place_id,  // Use Google Place ID as business ID
            name: place.name,
            category: inferCategory(from: place.types),
            city: city ?? extractCity(from: place.formatted_address ?? place.vicinity),
            address: place.formatted_address ?? place.vicinity ?? "",
            rating: place.rating,
            reviewCount: place.user_ratings_total,
            imageURL: getPhotoURL(from: place.photos?.first),
            description: nil,  // Google doesn't provide description
            priceRange: nil,   // Google doesn't provide price range
            isOpen: place.opening_hours?.open_now ?? (place.business_status == "OPERATIONAL"),
            distance: nil,     // Will be calculated later
            googlePlaceId: place.place_id,
            isGoogleListing: true,
            isClaimed: false,
            claimedBy: nil,
            hasActiveServices: false  // No services yet
        )
    }
    
    /// Infer category from Google Place types
    private static func inferCategory(from types: [String]?) -> String {
        guard let types = types else { return "Diğer" }
        
        // Map Google types to our categories
        if types.contains("hair_care") || types.contains("beauty_salon") {
            return "Kuaför & Güzellik"
        } else if types.contains("spa") {
            return "Spa & Masaj"
        } else if types.contains("dentist") {
            return "Diş Kliniği"
        } else if types.contains("doctor") || types.contains("hospital") {
            return "Sağlık"
        } else if types.contains("restaurant") {
            return "Restoran"
        } else if types.contains("cafe") {
            return "Kafe"
        } else if types.contains("gym") {
            return "Spor Salonu"
        } else {
            return "Diğer"
        }
    }
    
    /// Extract city from address
    private static func extractCity(from address: String?) -> String {
        guard let address = address else { return "Bilinmiyor" }
        
        // Try to extract city from address
        // Turkish addresses usually have city after comma
        let components = address.components(separatedBy: ",")
        
        // Common Turkish cities
        let cities = ["İstanbul", "Ankara", "İzmir", "Bursa", "Antalya", "Adana", 
                     "Konya", "Gaziantep", "Mersin", "Kayseri", "Eskişehir"]
        
        for component in components {
            let trimmed = component.trimmingCharacters(in: .whitespaces)
            for city in cities {
                if trimmed.contains(city) {
                    return city
                }
            }
        }
        
        // If no city found, return last component (usually city/country)
        if let lastComponent = components.last {
            return lastComponent.trimmingCharacters(in: .whitespaces)
        }
        
        return "Bilinmiyor"
    }
    
    /// Get photo URL from Google Photo
    private static func getPhotoURL(from photo: GooglePhoto?) -> String? {
        guard let photo = photo else {
            print("⚠️ No photo available for business")
            return nil
        }
        
        // Use GooglePlacesManager to get photo URL
        let photoURL = GooglePlacesManager.shared.getPhotoURL(
            photoReference: photo.photo_reference,
            maxWidth: 400
        )
        print("📸 Generated photo URL: \(photoURL)")
        return photoURL
    }
}
