//
//  BookingScene.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

struct BookingScene: View {
    let business: BusinessListing
    let service: Service
    
    @StateObject private var viewModel: BookingViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    init(business: BusinessListing, service: Service) {
        self.business = business
        self.service = service
        _viewModel = StateObject(wrappedValue: BookingViewModel(business: business, service: service))
    }
    
    var body: some View {
        NavigationStack {
            BookingUI(
                business: business,
                service: service,
                viewModel: viewModel,
                authManager: authManager,
                onCancel: { dismiss() }
            )
            .navigationTitle("Randevu Oluştur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
            .alert("Başarılı!", isPresented: $viewModel.showSuccessAlert) {
                Button("Tamam") {
                    dismiss()
                }
            } message: {
                Text("Randevunuz başarıyla oluşturuldu!\n\n'Rezervasyonlarım' sekmesinden görüntüleyebilirsiniz.")
            }
            .alert("Hata", isPresented: $viewModel.showErrorAlert) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Bir hata oluştu")
            }
            .onAppear {
                print("📱 BookingScene appeared - resetting state and loading time slots")
                viewModel.reset()
                viewModel.loadAvailableTimeSlots()
            }
        }
    }
}

#Preview {
    BookingScene(business: .sample, service: .sample)
        .environmentObject(AuthManager.shared)
}

