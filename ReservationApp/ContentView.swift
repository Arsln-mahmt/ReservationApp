//
//  ContentView.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var showTestView = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world !")
            
            Button("Google Places API Test") {
                showTestView = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .sheet(isPresented: $showTestView) {
            GooglePlacesTestView()
        }
    }
}

#Preview {
    ContentView()
}
