import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var game = FlashcardGame()
    @StateObject private var voiceManager = VoiceRecognitionManager()
    @State private var showingGameOver = false
    @State private var hasAnsweredCurrentCard = false
    
    var body: some View {
        ZStack {
            // Modern gradient background
            if game.showingIncorrectAnswer {
                LinearGradient(
                    colors: [Color.purple.opacity(0.8), Color.red.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            } else if game.showingCorrectAnswer {
                LinearGradient(
                    colors: [Color.green.opacity(0.8), Color.blue.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            } else {
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1), Color.pink.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            
            VStack(spacing: 20) {
                if game.showOperationMenu {
                    // Operation Selection Menu
                    VStack(spacing: 30) {
                        Text("Choose Your Kung Fu")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .pink, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 20)
                        
                        VStack(spacing: 20) {
                            // Addition
                            Button(action: {
                                let finalMode: GameMode = game.selectedMode == .display ? .displayAddition : .voiceAddition
                                startGame(mode: finalMode)
                                game.showOperationMenu = false
                            }) {
                                HStack(spacing: 15) {
                                    Text("+")
                                        .font(.system(size: 40, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Text("Addition")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                .frame(width: 250, height: 60)
                                .background(
                                    LinearGradient(
                                        colors: [.green, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(30)
                                .shadow(color: .green.opacity(0.4), radius: 10, x: 0, y: 5)
                            }
                            
                            // Subtraction
                            Button(action: {
                                let finalMode: GameMode = game.selectedMode == .display ? .displaySubtraction : .voiceSubtraction
                                startGame(mode: finalMode)
                                game.showOperationMenu = false
                            }) {
                                HStack(spacing: 15) {
                                    Text("−")
                                        .font(.system(size: 40, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Text("Subtraction")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                .frame(width: 250, height: 60)
                                .background(
                                    LinearGradient(
                                        colors: [.teal, .cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(30)
                                .shadow(color: .teal.opacity(0.4), radius: 10, x: 0, y: 5)
                            }
                            
                            // Multiplication
                            Button(action: {
                                let finalMode: GameMode = game.selectedMode == .display ? .display : .voice
                                startGame(mode: finalMode)
                                game.showOperationMenu = false
                            }) {
                                HStack(spacing: 15) {
                                    Text("×")
                                        .font(.system(size: 40, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Text("Multiplication")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                .frame(width: 250, height: 60)
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(30)
                                .shadow(color: .blue.opacity(0.4), radius: 10, x: 0, y: 5)
                            }
                            
                            // Expert Mode
                            Button(action: {
                                let finalMode: GameMode = game.selectedMode == .display ? .displayMixed : .voiceMixed
                                startGame(mode: finalMode)
                                game.showOperationMenu = false
                            }) {
                                HStack(spacing: 15) {
                                    Text("±×")
                                        .font(.system(size: 40, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Text("Expert Mode")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                .frame(width: 250, height: 60)
                                .background(
                                    LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(30)
                                .shadow(color: .orange.opacity(0.4), radius: 10, x: 0, y: 5)
                            }
                        }
                        
                        // Back button
                        Button(action: {
                            game.showOperationMenu = false
                        }) {
                            Text("Back")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: 100, height: 40)
                                .background(Color.gray.opacity(0.7))
                                .cornerRadius(20)
                        }
                    }
                } else if !game.gameStarted {
                    // Start screen
                    VStack(spacing: 30) {
                        // Modern gradient title
                        VStack(spacing: 12) {
                            VStack(spacing: 4) {
                                Text("Mathing My Math")
                                    .font(.system(size: 36, weight: .black, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.purple, .pink, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .multilineTextAlignment(.center)
                                
                                Text("Flash Cards")
                                    .font(.system(size: 36, weight: .black, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.purple, .pink, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .multilineTextAlignment(.center)
                            }
                                .padding(.bottom, 20)
                            
                            HStack(spacing: 30) {
                                // Display Mode
                                Button(action: {
                                    game.selectedMode = .display
                                    game.showOperationMenu = true
                                }) {
                                    VStack(spacing: 12) {
                                        Image(systemName: "grid.circle.fill")
                                            .font(.system(size: 50))
                                            .foregroundColor(.white)
                                        
                                        Text("Display")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 120, height: 120)
                                    .background(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(25)
                                    .shadow(color: .blue.opacity(0.4), radius: 15, x: 0, y: 8)
                                }
                                
                                // Voice Mode
                                Button(action: {
                                    game.selectedMode = .voice
                                    game.showOperationMenu = true
                                }) {
                                    VStack(spacing: 12) {
                                        Image(systemName: "mic.circle.fill")
                                            .font(.system(size: 50))
                                            .foregroundColor(.white)
                                        
                                        Text("Voice")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 120, height: 120)
                                    .background(
                                        LinearGradient(
                                            colors: [.purple, .pink],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(25)
                                    .shadow(color: .purple.opacity(0.4), radius: 15, x: 0, y: 8)
                                }
                            }
                            .frame(width: 0.0)
                        }
                        
            // Money Display
            VStack(spacing: 15) {
                // Total Money Earned - Purse only
                PurseView(money: game.totalMoneyEarned)
                
                // Last Game Earnings
                VStack(spacing: 10) {
                    Text("Last Game Earnings")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text(formatMoney(game.lastGameEarnings))
                        .font(.custom("Komika", size: 48))
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(15)
            .shadow(radius: 5)
            
            // Character and Shop buttons
            HStack(spacing: 20) {
                // Character button
                Button(action: {
                    game.showCharacterSelection = true
                }) {
                    VStack(spacing: 8) {
                        // Show character avatar or default icon
                        if game.currentAvatar.name != "Player" || game.currentAvatar.animalType != .cat {
                            Text(getAnimalEmoji(game.currentAvatar.animalType))
                                .font(.system(size: 50))
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                        
                        Text(game.currentAvatar.name == "Player" ? "Select Character" : game.currentAvatar.name)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(width: 120, height: 100)
                    .background(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                
                // Shop button
                Button(action: {
                    // TODO: Implement shop
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "cart.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                        
                        Text("Shop")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(width: 120, height: 100)
                    .background(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: .orange.opacity(0.4), radius: 10, x: 0, y: 5)
                }
            }
                    }
                    
                    // Exit button - bottom left (main screen only)
                    VStack {
                        Spacer()
                        HStack {
                            Button(action: {
                                exit(0)
                            }) {
                                Text("Exit Game")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.red)
                                    .cornerRadius(8)
                            }
                            .padding(.leading, 20)
                            .padding(.bottom, 20)
                            Spacer()
                        }
                    }
                } else if game.gameCompleted {
                    // Game completion stats screen
                    if game.showGameStats {
                        // Comprehensive stats screen
                        VStack(spacing: 25) {
                            // Congratulations header
                            VStack(spacing: 10) {
                                Text("🎉 Congratulations! 🎉")
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.purple, .pink, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                Text("You completed 100 questions!")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Grade and Pass/Fail
                            VStack(spacing: 15) {
                                // Grade display
                                HStack(spacing: 20) {
                                    VStack(spacing: 5) {
                                        Text("Grade")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        
                                        Text(game.finalGrade)
                                            .font(.system(size: 48, weight: .black, design: .rounded))
                                            .foregroundColor(gradeColor(game.finalGrade))
                                            .shadow(color: gradeColor(game.finalGrade).opacity(0.6), radius: 3, x: 2, y: 2)
                                    }
                                    
                                    VStack(spacing: 5) {
                                        Text("Result")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        
                                        Text(game.passedGame ? "PASS" : "FAIL")
                                            .font(.system(size: 32, weight: .black, design: .rounded))
                                            .foregroundColor(game.passedGame ? .green : .red)
                                            .shadow(color: game.passedGame ? Color.green.opacity(0.6) : Color.red.opacity(0.6), radius: 3, x: 2, y: 2)
                                    }
                                }
                                
                                // Accuracy percentage
                                Text("\(String(format: "%.1f", game.finalAccuracy))% Accuracy")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }
                            
                            // Stats grid
                            VStack(spacing: 15) {
                                HStack(spacing: 30) {
                                    StatCard(title: "Time", value: formatTime(game.gameCompletionTime), color: .blue)
                                    StatCard(title: "Correct", value: "\(game.totalCorrectAnswers)/100", color: .green)
                                }
                                
                                HStack(spacing: 30) {
                                    StatCard(title: "Earnings", value: formatMoney(game.money), color: .orange)
                                    StatCard(title: "Max Streak", value: "\(game.maxCorrectStreak)", color: .purple)
                                }
                            }
                            
                            // Action buttons
                            VStack(spacing: 15) {
                                Text("Choose your next action:")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 5)
                                
                                Button(action: {
                                    game.resetGame()
                                }) {
                                    Text("Play Again")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(width: 200, height: 50)
                                        .background(
                                            LinearGradient(
                                                colors: [.blue, .purple],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(25)
                                        .shadow(color: .blue.opacity(0.4), radius: 10, x: 0, y: 5)
                                }
                                
                                Button(action: {
                                    game.resetGame()
                                    game.gameCompleted = false
                                }) {
                                    Text("Main Menu")
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                        .frame(width: 150, height: 40)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.95))
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding()
                    } else {
                        // Loading state while calculating stats
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                            
                            Text("Calculating your results...")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    // Game screen
                    VStack(spacing: 20) {
                        // Show "Wrong" at top when incorrect answer
                        if game.showingIncorrectAnswer {
                            Text("Wrong")
                                .font(.custom("Komika", size: 48))
                                .foregroundColor(.red)
                                .shadow(color: Color.red.opacity(0.6), radius: 3, x: 2, y: 2)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Top bar with winnings countdown and money (hidden on incorrect screen)
                        if !game.showingIncorrectAnswer {
                        HStack {
                            // Avatar and Winnings countdown timer
                            HStack(spacing: 15) {
                                // Avatar display
                                VStack(spacing: 5) {
                                    Text(getAnimalEmoji(game.currentAvatar.animalType))
                                        .font(.system(size: 60))
                                    
                                    Text(game.currentAvatar.name)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                
                                // Winnings countdown timer - Circular progress
                                VStack(spacing: 5) {
                                    ZStack {
                                        // Background circle
                                        Circle()
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                                            .frame(width: 80, height: 80)
                                        
                                        // Progress circle
                                        Circle()
                                            .trim(from: 0, to: CGFloat(game.currentWinningsValue) / 100.0)
                                            .stroke(
                                                game.currentWinningsValue >= 75 ? Color.green : 
                                                game.currentWinningsValue >= 50 ? Color.orange : Color.red,
                                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                            )
                                            .frame(width: 80, height: 80)
                                            .rotationEffect(.degrees(-90))
                                        
                                        // Money amount text in center
                                        Text(formatMoney(max(0, (game.currentWinningsValue * (game.gameMode == .voice || game.gameMode == .voiceAddition || game.gameMode == .voiceSubtraction || game.gameMode == .voiceMixed ? 1000 : 500)) / 100)))
                                            .font(.custom("Komika", size: 20))
                                            .fontWeight(.bold)
                                            .foregroundColor(game.currentWinningsValue >= 75 ? .green : 
                                                           game.currentWinningsValue >= 50 ? .orange : .red)
                                    }
                                    
                                    Text("Winnings")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            // Purse and winning streak
                            HStack(spacing: 15) {
                                // Winning streak display
                                VStack(spacing: 5) {
                                    HStack(spacing: 2) {
                                        Text("⚡")
                                            .font(.caption)
                                        Text("Streak")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    // Max streak (smaller, above current)
                                    if game.maxCorrectStreak > 0 {
                                        Text("Max: \(game.maxCorrectStreak)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    // Current streak
                                    Text("\(game.correctStreak)")
                                        .font(.custom("Komika", size: 24))
                                        .fontWeight(.bold)
                                        .foregroundColor(game.correctStreak >= 3 ? .orange : .primary)
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle()
                                                .fill(game.correctStreak >= 3 ? Color.orange.opacity(0.2) : Color.gray.opacity(0.1))
                                        )
                                }
                                
                                // Purse icon
                                PurseView(money: game.money)
                            }
                        }
                        .padding(.horizontal)
                        }
                        
                        // Timer row - centered (hidden on incorrect screen)
                        if !game.showingIncorrectAnswer {
                        HStack {
                            Spacer()
                            
                            Text("Time: \(formatTime(game.timeElapsed))")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        }
                        
                        // Status bar - questions answered and accuracy
                        HStack {
                            Spacer()
                            VStack(spacing: 2) {
                                Text("\(game.currentCardIndex) of \(game.flashcards.count) questions answered")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                                
                                if game.currentCardIndex > 0 {
                                    let accuracy = Int((Double(game.totalCorrectAnswers) / Double(game.currentCardIndex)) * 100)
                                    Text("\(accuracy)% correct")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(accuracy >= 80 ? .green : accuracy >= 60 ? .orange : .red)
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // Progress bar
                        ProgressView(value: Double(game.currentCardIndex), total: Double(game.flashcards.count))
                            .progressViewStyle(LinearProgressViewStyle())
                            .padding(.horizontal)
                        
                        // Flashcard
                        if let currentCard = game.currentCard {
                            VStack(spacing: 20) {
                                Text(currentCard.question)
                                    .font(.system(size: 72, weight: .black, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                if game.showingIncorrectAnswer {
                                    // Show correct answer when wrong
                                    Text("= \(currentCard.answer)")
                                        .font(.system(size: 80, weight: .bold))
                                        .foregroundColor(.black)
                                } else if game.showHint && currentCard.answer >= 10 {
                                    // Show hint: first digit + ?
                                    let firstDigit = currentCard.answer / 10
                                    Text("= \(firstDigit)?")
                                        .font(.system(size: 40, weight: .medium))
                                        .foregroundColor(.blue)
                                } else {
                                    // Show recognized number or question mark
                                    if !voiceManager.recognizedNumber.isEmpty {
                                        Text("= \(voiceManager.recognizedNumber)")
                                            .font(.system(size: 40, weight: .medium))
                                            .foregroundColor(.black)
                                    } else {
                                        Text("= ?")
                                            .font(.system(size: 40, weight: .medium))
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(30)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                            )
                            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                        }
                        
                        // Voice recognition status (only for voice modes, hidden on incorrect screen)
                        if !game.showingIncorrectAnswer && (game.gameMode == .voice || game.gameMode == .voiceAddition || game.gameMode == .voiceSubtraction || game.gameMode == .voiceMixed) {
                            Text(voiceManager.isListening ? "Listening" : "Not listening")
                                .font(.headline)
                                .foregroundColor(voiceManager.isListening ? .red : .gray)
                        }
                        
                        // Skip button
                        if !hasAnsweredCurrentCard && !game.showingIncorrectAnswer {
                            Button(action: {
                                if game.money >= 200 { // $2.00 in cents
                                    skipCurrentCard()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "forward.fill")
                                        .font(.system(size: 16, weight: .bold))
                                    Text("Skip Card ($2)")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            game.money >= 200 ? 
                                                LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing) :
                                                LinearGradient(colors: [.gray, .gray.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                                .shadow(color: game.money >= 200 ? .orange.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                            }
                            .disabled(game.money < 200)
                        }
                        
                        // Hint button (only in voice mode)
                        if !hasAnsweredCurrentCard && !game.showingIncorrectAnswer, let currentCard = game.currentCard, currentCard.answer >= 10, (game.gameMode == .voice || game.gameMode == .voiceAddition || game.gameMode == .voiceSubtraction || game.gameMode == .voiceMixed) {
                            Button(action: {
                                if game.money >= 200 { // $2.00 in cents
                                    game.buyHint()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: 16, weight: .bold))
                                    Text("Buy Hint ($2)")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            game.money >= 200 ? 
                                                LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing) :
                                                LinearGradient(colors: [.gray, .gray.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                                .shadow(color: game.money >= 200 ? .blue.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                            }
                            .disabled(game.money < 200)
                        }
                        
                        // Voice Recognition Button
                        if !hasAnsweredCurrentCard {
                        if game.gameMode == .voice || game.gameMode == .voiceAddition || game.gameMode == .voiceSubtraction || game.gameMode == .voiceMixed {
                            // Modern Voice Recognition Button
                            VStack(spacing: 15) {
                                Image(systemName: voiceManager.isListening ? "mic.fill" : "mic")
                                    .font(.system(size: 50, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(voiceManager.isListening ? "Listening..." : "Tap or Hold to Speak")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 10)
                            }
                            .frame(width: 150, height: 150)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: voiceManager.isListening ? 
                                                [.red, .orange] : 
                                                [.green, .blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(.white.opacity(0.3), lineWidth: 3)
                                    )
                            )
                            .shadow(
                                color: voiceManager.isListening ? .red.opacity(0.4) : .green.opacity(0.4), 
                                radius: 15, 
                                x: 0, 
                                y: 8
                            )
                            .onTapGesture {
                                if voiceManager.isListening {
                                    voiceManager.stopListening()
                                } else {
                                    // Stop winnings countdown when starting to listen
                                    game.stopWinningsCountdownForAnswer()
                                    voiceManager.startListening()
                                }
                            }
                            .onLongPressGesture(minimumDuration: 0.1) {
                                if !voiceManager.isListening {
                                    // Stop winnings countdown when starting to listen
                                    game.stopWinningsCountdownForAnswer()
                                    voiceManager.startListening()
                                }
                            }
                        } else {
                            // Display Mode - Answer Grid (hidden when showing incorrect answer)
                            if !game.showingIncorrectAnswer {
                                AnswerGridView(
                                    answerOptions: game.answerOptions,
                                    onAnswerSelected: { answer in
                                        game.checkAnswer(answer)
                                    }
                                )
                            }
                        }
                        }
                    }
                }
            }
            .padding()
            
            // Exit button - bottom left (only show during game, not on main screen or incorrect screen)
            if game.gameStarted && !game.showingIncorrectAnswer {
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            resetGame()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.red)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .padding(.leading, 20)
                        .padding(.bottom, 20)
                        Spacer()
                    }
                }
            }
            
            // Fireworks overlay
            if game.showFireworks {
                FireworksView()
                    .allowsHitTesting(false)
            }
            
            // Balloons overlay
            if game.showBalloons {
                BalloonReleaseView(balloonCount: game.balloonCount)
                    .allowsHitTesting(false)
            }
            
            // Lightning streak overlay
            if game.showLightning {
                LightningStreakView(streakCount: game.lightningStreakCount)
                    .allowsHitTesting(false)
            }
            
            // Center lightning overlay (every 10 correct answers)
            if game.showCenterLightning {
                CenterLightningView()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            setupVoiceRecognitionCallback()
        }
        .onChange(of: game.currentCardIndex) { _ in
            startVoiceRecognitionForNewCard()
        }
        .onChange(of: game.gameStarted) { _ in
            if game.gameStarted {
                hasAnsweredCurrentCard = false
                startVoiceRecognitionForNewCard()
            }
        }
        .sheet(isPresented: $game.showCharacterSelection) {
            CharacterSelectionView(game: game)
        }
        .preferredColorScheme(.light) // Force light mode throughout the app
    }
    
    private func startGame(mode: GameMode) {
        game.startGame(mode: mode)
        if mode == .voice {
            checkMicrophonePermission()
        }
    }
    
    private func resetGame() {
        game.resetGame()
        hasAnsweredCurrentCard = false
        voiceManager.stopListening()
    }
    
    private func checkMicrophonePermission() {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if !granted {
                        voiceManager.errorMessage = "Microphone permission denied"
                    }
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if !granted {
                        voiceManager.errorMessage = "Microphone permission denied"
                    }
                }
            }
        }
    }
    
    private func setupVoiceRecognitionCallback() {
        voiceManager.onNumberRecognized = { recognizedNumber in
            // Mark that we've answered this card
            hasAnsweredCurrentCard = true
            
            // Check the answer
            game.checkAnswer(recognizedNumber)
        }
    }
    
    private func startVoiceRecognitionForNewCard() {
        // Reset voice recognition state for new card
        voiceManager.clearRecognizedText()
        hasAnsweredCurrentCard = false
        
        // Don't automatically start listening - user must press the button
    }
    
    private func skipCurrentCard() {
        // Mark that we've answered this card and stop listening
        hasAnsweredCurrentCard = true
        voiceManager.stopListening()
        
        // Deduct $2.00 and move to next card
        game.money = max(0, game.money - 200) // $2.00 in cents
        game.saveGameData()
        game.nextCard()
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func formatMoney(_ cents: Int) -> String {
        let dollars = cents / 100
        let remainingCents = cents % 100
        return String(format: "$%d.%02d", dollars, remainingCents)
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
    
    
    private func gradeColor(_ grade: String) -> Color {
        switch grade {
        case "A": return .green
        case "B": return .blue
        case "C": return .orange
        case "D": return .red
        case "F": return .red
        default: return .gray
        }
    }
}

// StatCard view for displaying individual statistics
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(width: 120, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(color.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

#Preview {
    ContentView()
}
