//
//  ProfileScene.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

struct ProfileScene: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var appEnvironment: AppEnvironment
    @EnvironmentObject var sceneDelegate: SceneDelegate
    @State private var showLoginSheet = false
    @State private var showRegisterSheet = false
    @State private var showLogoutAlert = false
    @State private var showProfileEdit = false
    @State private var showNotifications = false
    @State private var showFavorites = false
    @State private var showSettings = false
    @State private var showAdminPanel = false
    @Binding var shouldShowLogin: Bool
    
    init(shouldShowLogin: Binding<Bool> = .constant(false)) {
        self._shouldShowLogin = shouldShowLogin
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()
                
                if authManager.isAuthenticated, let user = authManager.currentUser {
                    // User is logged in
                    loggedInView(user: user)
                } else {
                    // User not logged in
                    guestView
                }
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showLoginSheet) {
                LoginScene()
            }
            .sheet(isPresented: $showRegisterSheet) {
                RegisterScene()
            }
            .sheet(isPresented: $showProfileEdit) {
                if let user = authManager.currentUser {
                    ProfileEditScene(user: user)
                }
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsScene()
            }
            .sheet(isPresented: $showFavorites) {
                FavoritesScene()
            }
            .sheet(isPresented: $showSettings) {
                SettingsScene()
            }
            .sheet(isPresented: $showAdminPanel) {
                AdminDashboard()
            }
            .alert("Çıkış Yap", isPresented: $showLogoutAlert) {
                Button("İptal", role: .cancel) {}
                Button("Çıkış Yap", role: .destructive) {
                    authManager.signOut()
                    appEnvironment.isAuthenticated = false
                    appEnvironment.currentUser = nil
                }
            } message: {
                Text("Çıkış yapmak istediğinize emin misiniz?")
            }
            .onChange(of: shouldShowLogin) { _, newValue in
                if newValue {
                    showLoginSheet = true
                    shouldShowLogin = false
                }
            }
        }
    }
    
    // MARK: - Guest View
    private var guestView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile icon
                ZStack {
                    Circle()
                        .fill(LinearGradient.primaryGradient.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.primaryOrange)
                }
                .padding(.top, 40)
                
                VStack(spacing: 12) {
                    Text("Hoş Geldiniz!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("Rezervasyon yapmak ve daha fazlası için giriş yapın")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Login button
                Button(action: {
                    showLoginSheet = true
                }) {
                    Text("Giriş Yap")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient.primaryGradient)
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                }
                .padding(.horizontal, 40)
                .shadow(color: Color.primaryOrange.opacity(0.3), radius: 8, y: 4)
                
                // Register button
                Button(action: {
                    showRegisterSheet = true
                }) {
                    HStack(spacing: 4) {
                        Text("Hesabınız yok mu?")
                            .foregroundColor(.textSecondary)
                        Text("Kayıt Olun")
                            .foregroundColor(.primaryOrange)
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Logged In View
    private func loggedInView(user: User) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile header
                VStack(spacing: 16) {
                    // Profile image
                    ZStack {
                        Circle()
                            .fill(LinearGradient.primaryGradient)
                            .frame(width: 100, height: 100)
                        
                        if user.profileImageURL != nil {
                            // TODO: Load actual image
                            Text(String(user.name.prefix(1)))
                                .font(.system(size: 40))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        } else {
                            Text(String(user.name.prefix(1)))
                                .font(.system(size: 40))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 4) {
                        Text(user.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                        
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                        
                        // Phone verification badge
                        if user.phoneVerified == true {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                Text("Telefon Doğrulandı")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                            }
                            .padding(.top, 4)
                        }
                    }
                }
                .padding(.bottom, 20)
                
                // Menu items
                VStack(spacing: 0) {
                    MenuButton(icon: "person.fill", title: "Profil Bilgilerim") {
                        showProfileEdit = true
                    }
                    
                    Divider().padding(.leading, 60)
                    
                    MenuButton(icon: "bell.fill", title: "Bildirimler") {
                        showNotifications = true
                    }
                    
                    Divider().padding(.leading, 60)
                    
                    MenuButton(icon: "heart.fill", title: "Favoriler") {
                        showFavorites = true
                    }
                    
                    Divider().padding(.leading, 60)
                    
                    MenuButton(icon: "gearshape.fill", title: "Ayarlar") {
                        showSettings = true
                    }
                    
                    // Admin Panel Access (Hidden for regular users)
                    if user.email.lowercased() == "admin@app.com" || user.email.lowercased() == "mahmut@test.com" { // Buraya kendi emailini ekle
                        Divider().padding(.leading, 60)
                        MenuButton(icon: "shield.fill", title: "Yönetici Paneli") {
                            showAdminPanel = true
                        }
                    }
                }
                .background(Color.bgCard)
                .cornerRadius(16)
                .padding(.horizontal, 20)
                
                // Logout button
                Button(action: {
                    showLogoutAlert = true
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                        Text("Çıkış Yap")
                            .foregroundColor(.red)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.primaryOrange)
                .frame(width: 30)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
            
            Spacer()
        }
    }
}

// MARK: - Menu Button
struct MenuButton: View {
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

#Preview {
    ProfileScene()
        .environmentObject(AuthManager.shared)
        .environmentObject(AppEnvironment.shared)
        .environmentObject(SceneDelegate.shared)
}



