//
//  CompleteProfileUI.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

struct CompleteProfileUI: View {
    @ObservedObject var viewModel: CompleteProfileViewModel
    @EnvironmentObject var sceneDelegate: SceneDelegate
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.bgSecondary
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerSection(topInset: geometry.safeAreaInsets.top)
                    
                    // Form
                    ScrollView {
                        formSection
                            .padding(.top, -30)
                    }
                }
                .ignoresSafeArea(edges: .top)
            }
        }
    }
    
    private func headerSection(topInset: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            LinearGradient.primaryGradient
                .frame(height: 200 + topInset)
                .cornerRadius(30, corners: [.bottomLeft, .bottomRight])
            
            VStack(spacing: 12) {
                Spacer()
                    .frame(height: topInset > 0 ? topInset : 20)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                
                Text("Son Bir Adım!")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Profilinizi tamamlayın")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.bottom, 40)
        }
    }
    
    private var formSection: some View {
        VStack(spacing: 20) {
            VStack(spacing: 20) {
                // Info text
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.primaryOrange)
                    Text("Lütfen iletişim bilgilerinizi girin")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textSecondary)
                    Spacer()
                }
                
                // Phone number
                CustomTextField(
                    icon: "phone.fill",
                    placeholder: "Telefon (5XX XXX XX XX)",
                    text: $viewModel.phoneNumber,
                    keyboardType: .phonePad
                )
                
                // Business fields
                if viewModel.userType == .business {
                    Divider()
                        .padding(.vertical, 8)
                    
                    Text("İşletme Bilgileri")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primaryOrange)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomTextField(
                        icon: "building.2.fill",
                        placeholder: "İşletme Adı",
                        text: $viewModel.businessName
                    )
                    
                    VStack(spacing: 8) {
                        CustomTextField(
                            icon: "location.fill",
                            placeholder: "İşletme Adresi",
                            text: $viewModel.businessAddress
                        )
                        
                        Button(action: {
                            viewModel.getCurrentLocation()
                        }) {
                            HStack(spacing: 8) {
                                if viewModel.isLoadingLocation {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .primaryOrange))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 14))
                                    Text("Konumumu Bul")
                                        .font(.system(size: 14, weight: .medium))
                                }
                            }
                            .foregroundColor(.primaryOrange)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.primaryOrange.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .disabled(viewModel.isLoadingLocation)
                    }
                    
                    CustomTextField(
                        icon: "tag.fill",
                        placeholder: "Kategori (Kuaför, Klinik, vb.)",
                        text: $viewModel.businessCategory
                    )
                }
                
                // Error message
                if let error = viewModel.errorMessage {
                    errorMessageView(error)
                }
                
                // Complete button
                Button(action: {
                    viewModel.completeProfile { success in
                        if success {
                            // Navigate to phone verification
                            // For now, go directly to home
                            if viewModel.userType == .business {
                                sceneDelegate.navigateTo(.businessDashboard)
                            } else {
                                sceneDelegate.navigateTo(.customerHome)
                            }
                        }
                    }
                    hideKeyboard()
                }) {
                    HStack(spacing: 12) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                            Text("Tamamla")
                        }
                    }
                }
                .primaryButtonStyle()
                .disabled(viewModel.isLoading)
            }
            .padding(20)
            .background(Color.white)
            .elevatedCardStyle()
            .padding(.horizontal, 20)
            
            Spacer(minLength: 40)
        }
    }
    
    private func errorMessageView(_ error: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(error)
                .font(.system(size: 14))
        }
        .foregroundColor(.errorRed)
        .padding(.horizontal)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.errorRed.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    CompleteProfileUI(viewModel: CompleteProfileViewModel(
        userType: .business,
        userId: "test123",
        email: "test@test.com",
        name: "Test User"
    ))
    .environmentObject(SceneDelegate.shared)
}

