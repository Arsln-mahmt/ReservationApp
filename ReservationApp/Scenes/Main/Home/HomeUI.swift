//
//  HomeUI.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 3.10.2025.
//

import SwiftUI

struct HomeUI: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var showVoiceAssistant = false
    @State private var showBusinessSearch = false
    
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
                    if viewModel.filteredBusinesses.isEmpty {
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
        .sheet(isPresented: $showBusinessSearch) {
            BusinessSearchView { selectedPlace in
                let businessListing = BusinessConverter.convertGooglePlace(selectedPlace, city: viewModel.selectedCity)
                if !viewModel.googleBusinesses.contains(where: { $0.googlePlaceId == businessListing.googlePlaceId }) {
                    viewModel.googleBusinesses.append(businessListing)
                    viewModel.applyFilters()
                }
                showBusinessSearch = false
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
}

// MARK: - Preview
struct HomeUI_Previews: PreviewProvider {
    static var previews: some View {
        HomeUI(viewModel: HomeViewModel())
    }
}
