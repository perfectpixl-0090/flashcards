//
//  CharacterSelectionView.swift
//  flashcards
//
//  Created by mark on 9/11/25.
//

import SwiftUI

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        @ViewBuilder if trueTransform: (Self) -> TrueContent,
        @ViewBuilder else falseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            trueTransform(self)
        } else {
            falseTransform(self)
        }
    }
}

struct CharacterSelectionView: View {
    @ObservedObject var game: FlashcardGame
    @State private var selectedAnimal: AnimalType = .cat
    @State private var characterName: String = ""
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.blue.opacity(0.1), .purple.opacity(0.1), .pink.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 30) {
                    // Title
                    Text("Create Your Character")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                    
                    // Character Preview
                    VStack(spacing: 15) {
                        Text("Preview")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        // Character Avatar Display
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Circle()
                                        .stroke(.white.opacity(0.3), lineWidth: 3)
                                )
                                .shadow(color: .blue.opacity(0.4), radius: 10, x: 0, y: 5)
                            
                            // Animal emoji based on selection
                            Text(getAnimalEmoji(selectedAnimal))
                                .font(.system(size: 80))
                        }
                        
                        // Character name display
                        if !characterName.isEmpty {
                            Text(characterName)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    
                    // Animal Selection
                    VStack(spacing: 15) {
                        Text("Choose your character")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 15) {
                            ForEach(AnimalType.allCases, id: \.self) { animal in
                                Button(action: {
                                    selectedAnimal = animal
                                }) {
                                    VStack(spacing: 0) {
                                        Text(getAnimalEmoji(animal))
                                            .font(.system(size: 40))
                                        
                                        Text(animal.rawValue.capitalized)
                                            .font(.system(size: 10, weight: .medium, design: .rounded))
                                            .foregroundColor(.primary)
                                    }
                                    .frame(width: 60, height: 60)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(selectedAnimal == animal ? 
                                                LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                                LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                            )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(selectedAnimal == animal ? .white.opacity(0.5) : .clear, lineWidth: 2)
                                    )
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    
                    
                    // Name Input
                    VStack(spacing: 15) {
                        Text("Character Name")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        TextField("Enter name", text: $characterName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    
                    // Action Buttons
                    HStack(spacing: 20) {
                        // Cancel Button
                        Button(action: {
                            game.showCharacterSelection = false
                        }) {
                            Text("Cancel")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: 120, height: 50)
                                .background(
                                    LinearGradient(
                                        colors: [.gray, .gray.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                                .shadow(radius: 5)
                        }
                        
                        // Create Character Button
                        Button(action: {
                            createCharacter()
                        }) {
                            Text("Create")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: 120, height: 50)
                                .background(
                                    LinearGradient(
                                        colors: [.green, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                                .shadow(radius: 5)
                        }
                        .disabled(characterName.isEmpty)
                    }
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 50) // Extra padding at bottom for better scrolling
            }
        }
    }
    
    private func createCharacter() {
        game.currentAvatar = Avatar(
            name: characterName.isEmpty ? "Player" : characterName,
            animalType: selectedAnimal
        )
        game.saveGameData()
        game.showCharacterSelection = false
    }
    
    private func getAnimalEmoji(_ animal: AnimalType) -> String {
        switch animal {
        case .cat: return "🐱"
        case .dog: return "🐶"
        case .rabbit: return "🐰"
        case .bear: return "🐻"
        case .fox: return "🦊"
        case .owl: return "🦉"
        case .panda: return "🐼"
        case .tiger: return "🐯"
        case .lion: return "😊"
        case .elephant: return "💩"
        }
    }
    
    
}


