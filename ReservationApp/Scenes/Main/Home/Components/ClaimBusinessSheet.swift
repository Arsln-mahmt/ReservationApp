//
//  ClaimBusinessSheet.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 21.12.2025.
//

import SwiftUI

struct ClaimBusinessSheet: View {
    let business: BusinessListing
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccess = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(business.name)
                            .font(.headline)
                        Text(business.address)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("İşletme Bilgileri")
                }
                
                Section {
                    TextField("Adınız Soyadınız", text: $name)
                        .textContentType(.name)
                    
                    TextField("Telefon Numaranız", text: $phone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                } header: {
                    Text("Yetkili Bilgileri")
                } footer: {
                    Text("Güvenlik amacıyla, bu telefon numarasından sizi arayarak teyit alacağız.")
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button {
                        submitRequest()
                    } label: {
                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Talebi Gönder")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(
                        isFormValid ? Color.primaryOrange : Color.gray.opacity(0.3)
                    )
                    .disabled(!isFormValid || isLoading)
                }
            }
            .navigationTitle("İşletmeyi Sahiplen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Vazgeç") {
                        dismiss()
                    }
                }
            }
            .alert("Talep Alındı", isPresented: $showSuccess) {
                Button("Tamam") {
                    dismiss()
                }
            } message: {
                Text("Sahiplenme talebiniz başarıyla alındı. Ekibimiz kısa süre içinde sizinle iletişime geçecektir.")
            }
        }
    }
    
    // MARK: - Logic
    private var isFormValid: Bool {
        return !name.isEmpty && phone.count >= 10
    }
    
    private func submitRequest() {
        isLoading = true
        errorMessage = nil
        
        // Simulate delay or call Firebase
        ClaimManager.shared.submitClaimRequest(
            business: business,
            requesterName: name,
            requesterPhone: phone
        ) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    showSuccess = true
                    
                case .failure(let error):
                    errorMessage = "Hata oluştu: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    ClaimBusinessSheet(business: BusinessListing.sample)
}
