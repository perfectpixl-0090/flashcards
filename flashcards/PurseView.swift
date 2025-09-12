//
//  PurseView.swift
//  flashcards
//
//  Created by mark on 9/9/25.
//

import SwiftUI

struct PurseView: View {
    let money: Int
    @State private var animate = false
    
    private func formatMoney(_ cents: Int) -> String {
        let dollars = cents / 100
        let remainingCents = cents % 100
        return String(format: "$%d.%02d", dollars, remainingCents)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Purse icon
            ZStack {
                // Purse body
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [Color.brown.opacity(0.8), Color.brown.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 60, height: 40)
                    .overlay(
                        // Purse flap
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.brown.opacity(0.9))
                            .frame(width: 50, height: 15)
                            .offset(y: -8)
                    )
                    .overlay(
                        // Purse handle
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.brown.opacity(0.9))
                            .frame(width: 20, height: 4)
                            .offset(y: -20)
                    )
                    .overlay(
                        // Money symbol
                        Text("$")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.yellow)
                            .offset(y: 2)
                    )
                    .scaleEffect(animate ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: animate)
            }
            
            // Money amount
            Text(formatMoney(money))
                .font(.custom("Komika", size: 18))
                .fontWeight(.bold)
                .foregroundColor(.green)
                .shadow(color: Color.green.opacity(0.6), radius: 2, x: 1, y: 1)
        }
        .onChange(of: money) { _ in
            // Animate when money changes
            animate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animate = false
            }
        }
    }
}

#Preview {
    PurseView(money: 150)
        .padding()
        .background(Color.blue.opacity(0.1))
}
