//
//  AnswerGridView.swift
//  flashcards
//
//  Created by mark on 9/9/25.
//

import SwiftUI

struct AnswerGridView: View {
    let answerOptions: [Int]
    let onAnswerSelected: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            // Top row
            HStack(spacing: 10) {
                AnswerButton(
                    answer: answerOptions[0],
                    onTap: { onAnswerSelected(answerOptions[0]) }
                )
                
                AnswerButton(
                    answer: answerOptions[1],
                    onTap: { onAnswerSelected(answerOptions[1]) }
                )
            }
            
            // Bottom row
            HStack(spacing: 10) {
                AnswerButton(
                    answer: answerOptions[2],
                    onTap: { onAnswerSelected(answerOptions[2]) }
                )
                
                AnswerButton(
                    answer: answerOptions[3],
                    onTap: { onAnswerSelected(answerOptions[3]) }
                )
            }
        }
        .padding()
    }
}

struct AnswerButton: View {
    let answer: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text("\(answer)")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 90, height: 90)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(.white.opacity(0.3), lineWidth: 2)
                        )
                )
                .shadow(color: .blue.opacity(0.4), radius: 10, x: 0, y: 5)
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: answer)
    }
}

#Preview {
    AnswerGridView(
        answerOptions: [12, 15, 18, 21],
        onAnswerSelected: { _ in }
    )
}
