//
//  HomeViewModel.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import Combine
import FirebaseFirestore

class HomeViewModel: ObservableObject {
    @Published var businesses: [BusinessListing] = []  // Firebase businesses
    @Published var googleBusinesses: [BusinessListing] = []  // Google Places businesses
    @Published var filteredBusinesses: [BusinessListing] = []
    @Published var searchText = ""
    @Published var selectedCategory: String?
    @Published var selectedCity: String = ""
    @Published var isLoading = false  // Start with false - no loading view
    @Published var showCityPicker = false
    @Published var showGoogleBusinesses = true  // Toggle to show/hide Google businesses
    @Published var selectedBusiness: BusinessListing?  // For sheet presentation
    @Published var hasBusiness = false // If user owns a business
    
    let categories = ["Tümü", "Kuaför & Güzellik", "Klinik", "Restoran", "Spor Salonu", "Diğer"]
    
    private let businessListingManager = BusinessListingManager.shared
    private let googlePlacesManager = GooglePlacesManager.shared
    private let cityKey = "selectedCity"
    
    init() {
        loadSavedCity()
        
        // Load Firebase businesses directly
        loadFirebaseBusinessesDirect()
        
        // Check if current user has a business
        checkBusinessStatus()
    }
    
    // MARK: - Load/Save City
    private func loadSavedCity() {
        if let savedCity = UserDefaults.standard.string(forKey: cityKey) {
            selectedCity = savedCity
            print("📍 Loaded saved city: \(savedCity)")
        } else {
            selectedCity = "Mersin" // Default city
            print("📍 No saved city, defaulting to Mersin")
        }
    }
    
    func saveCity(_ city: String) {
        selectedCity = city
        UserDefaults.standard.set(city, forKey: cityKey)
        print("💾 Saved city: \(city)")
        applyFilters()
    }
    
    // MARK: - Load Businesses
    func loadBusinesses() {
        print("📝 Loading businesses...")
        loadFirebaseBusinessesDirect()
        checkBusinessStatus()
    }
    
    // MARK: - Load Firebase Businesses Directly
    private func loadFirebaseBusinessesDirect() {
        isLoading = true
        print("🔥 Loading Firebase businesses...")
        
        businessListingManager.getAllBusinessListings { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let listings):
                    print("✅ Loaded \(listings.count) businesses from Firebase")
                    self.businesses = listings
                    
                case .failure(let error):
                    print("❌ Failed to load businesses: \(error)")
                    // Load fallback test data if Firebase fails
                    self.loadFallbackTestData()
                }
                
                // Load Google Businesses after Firebase (safely)
                // Do NOT set isLoading = false yet if we are going to load Google businesses
                if self.showGoogleBusinesses && !self.selectedCity.isEmpty {
                    self.loadGoogleBusinesses()
                } else {
                    self.applyFilters()
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Fallback Test Data
    private func loadFallbackTestData() {
        print("⚠️ Loading fallback test data...")
        businesses = [
            BusinessListing(
                businessId: "test_business_1",
                name: "Güzellik Merkezi",
                category: "Kuaför & Güzellik",
                city: "Mersin",
                address: "Yenişehir Mahallesi, Atatürk Caddesi No:45",
                rating: 4.8,
                reviewCount: 245,
                imageURL: nil,
                description: "Profesyonel kuaför ve güzellik hizmetleri",
                priceRange: "$$",
                isOpen: true,
                distance: 1.2
            )
        ]
        applyFilters()
    }
    
    // MARK: - Load Test Data (Direct - No Async)
    private func loadTestDataDirect() {
        // ... (keeping existing implementation if needed or can be removed, but I'll leave it for safety)
        isLoading = false
    }
    
    // MARK: - Load Firebase Businesses (Background)
    private func loadFirebaseBusinesses() {
        // ... (This function seems unused now, as we use Direct)
    }
    
    // MARK: - Load Google Places Businesses
    private func loadGoogleBusinesses() {
        guard !selectedCity.isEmpty else {
            applyFilters()
            return
        }
        
        // Removed simulator check to allow testing on Simulator
        // If API Key is invalid, it receives an error but doesn't crash
        
        // Run Google Places search on BACKGROUND queue
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Construct a meaningful query
            // If category is selected, use it. If not, use broad keywords.
            let categoryQuery = self.selectedCategory ?? "Güzellik Merkezi Kuaför Berber"
            let query = "\(categoryQuery) \(self.selectedCity)"
            print("🔍 Loading Google Places for: \(query)")
            
            self.googlePlacesManager.searchBusinessesByText(query: query) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let places):
                        // Convert Google Places to BusinessListing
                        self.googleBusinesses = places.map { place in
                            BusinessConverter.convertGooglePlace(place, city: self.selectedCity)
                        }
                        print("✅ Loaded \(places.count) businesses from Google Places")
                        
                    case .failure(let error):
                        print("❌ Failed to load Google businesses: \(error.localizedDescription)")
                        // Don't clear existing googleBusinesses on simple error to avoid flickering if it was loaded
                        if self.googleBusinesses.isEmpty {
                            self.googleBusinesses = []
                        }
                    }
                    
