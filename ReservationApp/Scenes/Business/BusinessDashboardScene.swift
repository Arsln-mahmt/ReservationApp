//
//  BusinessDashboardScene.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

struct BusinessDashboardScene: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var sceneDelegate: SceneDelegate
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.darkGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Image(systemName: "building.2.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.primaryOrange)
                    
                    VStack(spacing: 12) {
                        Text("İşletme Paneliniz")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(authManager.currentUser?.businessName ?? "İşletme")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(authManager.currentUser?.name ?? "")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    VStack(spacing: 15) {
                        BusinessInfoCard(
                            icon: "envelope.fill",
                            title: "E-posta",
                            value: authManager.currentUser?.email ?? ""
                        )
                        
                        BusinessInfoCard(
                            icon: "phone.fill",
                            title: "Telefon",
                            value: authManager.currentUser?.phoneNumber ?? ""
                        )
                        
                        BusinessInfoCard(
                            icon: "location.fill",
                            title: "Adres",
                            value: authManager.currentUser?.businessAddress ?? ""
                        )
                        
                        BusinessInfoCard(
                            icon: "tag.fill",
                            title: "Kategori",
                            value: authManager.currentUser?.businessCategory ?? ""
                        )
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    Button(action: {
                        authManager.signOut()
                        sceneDelegate.navigateTo(.authentication)
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square.fill")
                            Text("Çıkış Yap")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.primaryOrange.opacity(0.3))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct BusinessInfoCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.primaryOrange.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.primaryOrange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

#Preview {
    BusinessDashboardScene()
        .environmentObject(AuthManager.shared)
        .environmentObject(SceneDelegate.shared)
}

