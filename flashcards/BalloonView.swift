//
//  BalloonView.swift
//  flashcards
//
//  Created by mark on 9/9/25.
//

import SwiftUI

struct BalloonView: View {
    let color: Color
    let delay: Double
    @State private var animate = false
    
    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [color, color.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 80, height: 100)
            .overlay(
                // Balloon string
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 4, height: 50)
                    .offset(y: 50)
            )
            .offset(
                x: animate ? CGFloat.random(in: -100...100) : 0,
                y: animate ? -UIScreen.main.bounds.height - 200 : 0
            )
            .opacity(animate ? 0 : 1)
            .scaleEffect(animate ? 0.5 : 1.0)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeOut(duration: 3.0)) {
                        animate = true
                    }
                }
            }
    }
}

struct BalloonReleaseView: View {
    let balloonCount: Int
    @State private var showBalloons = false
    
    private let balloonColors: [Color] = [
        .red, .blue, .green, .yellow, .orange, .purple, .pink, .cyan
    ]
    
    var body: some View {
        ZStack {
            ForEach(0..<balloonCount, id: \.self) { index in
                BalloonView(
                    color: balloonColors[index % balloonColors.count],
                    delay: Double(index) * 0.1
                )
                .position(
                    x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                    y: UIScreen.main.bounds.height - 100
                )
            }
        }
        .onAppear {
            showBalloons = true
        }
    }
}

#Preview {
    BalloonReleaseView(balloonCount: 5)
        .background(Color.blue.opacity(0.1))
}
