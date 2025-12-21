//
//  BusinessSearchView.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 15.12.2025.
//

import SwiftUI
import CoreLocation

struct BusinessSearchView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var locationManager = LocationManager.shared
    @State private var searchQuery = ""
    @State private var searchResults: [GooglePlace] = []
    @State private var isSearching = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    private let placesManager = GooglePlacesManager.shared
    var onBusinessSelected: ((GooglePlace) -> Void)?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                
                // Results list
                if isSearching {
                    loadingView
                } else if searchResults.isEmpty {
                    emptyView
                } else {
                    resultsList
                }
            }
            .navigationTitle("İşletme Ara")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
            .alert("Hata", isPresented: $showError) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Bir hata oluştu")
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textSecondary)
            
            TextField("İşletme adı veya kategori...", text: $searchQuery)
                .textFieldStyle(.plain)
                .onSubmit {
                    performSearch()
                }
            
            if !searchQuery.isEmpty {
                Button(action: {
                    searchQuery = ""
                    searchResults = []
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
        .padding()
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Aranıyor...")
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.textSecondary)
            
            Text("İşletme Ara")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text("İşletme adını veya kategorisini girin\n(örn: \"Kuaför\", \"Klinik\", \"Spa\")")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: searchNearby) {
                HStack {
                    Image(systemName: "location.fill")
                    Text("Yakınımdaki İşletmeler")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(LinearGradient.primaryGradient)
                .cornerRadius(12)
            }
            .padding(.top)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Results List
    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(searchResults) { place in
                    BusinessSearchResultRow(place: place)
                        .onTapGesture {
                            onBusinessSelected?(place)
                            dismiss()
                        }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Actions
    private func performSearch() {
        guard !searchQuery.isEmpty else { return }
        
        isSearching = true
        
        let location = locationManager.location?.coordinate
        
        placesManager.searchBusinessesByText(query: searchQuery, location: location) { result in
            DispatchQueue.main.async {
                isSearching = false
                
                switch result {
                case .success(let places):
                    searchResults = places
                    
                case .failure(let error):
                    errorMessage = "Arama başarısız: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    private func searchNearby() {
        guard let location = locationManager.location?.coordinate else {
            errorMessage = "Konum bilgisi alınamadı. Lütfen konum izni verin."
            showError = true
            return
        }
        
        isSearching = true
        
        placesManager.searchNearbyBusinesses(location: location) { result in
            DispatchQueue.main.async {
                isSearching = false
                
                switch result {
                case .success(let places):
                    searchResults = places
                    
                case .failure(let error):
                    errorMessage = "Arama başarısız: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}

// MARK: - Business Search Result Row
struct BusinessSearchResultRow: View {
    let place: GooglePlace
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            Image(systemName: categoryIcon)
                .font(.title2)
                .foregroundColor(.primaryOrange)
                .frame(width: 50, height: 50)
                .background(Color.primaryOrange.opacity(0.1))
                .cornerRadius(10)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                if let address = place.vicinity ?? place.formatted_address {
                    Text(address)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 12) {
                    if let rating = place.rating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    
                    if let ratingsCount = place.user_ratings_total {
                        Text("(\(ratingsCount) değerlendirme)")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    if place.business_status == "OPERATIONAL" {
                        Text("• Açık")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.textSecondary)
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    private var categoryIcon: String {
        guard let types = place.types else { return "building.2" }
        
        if types.contains("hair_care") || types.contains("beauty_salon") {
            return "scissors"
        } else if types.contains("spa") {
            return "sparkles"
        } else if types.contains("dentist") || types.contains("doctor") || types.contains("hospital") {
            return "cross.case"
        } else if types.contains("restaurant") {
            return "fork.knife"
        } else {
            return "building.2"
        }
    }
}

#Preview {
    BusinessSearchView()
}
