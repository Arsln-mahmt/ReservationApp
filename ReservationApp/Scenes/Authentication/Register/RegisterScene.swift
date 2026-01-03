//
//  RegisterScene.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

struct RegisterScene: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showPhoneVerification = false
    
    var body: some View {
        RegisterUI(viewModel: viewModel, onDismiss: {
            dismiss()
        })
        .fullScreenCover(isPresented: $showPhoneVerification) {
            if let userId = viewModel.registeredUserId {
                PhoneVerificationScene(
                    phoneNumber: viewModel.phoneNumber,
                    userId: userId
                )
            }
        }
        .onChange(of: viewModel.registrationSuccessId) { _, newValue in
            if newValue != nil {
                print("🔄 Registration success detected, showing phone verification...")
                // Close register sheet first
                dismiss()
                // Small delay to ensure sheet is dismissed before showing new one
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showPhoneVerification = true
                }
            }
        }
    }
}

#Preview {
    RegisterScene()
}
