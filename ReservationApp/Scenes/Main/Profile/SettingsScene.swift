//
//  SettingsScene.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

struct SettingsScene: View {
    @Environment(\.dismiss) var dismiss
    @State private var notificationsEnabled = true
    @State private var emailNotifications = true
    @State private var smsNotifications = false
    @State private var pushNotifications = true
    @State private var showDeleteAccountAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Notifications Section
                    notificationsSection
                    
                    // Privacy Section
                    privacySection
                    
                    // App Info Section
                    appInfoSection
                    
                    // Danger Zone
                    dangerZoneSection
                }
                .padding(20)
            }
            .background(Color.bgPrimary)
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Geri") {
                        dismiss()
                    }
                }
            }
            .alert("Hesabı Sil", isPresented: $showDeleteAccountAlert) {
                Button("İptal", role: .cancel) {}
                Button("Sil", role: .destructive) {
                    // TODO: Delete account
                }
            } message: {
                Text("Hesabınızı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.")
            }
        }
    }
    
    // MARK: - Notifications Section
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Bildirimler")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 0) {
                ToggleRow(
                    icon: "bell.fill",
                    title: "Bildirimleri Etkinleştir",
                    isOn: $notificationsEnabled
                )
                
                Divider().padding(.leading, 60)
                
                ToggleRow(
                    icon: "envelope.fill",
                    title: "E-posta Bildirimleri",
                    isOn: $emailNotifications
                )
                .disabled(!notificationsEnabled)
                .opacity(notificationsEnabled ? 1.0 : 0.5)
                
                Divider().padding(.leading, 60)
                
                ToggleRow(
                    icon: "message.fill",
                    title: "SMS Bildirimleri",
                    isOn: $smsNotifications
                )
                .disabled(!notificationsEnabled)
                .opacity(notificationsEnabled ? 1.0 : 0.5)
                
                Divider().padding(.leading, 60)
                
                ToggleRow(
                    icon: "bell.badge.fill",
                    title: "Push Bildirimleri",
                    isOn: $pushNotifications
                )
                .disabled(!notificationsEnabled)
                .opacity(notificationsEnabled ? 1.0 : 0.5)
            }
            .background(Color.bgCard)
            .cornerRadius(16)
        }
    }
    
    // MARK: - Privacy Section
    private var privacySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Gizlilik")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 0) {
                SettingsMenuButton(icon: "lock.fill", title: "Şifre Değiştir") {
                    // TODO: Navigate to change password
                }
                
                Divider().padding(.leading, 60)
                
                SettingsMenuButton(icon: "hand.raised.fill", title: "Gizlilik Politikası") {
                    // TODO: Show privacy policy
                }
                
                Divider().padding(.leading, 60)
                
                SettingsMenuButton(icon: "doc.text.fill", title: "Kullanım Koşulları") {
                    // TODO: Show terms of service
                }
            }
            .background(Color.bgCard)
            .cornerRadius(16)
        }
    }
    
    // MARK: - App Info Section
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Uygulama")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 0) {
                SettingsInfoRow(icon: "info.circle.fill", title: "Versiyon", value: "1.0.0")
                
                Divider().padding(.leading, 60)
                
                SettingsMenuButton(icon: "star.fill", title: "Uygulamayı Değerlendir") {
                    // TODO: Open App Store rating
                }
                
                Divider().padding(.leading, 60)
                
                SettingsMenuButton(icon: "envelope.fill", title: "Destek") {
                    // TODO: Open support email
                }
            }
            .background(Color.bgCard)
            .cornerRadius(16)
        }
    }
    
    // MARK: - Danger Zone Section
    private var dangerZoneSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: {
                showDeleteAccountAlert = true
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red)
                    Text("Hesabı Sil")
                        .foregroundColor(.red)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Toggle Row
struct ToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.primaryOrange)
                .frame(width: 30)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }
}

// MARK: - Settings Menu Button
struct SettingsMenuButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.primaryOrange)
                    .frame(width: 30)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textLight)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Settings Info Row
struct SettingsInfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.primaryOrange)
                .frame(width: 30)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }
}

#Preview {
    SettingsScene()
}

