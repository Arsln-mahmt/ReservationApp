//
//  LoginUI.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

struct LoginUI: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.bgSecondary
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top gradient header with safe area
                    headerSection(topInset: geometry.safeAreaInsets.top)
                    
                    // Login form
                    loginFormSection
                        .padding(.top, -40)
                    
                    Spacer()
                }
                .ignoresSafeArea(edges: .top)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isAnimating = true
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    // MARK: - Header Section
    private func headerSection(topInset: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            // Background with proper height for safe area
            LinearGradient.primaryGradient
                .frame(height: 260 + topInset)
                .cornerRadius(30, corners: [.bottomLeft, .bottomRight])
            
            VStack(spacing: 12) {
                // Dynamic Island / Notch spacer
                Spacer()
                    .frame(height: topInset > 0 ? topInset + 10 : 20)
                
                // Logo
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                .scaleEffect(isAnimating ? 1 : 0.5)
                .opacity(isAnimating ? 1 : 0)
                
                Text("Hoş Geldiniz")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Hesabınıza giriş yapın")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Login Form Section
    private var loginFormSection: some View {
        VStack(spacing: 16) {
            // White card container
            VStack(spacing: 20) {
                // Email field
                emailField
                
                // Password field
                passwordField
                
                // Error message
                if let error = viewModel.errorMessage {
                    errorMessageView(error)
                }
                
                // Login button
                loginButton
                
                // Forgot password
                forgotPasswordButton
                
                // Divider
                dividerWithText
                
                // Register button
                registerButton
            }
            .padding(20)
            .background(Color.white)
            .elevatedCardStyle()
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - UI Components
    private var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("E-posta", systemImage: "envelope.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.textSecondary)
            
            TextField("ornek@email.com", text: $viewModel.email)
                .textFieldStyle()
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
        }
    }
    
    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Şifre", systemImage: "lock.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.textSecondary)
            
            SecureField("••••••••", text: $viewModel.password)
                .textFieldStyle()
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
    
    private var loginButton: some View {
        Button(action: {
            viewModel.login()
            hideKeyboard()
        }) {
            HStack(spacing: 12) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 20))
                    Text("Giriş Yap")
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity)
            .background(LinearGradient.primaryGradient)
            .cornerRadius(12)
            .contentShape(Rectangle())
            .shadow(color: Color.primaryOrange.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(viewModel.isLoading)
    }
    
    private var forgotPasswordButton: some View {
        Button(action: {
            // Forgot password action
        }) {
            Text("Şifremi Unuttum")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primaryOrange)
        }
    }
    
    private var dividerWithText: some View {
        HStack {
            Rectangle()
                .fill(Color.textLight.opacity(0.3))
                .frame(height: 1)
            Text("veya")
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
                .padding(.horizontal, 12)
            Rectangle()
                .fill(Color.textLight.opacity(0.3))
                .frame(height: 1)
        }
        .padding(.vertical, 8)
    }
    
    private var registerButton: some View {
        NavigationLink(destination: RegisterScene()) {
            HStack(spacing: 12) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 20))
                Text("Hesap Oluştur")
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.primaryOrange)
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primaryOrange, lineWidth: 2)
            )
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    LoginUI(viewModel: LoginViewModel())
}

