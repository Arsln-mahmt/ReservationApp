//
//  ServiceSelectionSheet.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 21.12.2025.
//

import SwiftUI
import Combine
import FirebaseFirestore

struct ServiceSelectionSheet: View {
    let business: BusinessListing
    let onSelect: (Service) -> Void
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ServiceSelectionViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Hizmetler yükleniyor...")
                } else if viewModel.services.isEmpty {
                    emptyView
                } else {
                    servicesList
                }
            }
            .navigationTitle("Hizmet Seçin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.loadServices(for: business)
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.clipboard")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            Text("Hizmet bulunamadı")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Bu işletme henüz hizmet eklememektedir.")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var servicesList: some View {
        List(viewModel.services) { service in
            Button {
                onSelect(service)
            } label: {
                ServiceItemRow(service: service)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
}

// MARK: - Service Item Row
struct ServiceItemRow: View {
    let service: Service
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: "scissors")
                .font(.title2)
                .foregroundColor(.primaryOrange)
                .frame(width: 50, height: 50)
                .background(Color.primaryOrange.opacity(0.1))
                .cornerRadius(12)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(service.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let description = service.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                HStack(spacing: 12) {
                    // Duration
                    Label("\(service.duration) dk", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    // Price
                    Text("\(Int(service.price)) ₺")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryOrange)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - Service Selection ViewModel
class ServiceSelectionViewModel: ObservableObject {
    @Published var services: [Service] = []
    @Published var isLoading = false
    
    func loadServices(for business: BusinessListing) {
        isLoading = true
        
        // Try with businessId first (for Firebase businesses)
        let searchId = business.businessId
        
        print("🔍 Loading services for business: \(business.name)")
        print("   businessId: \(searchId)")
        print("   document id: \(business.id ?? "nil")")
        
        // Load services from Firebase using businessId
        ServiceManager.shared.getServices(businessId: searchId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let services):
                    if !services.isEmpty {
                        print("✅ Found \(services.count) services with businessId")
                        self?.services = services.filter { $0.isActive }
                        self?.isLoading = false
                    } else {
                        // Try with document ID if businessId returns empty
                        self?.tryWithDocumentId(business: business)
                    }
                case .failure(let error):
                    print("❌ Error loading services: \(error)")
                    self?.tryWithDocumentId(business: business)
                }
            }
        }
    }
    
    private func tryWithDocumentId(business: BusinessListing) {
        guard let docId = business.id else {
            // For Google Places businesses or no id, show sample services
            services = [
                Service(
                    id: UUID().uuidString,
                    businessId: business.uniqueID,
                    name: "Standart Hizmet",
                    description: "Bu işletmenin standart hizmeti",
                    duration: 30,
                    price: 100,
                    isActive: true,
                    createdAt: Timestamp()
                )
            ]
            isLoading = false
            return
        }
        
        print("🔍 Trying with document ID: \(docId)")
        ServiceManager.shared.getServices(businessId: docId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let services):
                    if !services.isEmpty {
                        print("✅ Found \(services.count) services with document ID")
                        self?.services = services.filter { $0.isActive }
                    } else {
                        print("⚠️ No services found for this business")
                        self?.services = []
                    }
                case .failure(let error):
                    print("❌ Error loading services: \(error)")
                    self?.services = []
                }
            }
        }
    }
}

#Preview {
    ServiceSelectionSheet(business: .sample) { _ in }
}
