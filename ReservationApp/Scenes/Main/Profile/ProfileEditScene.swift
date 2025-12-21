//
//  ProfileEditScene.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI
import FirebaseFirestore

struct ProfileEditScene: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    @State private var name: String
    @State private var phoneNumber: String
    @State private var address: String
    @State private var isLoading = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    init(user: User) {
        _name = State(initialValue: user.name)
        _phoneNumber = State(initialValue: user.phoneNumber ?? "")
        _address = State(initialValue: user.address ?? "")
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Picture Section
                    profilePictureSection
                    
                    // Personal Info Section
                    personalInfoSection
                    
                    // Save Button
                    saveButton
                }
                .padding(20)
            }
            .background(Color.bgPrimary)
            .navigationTitle("Profil Bilgilerim")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
            .alert("Başarılı", isPresented: $showSuccessAlert) {
                Button("Tamam") {
                    dismiss()
                }
            } message: {
                Text("Profil bilgileriniz güncellendi")
            }
            .alert("Hata", isPresented: $showErrorAlert) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Profile Picture Section
    private var profilePictureSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient.primaryGradient)
                    .frame(width: 120, height: 120)
                
                Text(String(name.prefix(1)))
                    .font(.system(size: 50))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Button(action: {
                // TODO: Add image picker
            }) {
                Text("Fotoğraf Değiştir")
                    .font(.subheadline)
                    .foregroundColor(.primaryOrange)
            }
        }
        .padding(.vertical)
    }
    
    // MARK: - Personal Info Section
    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Kişisel Bilgiler")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 16) {
                // Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ad Soyad")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    TextField("Ad Soyad", text: $name)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.bgCard)
                        .cornerRadius(12)
                }
                
                // Phone
                VStack(alignment: .leading, spacing: 8) {
                    Text("Telefon")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    TextField("Telefon", text: $phoneNumber)
                        .textFieldStyle(.plain)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color.bgCard)
                        .cornerRadius(12)
                }
                
                // Address
                VStack(alignment: .leading, spacing: 8) {
                    Text("Adres (Opsiyonel)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    TextEditor(text: $address)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color.bgCard)
                        .cornerRadius(12)
                }
                
                // Email (readonly)
                VStack(alignment: .leading, spacing: 8) {
                    Text("E-posta")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Text(authManager.currentUser?.email ?? "")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.bgCard.opacity(0.5))
                        .cornerRadius(12)
                        .overlay(
                            Text("E-posta değiştirilemez")
                                .font(.caption2)
                                .foregroundColor(.textLight)
                                .padding(.trailing, 12),
                            alignment: .trailing
                        )
                }
            }
        }
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: saveProfile) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity)
            } else {
                Text("Kaydet")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 56)
        .background(LinearGradient.primaryGradient)
        .cornerRadius(12)
        .disabled(isLoading || name.isEmpty)
        .opacity(name.isEmpty ? 0.5 : 1.0)
    }
    
    private func saveProfile() {
        guard !name.isEmpty else { return }
        
        isLoading = true
        
        // TODO: Implement actual profile update with Firebase
        // For now, just simulate a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            showSuccessAlert = true
            
            // Update local user data
            if var user = authManager.currentUser {
                user.name = name
                user.phoneNumber = phoneNumber.isEmpty ? nil : phoneNumber
                user.address = address.isEmpty ? nil : address
                authManager.currentUser = user
            }
        }
    }
}

#Preview {
    ProfileEditScene(user: User(
        uid: "123",
        email: "test@example.com",
        name: "Test User",
        userType: .customer,
        createdAt: Timestamp()
    ))
    .environmentObject(AuthManager.shared)
}

