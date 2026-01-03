//
//  SceneDelegate.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI
import Combine

class SceneDelegate: ObservableObject {
    @Published var currentScene: AppSceneType = .mainApp
    
    static let shared = SceneDelegate()
    
    private init() {}
    
    func navigateTo(_ scene: AppSceneType) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentScene = scene
        }
    }
}
