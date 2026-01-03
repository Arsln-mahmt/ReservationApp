//
//  HomeScene.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

struct HomeScene: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            HomeUI(viewModel: viewModel)
        }
    }
}

#Preview {
    HomeScene()
}