                    self.applyFilters()
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Load Test Data (Sync)
    private func loadTestDataSync() {
        print("📝 Loading test data...")
        
        businesses = [
            BusinessListing(
                businessId: "test_business_1",
                name: "Güzellik Merkezi",
                category: "Kuaför & Güzellik",
                city: "Mersin",
                address: "Yenişehir Mahallesi, Atatürk Caddesi No:45",
                rating: 4.8,
                reviewCount: 245,
                imageURL: nil,
                description: "Profesyonel kuaför ve güzellik hizmetleri",
                priceRange: "$$",
                isOpen: true,
                distance: 1.2
            ),
            BusinessListing(
                businessId: "test_business_2",
                name: "İstanbul Kuaför",
                category: "Kuaför & Güzellik",
                city: "İstanbul",
                address: "Kadıköy, İstanbul",
                rating: 4.5,
                reviewCount: 189,
                imageURL: nil,
                description: "Modern kuaför salonu",
                priceRange: "$$$",
                isOpen: true,
                distance: 2.5
            ),
            BusinessListing(
                businessId: "test_business_3",
                name: "Yenişehir Güzellik",
                category: "Bakım",
                city: "Ankara",
                address: "Çankaya, Ankara",
                rating: 4.7,
                reviewCount: 320,
                imageURL: nil,
                description: "Güzellik Merkezi",
                priceRange: "$$$",
                isOpen: true,
                distance: 3.2
            )
        ]
        
        // Apply filters ONCE after data is set
        DispatchQueue.main.async { [weak self] in
            self?.applyFilters()
            self?.isLoading = false
            print("✅ Test data loaded and filtered")
        }
    }
    
    // MARK: - Apply All Filters
    func applyFilters() {
        // Combine Firebase and Google businesses
        var allBusinesses = businesses
        
        if showGoogleBusinesses && !googleBusinesses.isEmpty {
            // Add Google businesses that don't already exist in Firebase
            let googleFiltered = googleBusinesses.filter { googleBiz in
                !businesses.contains { firebaseBiz in
                    // Check if same business (by Google Place ID or name+address)
                    if let googleId = firebaseBiz.googlePlaceId, googleId == googleBiz.googlePlaceId {
                        return true
                    }
                    return firebaseBiz.name == googleBiz.name && firebaseBiz.address == googleBiz.address
                }
            }
            allBusinesses += googleFiltered
        }
        
        var result = allBusinesses
        
        // 1. Filter by city
        if !selectedCity.isEmpty {
            result = result.filter { $0.city.localizedCaseInsensitiveContains(selectedCity) }
        }
        
        // 2. Filter by category
        if let category = selectedCategory, category != "Tümü" {
            result = result.filter { $0.category == category }
        }
        
        // 3. Filter by search text
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText) ||
                ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        filteredBusinesses = result
    }
    
    // MARK: - Filter by Category
    func filterByCategory(_ category: String) {
        if category == "Tümü" {
            selectedCategory = nil
        } else {
            selectedCategory = category
        }
        applyFilters()
    }
    
    // MARK: - Search
    func search() {
        applyFilters()
    }
    
    // MARK: - Use Current Location
    func useCurrentLocation() {
        // TODO: Get user's current city from LocationManager
        print("📍 Using current location...")
        // For now, just keep the selected city
    }
    
    // MARK: - Check Business Ownership
    func checkBusinessStatus() {
        guard let user = AuthManager.shared.currentUser else {
            self.hasBusiness = false
            return
        }
        
        // Check if user owns any business
        let db = Firestore.firestore()
        db.collection("businesses")
            .whereField("businessId", isEqualTo: user.uid)
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ Error checking business status: \(error)")
                        self?.hasBusiness = false
                    } else {
                        // If documents exist, user is a business owner
                        self?.hasBusiness = !(snapshot?.documents.isEmpty ?? true)
                        print("🏢 User business status: \(self?.hasBusiness ?? false)")
                    }
                }
            }
    }
}



