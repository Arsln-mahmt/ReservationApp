//
//  CustomerHomeScene.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

struct CustomerHomeScene: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var sceneDelegate: SceneDelegate
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.primaryGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12) {
                        Text("Hoş Geldin!")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(authManager.currentUser?.name ?? "Kullanıcı")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("Müşteri Paneli")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    VStack(spacing: 15) {
                        InfoCard(
                            icon: "envelope.fill",
                            title: "E-posta",
                            value: authManager.currentUser?.email ?? ""
                        )
                        
                        InfoCard(
                            icon: "phone.fill",
                            title: "Telefon",
                            value: authManager.currentUser?.phoneNumber ?? ""
                        )
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    Button(action: {
                        authManager.signOut()
                        sceneDelegate.navigateTo(.mainApp)
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square.fill")
                            Text("Çıkış Yap")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.2))
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

struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(15)
    }
}

#Preview {
    CustomerHomeScene()
        .environmentObject(AuthManager.shared)
        .environmentObject(SceneDelegate.shared)
}

