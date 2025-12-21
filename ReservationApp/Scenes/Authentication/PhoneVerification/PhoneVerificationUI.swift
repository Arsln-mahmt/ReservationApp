//
//  PhoneVerificationUI.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

struct PhoneVerificationUI: View {
    @ObservedObject var viewModel: PhoneVerificationViewModel
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var sceneDelegate: SceneDelegate
    @EnvironmentObject var appEnvironment: AppEnvironment
    @FocusState private var isCodeFieldFocused: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient.primaryGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with back button
                    headerSection(geometry: geometry)
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 24) {
                            // Title and description
                            titleSection
                            
                            // Code input
                            codeInputSection
                            
                            // Verify button
                            verifyButton
                            
                            // Resend code
                            resendSection
                            
                            // Messages
                            if let errorMessage = viewModel.errorMessage {
                                errorMessageView(errorMessage)
                            }
                            
                            if let successMessage = viewModel.successMessage {
                                successMessageView(successMessage)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 40)
                        .padding(.bottom, 40)
                    }
                }
                
                // Loading overlay
                if viewModel.isLoading || viewModel.isSendingCode {
                    LoadingOverlay(
                        message: viewModel.isSendingCode ? "Kod gönderiliyor..." : "Doğrulanıyor..."
                    )
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    // MARK: - Header Section
    private func headerSection(geometry: GeometryProxy) -> some View {
        let topInset = geometry.safeAreaInsets.top
        let baseHeight: CGFloat = 140
        let dynamicHeight = topInset > 50 ? baseHeight + 20 : baseHeight
        
        return ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color.clear)
                .frame(height: dynamicHeight)
            
            // Back button
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Geri")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    Spacer()
                }
                .padding(.top, topInset > 50 ? 8 : 4)
                Spacer()
            }
            
            VStack(spacing: 12) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                
                Text("Telefon Doğrulama")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.bottom, 20)
        }
        .frame(height: dynamicHeight)
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        VStack(spacing: 12) {
            Text("Doğrulama Kodu")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text("\(viewModel.phoneNumber) numaralı telefona gönderilen 6 haneli kodu girin")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Code Input Section
    private var codeInputSection: some View {
        VStack(spacing: 16) {
            ZStack {
                // Code boxes
                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { index in
                        CodeDigitView(
                            digit: getDigit(at: index),
                            isActive: index == viewModel.verificationCode.count
                        )
                    }
                }
                
                // Hidden TextField for input (full width to catch taps)
                TextField("", text: $viewModel.verificationCode)
                    .keyboardType(.numberPad)
                    .focused($isCodeFieldFocused)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .opacity(0.01)
                    .onChange(of: viewModel.verificationCode) { newValue in
                        // Limit to 6 digits
                        if newValue.count > 6 {
                            viewModel.verificationCode = String(newValue.prefix(6))
                        }
                        // Remove non-numeric characters
                        viewModel.verificationCode = viewModel.verificationCode.filter { $0.isNumber }
                    }
            }
            .onTapGesture {
                isCodeFieldFocused = true
            }
        }
        .padding(.vertical, 20)
        .onAppear {
            // Auto-focus when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isCodeFieldFocused = true
            }
        }
    }
    
    // MARK: - Verify Button
    private var verifyButton: some View {
        Button(action: {
            hideKeyboard()
            viewModel.verifyCode { success in
                if success {
                    // Wait a moment to show success message
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        dismiss() // Close verification screen
                        // Then navigate to home
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            navigateToHome()
                        }
                    }
                }
            }
        }) {
            Text("Doğrula")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient.primaryGradient
                        .opacity(viewModel.verificationCode.count == 6 ? 1 : 0.5)
                )
                .cornerRadius(16)
                .shadow(color: Color.primaryOrange.opacity(0.3), radius: 8, y: 4)
        }
        .disabled(viewModel.verificationCode.count != 6)
    }
    
    // MARK: - Resend Section
    private var resendSection: some View {
        VStack(spacing: 12) {
            if !viewModel.canResend {
                Text("Kodu tekrar gönderebilmek için \(viewModel.countdown) saniye bekleyin")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Button(action: {
                viewModel.sendVerificationCode()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Kodu Tekrar Gönder")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(viewModel.canResend ? .primaryOrange : .textLight)
            }
            .disabled(!viewModel.canResend)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Helper Functions
    private func getDigit(at index: Int) -> String? {
        guard index < viewModel.verificationCode.count else { return nil }
        let digitIndex = viewModel.verificationCode.index(
            viewModel.verificationCode.startIndex,
            offsetBy: index
        )
        return String(viewModel.verificationCode[digitIndex])
    }
    
    private func navigateToHome() {
        // Update AuthManager
        authManager.checkAuthStatus()
        
        // Navigate based on user type
        if let userType = appEnvironment.currentUser?.userType {
            switch userType {
            case .customer:
                sceneDelegate.navigateTo(.mainApp)
            case .business:
                sceneDelegate.navigateTo(.businessDashboard)
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // MARK: - Message Views
    private func errorMessageView(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.red)
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func successMessageView(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.green)
            Spacer()
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Code Digit View
struct CodeDigitView: View {
    let digit: String?
    let isActive: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            isActive ? Color.primaryOrange : Color.textLight.opacity(0.3),
                            lineWidth: isActive ? 2 : 1
                        )
                )
                .frame(width: 45, height: 56)
            
            if let digit = digit {
                Text(digit)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
            }
        }
    }
}

// MARK: - Loading Overlay
struct LoadingOverlay: View {
    let message: String
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(Color.secondaryNavy)
            .cornerRadius(16)
        }
    }
}

