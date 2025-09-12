//
//  flashcardsApp.swift
//  flashcards
//
//  Created by mark on 9/9/25.
//

import SwiftUI

@main
struct flashcardsApp: App {
    @State private var isLoading = true
    
    var body: some Scene {
        WindowGroup {
            if isLoading {
                LoadingView()
                    .preferredColorScheme(.light)
                    .onAppear {
                        // Simulate loading time for app initialization
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                isLoading = false
                            }
                        }
                    }
            } else {
                ContentView()
                    .preferredColorScheme(.light) // Force light mode
            }
        }
    }
}
