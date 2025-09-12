//
//  FireworksView.swift
//  flashcards
//
//  Created by mark on 9/9/25.
//

import SwiftUI

struct FireworksView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Multiple firework bursts
            ForEach(0..<8, id: \.self) { index in
                FireworkBurst(
                    delay: Double(index) * 0.3,
                    position: CGPoint(
                        x: CGFloat.random(in: 0.2...0.8),
                        y: CGFloat.random(in: 0.2...0.8)
                    )
                )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct FireworkBurst: View {
    let delay: Double
    let position: CGPoint
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [.red, .orange, .yellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: animate ? 200 : 0, height: animate ? 200 : 0)
                .opacity(animate ? 0 : 1)
                .position(
                    x: position.x * UIScreen.main.bounds.width,
                    y: position.y * UIScreen.main.bounds.height
                )
            
            // Inner burst
            ForEach(0..<12, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.yellow, .orange, .red],
                            startPoint: .center,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 8, height: 8)
                    .offset(
                        x: animate ? cos(Double(index) * .pi / 6) * 80 : 0,
                        y: animate ? sin(Double(index) * .pi / 6) * 80 : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .position(
                        x: position.x * UIScreen.main.bounds.width,
                        y: position.y * UIScreen.main.bounds.height
                    )
            }
            
            // Center explosion
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white, .yellow, .orange, .red],
                        center: .center,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .frame(width: animate ? 60 : 0, height: animate ? 60 : 0)
                .opacity(animate ? 0 : 1)
                .position(
                    x: position.x * UIScreen.main.bounds.width,
                    y: position.y * UIScreen.main.bounds.height
                )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: 1.5)) {
                    animate = true
                }
            }
        }
    }
}

#Preview {
    FireworksView()
        .background(Color.black)
}
