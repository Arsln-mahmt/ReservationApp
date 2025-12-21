//
//  GooglePlacesManager.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 15.12.2025.
//

import Foundation
import CoreLocation

/// Manager for Google Places API operations
class GooglePlacesManager {
    static let shared = GooglePlacesManager()
    
    // Use legacy API for now (more compatible)
    private let baseURL = "https://maps.googleapis.com/maps/api/place"
    private var apiKey: String {
        return Config.googleMapsAPIKey
    }
    
    private init() {}
    
    // MARK: - Search Nearby Businesses
    /// Search for nearby businesses by type and location
    func searchNearbyBusinesses(
        location: CLLocationCoordinate2D,
        radius: Int = 5000, // meters
        type: String = "beauty_salon|hair_care|spa|dentist|doctor",
        completion: @escaping (Result<[GooglePlace], Error>) -> Void
    ) {
        // Use legacy API endpoint
        let urlString = "\(baseURL)/nearbysearch/json?location=\(location.latitude),\(location.longitude)&radius=\(radius)&type=\(type)&key=\(apiKey)&language=tr"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        print("🔍 Searching nearby businesses:")
        print("   URL: \(urlString)")
        print("   Location: \(location.latitude), \(location.longitude)")
        print("   Radius: \(radius)m")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Failed to search: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1)))
                return
            }
            
            // Debug: Print response
            if let responseString = String(data: data, encoding: .utf8) {
                print("📝 Response: \(responseString.prefix(200))...")
            }
            
            do {
                let result = try JSONDecoder().decode(GooglePlacesResponse.self, from: data)
                
                if result.status == "OK" {
                    print("✅ Found \(result.results.count) places")
                    completion(.success(result.results))
                } else {
                    print("⚠️ API returned status: \(result.status)")
                    if let errorMessage = result.error_message {
                        print("   Error message: \(errorMessage)")
                    }
                    completion(.failure(NSError(domain: "API Error: \(result.status)", code: -1)))
                }
            } catch {
                print("❌ Failed to decode: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Search Businesses by Text
    /// Search for businesses by text query
    func searchBusinessesByText(
        query: String,
        location: CLLocationCoordinate2D? = nil,
        completion: @escaping (Result<[GooglePlace], Error>) -> Void
    ) {
        var urlString = "\(baseURL)/textsearch/json?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)&key=\(apiKey)&language=tr"
        
        if let location = location {
            urlString += "&location=\(location.latitude),\(location.longitude)&radius=10000"
        }
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        print("🔍 Searching businesses by text:")
        print("   URL: \(urlString)")
        print("   Query: \(query)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Failed to search: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1)))
                return
            }
            
            // Debug: Print response
            if let responseString = String(data: data, encoding: .utf8) {
                print("📝 Response: \(responseString.prefix(200))...")
            }
            
            do {
                let result = try JSONDecoder().decode(GooglePlacesResponse.self, from: data)
                
                if result.status == "OK" {
                    print("✅ Found \(result.results.count) places")
                    completion(.success(result.results))
                } else {
                    print("⚠️ API returned status: \(result.status)")
                    if let errorMessage = result.error_message {
                        print("   Error message: \(errorMessage)")
                    }
                    completion(.failure(NSError(domain: "API Error: \(result.status)", code: -1)))
                }
            } catch {
                print("❌ Failed to decode: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Get Place Details
    /// Get detailed information about a specific place
    func getPlaceDetails(
        placeId: String,
        completion: @escaping (Result<GooglePlaceDetails, Error>) -> Void
    ) {
        let urlString = "\(baseURL)/details/json?place_id=\(placeId)&fields=name,formatted_address,formatted_phone_number,opening_hours,website,rating,user_ratings_total,photos,geometry&key=\(apiKey)&language=tr"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        
        print("📍 Getting place details for: \(placeId)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Failed to get details: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1)))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(GooglePlaceDetailsResponse.self, from: data)
                
                if result.status == "OK", let details = result.result {
                    print("✅ Got place details: \(details.name)")
                    completion(.success(details))
                } else {
                    print("⚠️ API returned status: \(result.status)")
                    completion(.failure(NSError(domain: "API Error: \(result.status)", code: -1)))
                }
            } catch {
                print("❌ Failed to decode: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Get Photo URL
    /// Get photo URL for a place photo reference
    func getPhotoURL(photoReference: String, maxWidth: Int = 400) -> String {
        return "\(baseURL)/photo?maxwidth=\(maxWidth)&photo_reference=\(photoReference)&key=\(apiKey)"
    }
}

// MARK: - Models

struct GooglePlacesResponse: Codable {
    let results: [GooglePlace]
    let status: String
    let error_message: String?
}

struct GooglePlace: Codable, Identifiable {
    let place_id: String
    let name: String
    let vicinity: String?
    let formatted_address: String?
    let geometry: GoogleGeometry
    let rating: Double?
    let user_ratings_total: Int?
    let types: [String]?
    let photos: [GooglePhoto]?
    let business_status: String?
    
    var id: String { place_id }
}

struct GoogleGeometry: Codable {
    let location: GoogleLocation
}

struct GoogleLocation: Codable {
    let lat: Double
    let lng: Double
}

struct GooglePhoto: Codable {
    let photo_reference: String
    let height: Int
    let width: Int
}

// MARK: - Place Details Models

struct GooglePlaceDetailsResponse: Codable {
    let result: GooglePlaceDetails?
    let status: String
}

struct GooglePlaceDetails: Codable {
    let name: String
    let formatted_address: String?
    let formatted_phone_number: String?
    let website: String?
    let rating: Double?
    let user_ratings_total: Int?
    let opening_hours: GoogleOpeningHours?
    let photos: [GooglePhoto]?
    let geometry: GoogleGeometry
}

struct GoogleOpeningHours: Codable {
    let open_now: Bool?
    let weekday_text: [String]?
}
