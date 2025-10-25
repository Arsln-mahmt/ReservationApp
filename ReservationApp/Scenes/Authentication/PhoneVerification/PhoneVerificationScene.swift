//
//  PhoneVerificationScene.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

struct PhoneVerificationScene: View {
    @StateObject private var viewModel: PhoneVerificationViewModel
    
    init(phoneNumber: String, userId: String) {
        _viewModel = StateObject(wrappedValue: PhoneVerificationViewModel(phoneNumber: phoneNumber, userId: userId))
    }
    
    var body: some View {
        PhoneVerificationUI(viewModel: viewModel)
    }
}

