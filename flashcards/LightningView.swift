//
//  LightningView.swift
//  flashcards
//
//  Created by mark on 9/9/25.
//

import SwiftUI

struct LightningView: View {
    @State private var animate = false
    @State private var opacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Main lightning bolt
            Path { path in
                let width: CGFloat = 60
                let height: CGFloat = 120
                
                // Lightning bolt shape
                path.move(to: CGPoint(x: width * 0.3, y: 0))
                path.addLine(to: CGPoint(x: width * 0.1, y: height * 0.4))
                path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.4))
                path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.7))
                path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.7))
                path.addLine(to: CGPoint(x: width * 0.1, y: height))
                path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.6))
                path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.6))
                path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.3))
                path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.3))
                path.addLine(to: CGPoint(x: width * 0.7, y: 0))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [Color.yellow, Color.orange, Color.yellow],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 60, height: 120)
            .scaleEffect(animate ? 1.2 : 0.8)
            .opacity(opacity)
            .shadow(color: .yellow, radius: animate ? 15 : 5)
            
            // Glow effect
            Path { path in
                let width: CGFloat = 60
                let height: CGFloat = 120
                
                // Lightning bolt shape (slightly larger for glow)
                path.move(to: CGPoint(x: width * 0.3, y: 0))
                path.addLine(to: CGPoint(x: width * 0.1, y: height * 0.4))
                path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.4))
                path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.7))
                path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.7))
                path.addLine(to: CGPoint(x: width * 0.1, y: height))
                path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.6))
                path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.6))
                path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.3))
                path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.3))
                path.addLine(to: CGPoint(x: width * 0.7, y: 0))
                path.closeSubpath()
            }
            .fill(Color.yellow.opacity(0.3))
            .frame(width: 80, height: 140)
            .blur(radius: 8)
            .scaleEffect(animate ? 1.3 : 0.9)
            .opacity(opacity * 0.6)
        }
        .onAppear {
            // Fade in
            withAnimation(.easeIn(duration: 0.3)) {
                opacity = 1.0
            }
            
            // Start pulsing animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
            
            // Fade out after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    opacity = 0.0
                }
            }
        }
    }
}

struct LightningStreakView: View {
    let streakCount: Int
    @State private var showLightning = false
    
    var body: some View {
        ZStack {
            if showLightning {
                // Multiple lightning bolts for higher streaks
                ForEach(0..<min(streakCount, 3), id: \.self) { index in
                    LightningView()
                        .position(
                            x: CGFloat.random(in: 100...UIScreen.main.bounds.width - 100),
                            y: CGFloat.random(in: 150...UIScreen.main.bounds.height - 200)
                        )
                        .animation(.easeInOut(duration: 0.3).delay(Double(index) * 0.2), value: showLightning)
                }
            }
        }
        .onAppear {
            showLightning = true
        }
    }
}

struct CenterLightningView: View {
    @State private var animate = false
    @State private var opacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Large center lightning bolt
            Path { path in
                let width: CGFloat = 100
                let height: CGFloat = UIScreen.main.bounds.height
                let centerX = UIScreen.main.bounds.width / 2
                
                // Create a large lightning bolt that goes through the center of the screen
                path.move(to: CGPoint(x: centerX - width * 0.2, y: 0))
                path.addLine(to: CGPoint(x: centerX - width * 0.4, y: height * 0.2))
                path.addLine(to: CGPoint(x: centerX + width * 0.3, y: height * 0.2))
                path.addLine(to: CGPoint(x: centerX - width * 0.1, y: height * 0.4))
                path.addLine(to: CGPoint(x: centerX + width * 0.4, y: height * 0.4))
                path.addLine(to: CGPoint(x: centerX + width * 0.1, y: height * 0.6))
                path.addLine(to: CGPoint(x: centerX - width * 0.3, y: height * 0.6))
                path.addLine(to: CGPoint(x: centerX + width * 0.2, y: height * 0.8))
                path.addLine(to: CGPoint(x: centerX - width * 0.2, y: height * 0.8))
                path.addLine(to: CGPoint(x: centerX + width * 0.1, y: height))
                path.addLine(to: CGPoint(x: centerX + width * 0.5, y: height * 0.7))
                path.addLine(to: CGPoint(x: centerX - width * 0.1, y: height * 0.7))
                path.addLine(to: CGPoint(x: centerX + width * 0.3, y: height * 0.5))
                path.addLine(to: CGPoint(x: centerX - width * 0.2, y: height * 0.5))
                path.addLine(to: CGPoint(x: centerX + width * 0.4, y: height * 0.3))
                path.addLine(to: CGPoint(x: centerX - width * 0.3, y: height * 0.3))
                path.addLine(to: CGPoint(x: centerX + width * 0.2, y: 0))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [Color.white, Color.yellow, Color.orange, Color.yellow, Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 100, height: UIScreen.main.bounds.height)
            .scaleEffect(animate ? 1.3 : 0.7)
            .opacity(opacity)
            .shadow(color: .yellow, radius: animate ? 25 : 10)
            
            // Intense glow effect
            Path { path in
                let width: CGFloat = 100
                let height: CGFloat = UIScreen.main.bounds.height
                let centerX = UIScreen.main.bounds.width / 2
                
                // Same lightning shape but larger for glow
                path.move(to: CGPoint(x: centerX - width * 0.2, y: 0))
                path.addLine(to: CGPoint(x: centerX - width * 0.4, y: height * 0.2))
                path.addLine(to: CGPoint(x: centerX + width * 0.3, y: height * 0.2))
                path.addLine(to: CGPoint(x: centerX - width * 0.1, y: height * 0.4))
                path.addLine(to: CGPoint(x: centerX + width * 0.4, y: height * 0.4))
                path.addLine(to: CGPoint(x: centerX + width * 0.1, y: height * 0.6))
                path.addLine(to: CGPoint(x: centerX - width * 0.3, y: height * 0.6))
                path.addLine(to: CGPoint(x: centerX + width * 0.2, y: height * 0.8))
                path.addLine(to: CGPoint(x: centerX - width * 0.2, y: height * 0.8))
                path.addLine(to: CGPoint(x: centerX + width * 0.1, y: height))
                path.addLine(to: CGPoint(x: centerX + width * 0.5, y: height * 0.7))
                path.addLine(to: CGPoint(x: centerX - width * 0.1, y: height * 0.7))
                path.addLine(to: CGPoint(x: centerX + width * 0.3, y: height * 0.5))
                path.addLine(to: CGPoint(x: centerX - width * 0.2, y: height * 0.5))
                path.addLine(to: CGPoint(x: centerX + width * 0.4, y: height * 0.3))
                path.addLine(to: CGPoint(x: centerX - width * 0.3, y: height * 0.3))
                path.addLine(to: CGPoint(x: centerX + width * 0.2, y: 0))
                path.closeSubpath()
            }
            .fill(Color.yellow.opacity(0.4))
            .frame(width: 150, height: UIScreen.main.bounds.height)
            .blur(radius: 15)
            .scaleEffect(animate ? 1.5 : 0.8)
            .opacity(opacity * 0.8)
        }
        .onAppear {
            // Fade in quickly
            withAnimation(.easeIn(duration: 0.2)) {
                opacity = 1.0
            }
            
            // Start intense pulsing animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
            
            // Fade out after 2.8 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                withAnimation(.easeOut(duration: 0.2)) {
                    opacity = 0.0
                }
            }
        }
    }
}

#Preview {
    LightningStreakView(streakCount: 3)
        .background(Color.black.opacity(0.8))
}
