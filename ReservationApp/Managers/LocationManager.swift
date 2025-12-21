//
//  LocationManager.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    @Published var location: CLLocation?
    @Published var address: String?
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    static let shared = LocationManager()
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Request Location Permission
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Get Current Location
    func getCurrentLocation(completion: @escaping (Result<String, Error>) -> Void) {
        isLoading = true
        errorMessage = nil
        
        // Check authorization status
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            // Request permission first
            requestPermission()
            completion(.failure(LocationError.permissionNotDetermined))
            isLoading = false
            return
            
        case .denied, .restricted:
            isLoading = false
            completion(.failure(LocationError.permissionDenied))
            return
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Permission granted, get location
            locationManager.requestLocation()
            
        @unknown default:
            isLoading = false
            completion(.failure(LocationError.unknownError))
            return
        }
        
        // Wait for location update (handled in delegate)
        // Store completion for later use
        self.locationCompletion = completion
    }
    
    // MARK: - Get Current Location Placemark
    func getCurrentLocationPlacemark(completion: @escaping (Result<CLPlacemark, Error>) -> Void) {
        isLoading = true
        errorMessage = nil
        
        // Check authorization status
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            requestPermission()
            completion(.failure(LocationError.permissionNotDetermined))
            isLoading = false
            return
            
        case .denied, .restricted:
            isLoading = false
            completion(.failure(LocationError.permissionDenied))
            return
            
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
            
        @unknown default:
            isLoading = false
            completion(.failure(LocationError.unknownError))
            return
        }
        
        self.placemarkCompletion = completion
    }
    
    // Store completion handlers
    private var locationCompletion: ((Result<String, Error>) -> Void)?
    private var placemarkCompletion: ((Result<CLPlacemark, Error>) -> Void)?
    
    // MARK: - Geocode Location to Address
    private func geocodeLocation(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                print("❌ Geocoding error: \(error.localizedDescription)")
                self.errorMessage = "Adres alınamadı"
                self.locationCompletion?(.failure(error))
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("❌ No placemark found")
                self.locationCompletion?(.failure(LocationError.noAddressFound))
                return
            }
            
            // Build address string
            let address = self.formatAddress(from: placemark)
            self.address = address
            
            print("✅ Location found: \(address)")
            self.locationCompletion?(.success(address))
            self.placemarkCompletion?(.success(placemark))
            
            // Clear completions
            self.locationCompletion = nil
            self.placemarkCompletion = nil
        }
    }
    
    // MARK: - Format Address
    private func formatAddress(from placemark: CLPlacemark) -> String {
        var addressComponents: [String] = []
        
        // Street name and number
        if let thoroughfare = placemark.thoroughfare {
            var street = thoroughfare
            if let subThoroughfare = placemark.subThoroughfare {
                street = "\(thoroughfare) No:\(subThoroughfare)"
            }
            addressComponents.append(street)
        }
        
        // Neighborhood
        if let subLocality = placemark.subLocality {
            addressComponents.append(subLocality)
        }
        
        // District
        if let locality = placemark.locality {
            addressComponents.append(locality)
        }
        
        // City
        if let administrativeArea = placemark.administrativeArea {
            addressComponents.append(administrativeArea)
        }
        
        // Country
        if let country = placemark.country {
            addressComponents.append(country)
        }
        
        return addressComponents.joined(separator: ", ")
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        print("📍 Location authorization status changed: \(manager.authorizationStatus.rawValue)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        self.location = location
        print("📍 Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        // Convert to address
        geocodeLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        errorMessage = "Konum alınamadı"
        
        print("❌ Location error: \(error.localizedDescription)")
        
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                locationCompletion?(.failure(LocationError.permissionDenied))
            case .locationUnknown:
                locationCompletion?(.failure(LocationError.locationUnavailable))
            default:
                locationCompletion?(.failure(error))
            }
        } else {
            locationCompletion?(.failure(error))
            placemarkCompletion?(.failure(error))
        }
        
        locationCompletion = nil
        placemarkCompletion = nil
    }
}

// MARK: - Location Errors
enum LocationError: LocalizedError {
    case permissionNotDetermined
    case permissionDenied
    case locationUnavailable
    case noAddressFound
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .permissionNotDetermined:
            return "Lütfen konum izni verin"
        case .permissionDenied:
            return "Konum izni reddedildi. Ayarlar'dan izin verebilirsiniz."
        case .locationUnavailable:
            return "Konum bilgisi alınamadı"
        case .noAddressFound:
            return "Adres bulunamadı"
        case .unknownError:
            return "Bilinmeyen bir hata oluştu"
        }
    }
}











