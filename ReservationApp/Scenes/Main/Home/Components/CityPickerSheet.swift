//
//  CityPickerSheet.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 21.12.2025.
//

import SwiftUI

// MARK: - City Picker Sheet
struct CityPickerSheet: View {
    @Binding var selectedCity: String
    let onSelect: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    
    private var popularCities: [City] {
        City.popularCities
    }
    
    private var allCities: [City] {
        City.sortedCities
    }
    
    private var filteredCities: [City] {
        if searchText.isEmpty {
            return allCities
        } else {
            return allCities.filter { $0.displayName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Şehir ara...", text: $searchText)
                        .textFieldStyle(.plain)
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()
                
                List {
                    if searchText.isEmpty {
                        Section("Popüler Şehirler") {
                            ForEach(popularCities) { city in
                                CityRow(city: city, isSelected: selectedCity == city.rawValue) {
                                    onSelect(city.rawValue)
                                    dismiss()
                                }
                            }
                        }
                    }
                    
                    Section(searchText.isEmpty ? "Tüm Şehirler" : "Sonuçlar") {
                        ForEach(filteredCities) { city in
                            CityRow(city: city, isSelected: selectedCity == city.rawValue) {
                                onSelect(city.rawValue)
                                dismiss()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Şehir Seç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - City Row
struct CityRow: View {
    let city: City
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(city.displayName)
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.orange)
                }
            }
        }
    }
}

#Preview {
    CityPickerSheet(selectedCity: .constant("İstanbul"), onSelect: { _ in })
}
