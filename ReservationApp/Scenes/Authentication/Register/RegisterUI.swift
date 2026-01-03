//
//  RegisterUI.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

struct RegisterUI: View {
    @ObservedObject var viewModel: RegisterViewModel
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Color.bgSecondary
                .ignoresSafeArea()
            
            if viewModel.showUserTypeSelection {
                // User type selection screen
                userTypeSelectionView
            } else {
                // Registration form
                registrationFormView
            }
        }
    }
    
    // MARK: - User Type Selection
    private var userTypeSelectionView: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "person.2.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(LinearGradient.primaryGradient)
                
                Text("Hesap Türü Seçin")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                Text("Devam etmek için hesap türünüzü seçin")
                    .font(.system(size: 15))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 60)
            
            // User type cards
            VStack(spacing: 20) {
                UserTypeCard(
                    icon: "person.fill",
                    title: "Müşteri",
                    description: "Rezervasyon yapmak için hesap oluştur",
                    isSelected: false
                ) {
                    viewModel.selectUserType(.customer)
                }
                
                UserTypeCard(
                    icon: "building.2.fill",
                    title: "İşletme",
                    description: "İşletmeni kaydet ve rezervasyon al",
                    isSelected: false
                ) {
                    viewModel.selectUserType(.business)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Back button
            Button(action: onDismiss) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Giriş Sayfasına Dön")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primaryOrange)
            }
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Registration Form
    private var registrationFormView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header with safe area handling
                headerSection
                
                // Form
                formSection
                    .padding(.top, -40)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
    
    private var headerSection: some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            LinearGradient.primaryGradient
                .ignoresSafeArea(edges: .top)
                .frame(height: 280) // Fixed height that covers top area
                .cornerRadius(30, corners: [.bottomLeft, .bottomRight])
            
            // Content
            VStack(spacing: 12) {
                // Spacer for status bar
                Spacer().frame(height: 60)
                
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: viewModel.userType == .customer ? "person.fill" : "building.2.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.white)
                }
                
                // Title
                Text(viewModel.userType == .customer ? "Müşteri Kaydı" : "İşletme Kaydı")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                // Subtitle
                Text("Hesap oluşturun ve başlayın")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.bottom, 50)
        }
    }
    
    private var formSection: some View {
        VStack(spacing: 20) {
            VStack(spacing: 24) {
                // Social login buttons
                socialLoginButtons
                
                // Divider
                dividerWithText
                
                // Email/Password registration
                registrationFields
                
                // Error message
                if let error = viewModel.errorMessage {
                    errorMessageView(error)
                }
                
                // Register button
                registerButton
                
                // Login link
                loginLink
            }
            .padding(24)
            .background(Color.white)
            .elevatedCardStyle()
            .padding(.horizontal, 20)
            
            Spacer(minLength: 40)
        }
    }
    
    // MARK: - UI Components
    
    private var socialLoginButtons: some View {
        VStack(spacing: 12) {
            // Apple Sign In
            Button(action: {
                viewModel.signInWithApple()
            }) {
                HStack {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 20))
                    Text("Apple ile Devam Et")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.black)
                .cornerRadius(12)
            }
            
            // Google Sign In
            Button(action: {
                viewModel.signInWithGoogle()
            }) {
                HStack(spacing: 12) {
                    // Google colorful G
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                        
                        Text("G")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.26, green: 0.52, blue: 0.96), // Blue
                                        Color(red: 0.92, green: 0.25, blue: 0.21), // Red
                                        Color(red: 0.98, green: 0.74, blue: 0.02), // Yellow
                                        Color(red: 0.15, green: 0.66, blue: 0.29)  // Green
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    Text("Google ile Devam Et")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.textLight.opacity(0.5), lineWidth: 1.5)
                )
            }
        }
    }
    
    private var dividerWithText: some View {
        HStack {
            Rectangle()
                .fill(Color.textLight.opacity(0.3))
                .frame(height: 1)
            Text("veya e-posta ile")
                .font(.system(size: 13))
                .foregroundColor(.textSecondary)
                .padding(.horizontal, 12)
            Rectangle()
                .fill(Color.textLight.opacity(0.3))
                .frame(height: 1)
        }
    }
    
    private var registrationFields: some View {
        VStack(spacing: 16) {
            // First Name
            CustomTextField(
                icon: "person.fill",
                placeholder: "Ad",
                text: $viewModel.firstName
            )
            
            // Last Name
            CustomTextField(
                icon: "person.fill",
                placeholder: "Soyad",
                text: $viewModel.lastName
            )
            
            // Email
            CustomTextField(
                icon: "envelope.fill",
                placeholder: "E-posta",
                text: $viewModel.email,
                keyboardType: .emailAddress
            )
            
            // Phone
            CustomTextField(
                icon: "phone.fill",
                placeholder: "Telefon (5XX XXX XX XX)",
                text: $viewModel.phoneNumber,
                keyboardType: .phonePad
            )
            
            // Password
            CustomSecureField(
                icon: "lock.fill",
                placeholder: "Şifre (min. 6 karakter)",
                text: $viewModel.password
            )
            
            // Confirm Password
            CustomSecureField(
                icon: "lock.fill",
                placeholder: "Şifre Tekrar",
                text: $viewModel.confirmPassword
            )
            
            // Business fields (only if business type)
            if viewModel.userType == .business {
                businessFields
            }
        }
    }
    
    private var businessFields: some View {
        VStack(spacing: 16) {
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
                
                // Location button
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
            
            HStack(spacing: 12) {
                CustomTextField(
                    icon: "map.fill",
                    placeholder: "İlçe",
                    text: $viewModel.businessDistrict
                )
                
                CustomTextField(
                    icon: "mappin.and.ellipse",
                    placeholder: "Şehir",
                    text: $viewModel.businessCity
                )
            }
            
            CustomTextField(
                icon: "tag.fill",
                placeholder: "Kategori (Kuaför, Klinik, vb.)",
                text: $viewModel.businessCategory
            )
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
    
    private var registerButton: some View {
        Button(action: {
            viewModel.register()
            hideKeyboard()
        }) {
            HStack(spacing: 12) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                    Text("Hesap Oluştur")
                }
            }
        }
        .primaryButtonStyle()
        .disabled(viewModel.isLoading)
    }
    
    private var loginLink: some View {
        HStack {
            Text("Zaten hesabınız var mı?")
                .font(.system(size: 15))
                .foregroundColor(.textSecondary)
            Button(action: onDismiss) {
                Text("Giriş Yap")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primaryOrange)
            }
        }
    }
}

// MARK: - User Type Card
struct UserTypeCard: View {
    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(LinearGradient.primaryGradient.opacity(0.1))
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: icon)
                        .font(.system(size: 32))
                        .foregroundStyle(LinearGradient.primaryGradient)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.textPrimary)
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primaryOrange)
            }
            .padding(20)
            .background(Color.white)
            .elevatedCardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Custom Text Field
struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.primaryOrange)
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .autocapitalization(.none)
                .keyboardType(keyboardType)
        }
        .padding()
        .background(Color.bgSecondary)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.textLight.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Custom Secure Field
struct CustomSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.primaryOrange)
                .frame(width: 24)
            
            SecureField(placeholder, text: $text)
                .font(.system(size: 16))
                .textContentType(.password)
                .submitLabel(.done)
        }
        .padding()
        .background(Color.bgSecondary)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.textLight.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    RegisterUI(viewModel: RegisterViewModel(), onDismiss: {})
}

