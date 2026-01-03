//
//  CompleteProfileScene.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

struct CompleteProfileScene: View {
    @StateObject private var viewModel: CompleteProfileViewModel
    let userType: UserType
    
    init(userType: UserType, userId: String, email: String, name: String) {
        self.userType = userType
        _viewModel = StateObject(wrappedValue: CompleteProfileViewModel(
            userType: userType,
            userId: userId,
            email: email,
            name: name
        ))
    }
    
    var body: some View {
        CompleteProfileUI(viewModel: viewModel)
    }
}











