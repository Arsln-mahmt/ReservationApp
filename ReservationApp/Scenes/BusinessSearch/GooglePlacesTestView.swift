//
//  GooglePlacesTestView.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 15.12.2025.
//

import SwiftUI
import CoreLocation

/// Test view for Google Places API
struct GooglePlacesTestView: View {
    @State private var testResult = "Test henüz çalıştırılmadı"
    @State private var isLoading = false
    
    private let placesManager = GooglePlacesManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Google Places API Test")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(testResult)
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
                
                Button(action: testAPI) {
                    Text("API'yi Test Et")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient.primaryGradient)
                        .cornerRadius(12)
                }
                .disabled(isLoading)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("API Test")
        }
    }
    
    private func testAPI() {
        isLoading = true
        testResult = "Test ediliyor..."
        
        // Mersin merkez koordinatları
        let mersinLocation = CLLocationCoordinate2D(latitude: 36.8121, longitude: 34.6415)
        
        placesManager.searchBusinessesByText(query: "Kuaför Mersin", location: mersinLocation) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let places):
                    testResult = """
                    ✅ Başarılı!
                    
                    \(places.count) işletme bulundu:
                    
                    \(places.prefix(5).map { "• \($0.name)" }.joined(separator: "\n"))
                    """
                    
                case .failure(let error):
                    testResult = """
                    ❌ Hata!
                    
                    \(error.localizedDescription)
                    
                    Lütfen:
                    1. API key'in doğru olduğunu kontrol edin
                    2. Places API'nin etkinleştirildiğini kontrol edin
                    3. Internet bağlantınızı kontrol edin
                    """
                }
            }
        }
    }
}

#Preview {
    GooglePlacesTestView()
}
