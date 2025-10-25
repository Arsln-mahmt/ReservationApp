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
    
    var body: some View {
        RegisterUI(viewModel: viewModel, onDismiss: {
            dismiss()
        })
        .fullScreenCover(isPresented: $viewModel.registrationSuccess) {
            if let userId = viewModel.registeredUserId {
                PhoneVerificationScene(
                    phoneNumber: viewModel.phoneNumber,
                    userId: userId
                )
            }
        }
    }
}

#Preview {
    RegisterScene()
}
