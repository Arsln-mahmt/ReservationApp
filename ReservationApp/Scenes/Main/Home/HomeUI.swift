//
//  HomeUI.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 3.10.2025.
//

import SwiftUI

struct HomeUI: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var authManager: AuthManager
    @State private var showVoiceAssistant = false
    @State private var showBusinessSearch = false
    @State private var showBusinessDashboard = false
    @State private var isAnimating = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Category filter
                    categoryScrollView
                    
                    // Business list
                    if viewModel.isLoading {
                        loadingView
                    } else if viewModel.filteredBusinesses.isEmpty {
                        emptyView
                    } else {
                        businessList
                    }
                }
                
                // Voice Assistant Floating Button with Tooltip
                VoiceAssistantButton(showVoiceAssistant: $showVoiceAssistant)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Business Dashboard Button (Left)
                ToolbarItem(placement: .navigationBarLeading) {
                    if authManager.isAuthenticated && viewModel.hasBusiness {
                        Button {
                            showBusinessDashboard = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "storefront.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("İşletmem")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.primaryOrange)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 28)
                            .background(Color.bgPrimary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.primaryOrange.opacity(0.3), lineWidth: 1.5)
                            )
                            .cornerRadius(20)
                        }
                    }
                }
                
                // Search Button (Right)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showBusinessSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }

                }
            }
        }
        .fullScreenCover(isPresented: $showBusinessDashboard) {
            BusinessDashboardScene()
        }
        .onReceive(NotificationCenter.default.publisher(for: .dismissBusinessDashboard)) { _ in
            showBusinessDashboard = false
        }
        .sheet(isPresented: $viewModel.showCityPicker) {
            CityPickerSheet(
                selectedCity: $viewModel.selectedCity,
                onSelect: { city in
                    viewModel.saveCity(city)
                    viewModel.showCityPicker = false
                }
            )
        }
        .sheet(isPresented: $showVoiceAssistant) {
            VoiceAssistantChatView()
        }
        .sheet(item: $viewModel.selectedBusiness) { business in
            NavigationStack {
                SimpleBusinessDetail(business: business)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Kapat") {
                                viewModel.selectedBusiness = nil
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $showBusinessSearch) {
            BusinessSearchView { selectedPlace in
                let businessListing = BusinessConverter.convertGooglePlace(selectedPlace, city: viewModel.selectedCity)
                if !viewModel.googleBusinesses.contains(where: { $0.googlePlaceId == businessListing.googlePlaceId }) {
                    viewModel.googleBusinesses.append(businessListing)
                    viewModel.applyFilters()
                }
                showBusinessSearch = false
                
                // Open detail sheet after search closes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.selectedBusiness = businessListing
                }
            }
        }
        .onAppear {
            if authManager.currentUser != nil {
                viewModel.checkBusinessStatus()
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("İşletmeleri Keşfet")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            // City Selector
            Button {
                viewModel.showCityPicker = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.orange)
                    
                    Text(viewModel.selectedCity.isEmpty ? "Şehir Seç" : viewModel.selectedCity)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            }
        }
        .padding()
        .background(Color.bgPrimary)
    }
    
    // MARK: - Category ScrollView
    private var categoryScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.categories, id: \.self) { category in
                    CategoryChip(
                        title: category,
                        isSelected: viewModel.selectedCategory == category || (category == "Tümü" && viewModel.selectedCategory == nil),
                        action: {
                            if category == "Tümü" {
                                viewModel.selectedCategory = nil
                                viewModel.applyFilters()
                            } else {
                                viewModel.filterByCategory(category)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color.bgPrimary)
    }
    
    // MARK: - Business List
    private var businessList: some View {
        List(viewModel.filteredBusinesses, id: \.uniqueID) { business in
            ZStack {
                NavigationLink(destination: SimpleBusinessDetail(business: business)) {
                    EmptyView()
                }
                .opacity(0) // Hide the arrow
                
                BusinessCardRow(business: business)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .refreshable {
            viewModel.loadBusinesses()
        }
    }
    
    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "building.2")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            Text("İşletme bulunamadı")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Farklı bir şehir veya kategori seçin")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.7))
            Spacer()
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "calendar")
                .font(.system(size: 60))
                .foregroundColor(.orange.opacity(0.6))
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .opacity(isAnimating ? 1.0 : 0.5)
                .onAppear {
                    // Start animation when view appears
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        isAnimating = true
                    }
                }
            
            Text("İşletmeler Yükleniyor...")
                .font(.headline)
                .foregroundColor(.gray)
            
            Spacer()
        }
    }
}

// MARK: - Preview
struct HomeUI_Previews: PreviewProvider {
    static var previews: some View {
        HomeUI(viewModel: HomeViewModel())
    }
}
