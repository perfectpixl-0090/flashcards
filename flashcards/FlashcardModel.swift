//
//  FlashcardModel.swift
//  flashcards
//
//  Created by mark on 9/9/25.
//

import Foundation
import AVFoundation
import UIKit
import AudioToolbox

enum GameMode {
    case voice
    case display
    case voiceAddition
    case displayAddition
    case voiceSubtraction
    case displaySubtraction
    case voiceMixed
    case displayMixed
}

enum OperationType: CaseIterable {
    case multiplication
    case addition
    case subtraction
}

enum AnimalType: String, CaseIterable {
    case cat = "cat"
    case dog = "dog"
    case rabbit = "rabbit"
    case bear = "bear"
    case fox = "fox"
    case owl = "owl"
    case panda = "panda"
    case tiger = "tiger"
    case lion = "lion"
    case elephant = "elephant"
}


struct Avatar {
    var name: String
    var animalType: AnimalType
}

struct Flashcard: Identifiable, Hashable {
    let id = UUID()
    let firstNumber: Int
    let secondNumber: Int
    let operation: OperationType
    let answer: Int
    
    var question: String {
        switch operation {
        case .multiplication:
            return "\(firstNumber) × \(secondNumber)"
        case .addition:
            return "\(firstNumber) + \(secondNumber)"
        case .subtraction:
            return "\(firstNumber) - \(secondNumber)"
        }
    }
    
    // Legacy properties for backward compatibility
    var multiplicand: Int { firstNumber }
    var multiplier: Int { secondNumber }
    
    init(firstNumber: Int, secondNumber: Int, operation: OperationType) {
        self.firstNumber = firstNumber
        self.secondNumber = secondNumber
        self.operation = operation
        
        switch operation {
        case .multiplication:
            self.answer = firstNumber * secondNumber
        case .addition:
            self.answer = firstNumber + secondNumber
        case .subtraction:
            self.answer = firstNumber - secondNumber
        }
    }
    
    // Legacy initializer for backward compatibility
    init(multiplicand: Int, multiplier: Int) {
        self.init(firstNumber: multiplicand, secondNumber: multiplier, operation: .multiplication)
    }
}

class FlashcardGame: ObservableObject {
    @Published var flashcards: [Flashcard] = []
    
    init() {
        loadGameData()
        loadLastGameEarnings()
        // Don't generate flashcards immediately - do it lazily when needed
    }
    
    private func ensureFlashcardsGenerated() {
        if flashcards.isEmpty {
            generateFlashcards()
        }
    }
    @Published var currentCardIndex: Int = 0
    @Published var money: Int = 0
    @Published var gameStarted: Bool = false
    @Published var gameCompleted: Bool = false
    @Published var timeElapsed: TimeInterval = 0
    @Published var showingCorrectAnswer: Bool = false
    @Published var showingIncorrectAnswer: Bool = false
    @Published var highestMoney: Int = 0
    @Published var totalMoneyEarned: Int = 0
    @Published var lastGameEarnings: Int = 0
    @Published var showFireworks: Bool = false
    @Published var showBalloons: Bool = false
    @Published var balloonCount: Int = 0
    @Published var showLightning: Bool = false
    @Published var lightningStreakCount: Int = 0
    @Published var showCenterLightning: Bool = false
    @Published var currentWinningsValue: Int = 100
    @Published var answerStartTime: Date?
    @Published var showHint: Bool = false
    @Published var showOperationMenu: Bool = false
    @Published var selectedMode: GameMode = .display
    @Published var showCharacterSelection: Bool = false
    @Published var currentAvatar: Avatar = Avatar(
        name: "Player",
        animalType: .cat
    )
    @Published var gameMode: GameMode = .voice
    @Published var answerOptions: [Int] = []
    
    private var gameTimer: Timer?
    private var startTime: Date?
    private var audioPlayer: AVAudioPlayer?
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .heavy)
    @Published var correctStreak: Int = 0
    @Published var maxCorrectStreak: Int = 0
    @Published var totalCorrectAnswers: Int = 0
    @Published var showGameStats: Bool = false
    @Published var gameCompletionTime: TimeInterval = 0
    @Published var finalAccuracy: Double = 0
    @Published var finalGrade: String = ""
    @Published var passedGame: Bool = false
    private var wrongAnswers: [Flashcard] = []
    private var wrongAnswerInsertionQueue: [Int] = []
    private var winningsTimer: Timer?
    
    var onNewHighScore: (() -> Void)?
    
    var currentCard: Flashcard? {
        ensureFlashcardsGenerated()
        guard currentCardIndex < flashcards.count else { return nil }
        return flashcards[currentCardIndex]
    }
    
    var progress: Double {
        ensureFlashcardsGenerated()
        guard !flashcards.isEmpty else { return 0 }
        return Double(currentCardIndex) / Double(flashcards.count)
    }
    
    var cardsRemaining: Int {
        ensureFlashcardsGenerated()
        return max(0, flashcards.count - currentCardIndex)
    }
    
    // Grade calculation based on accuracy
    var currentAccuracy: Double {
        guard currentCardIndex > 0 else { return 0 }
        return (Double(totalCorrectAnswers) / Double(currentCardIndex)) * 100
    }
    
    func calculateGrade(accuracy: Double) -> (grade: String, passed: Bool) {
        switch accuracy {
        case 90...100:
            return ("A", true)
        case 80..<90:
            return ("B", true)
        case 70..<80:
            return ("C", true)
        case 60..<70:
            return ("D", false)
        default:
            return ("F", false)
        }
    }
    
    private func addWrongAnswerForReuse(_ card: Flashcard) {
        // Add the wrong answer to our tracking list
        wrongAnswers.append(card)
        
        // Schedule it for insertion in the next 3-5 questions
        let insertionDelay = Int.random(in: 3...5)
        wrongAnswerInsertionQueue.append(insertionDelay)
    }
    
    private func shouldInsertWrongAnswer() -> Flashcard? {
        // Check if we have wrong answers to insert
        guard !wrongAnswers.isEmpty else { return nil }
        
        // Check if any wrong answers are ready for insertion
        for i in 0..<wrongAnswerInsertionQueue.count {
            if wrongAnswerInsertionQueue[i] <= 0 {
                // This wrong answer is ready for insertion
                let wrongAnswer = wrongAnswers.remove(at: i)
                wrongAnswerInsertionQueue.remove(at: i)
                return wrongAnswer
            }
        }
        
        return nil
    }
    
    private func decrementWrongAnswerQueue() {
        // Decrement all insertion delays
        for i in 0..<wrongAnswerInsertionQueue.count {
            wrongAnswerInsertionQueue[i] -= 1
        }
    }
    
    
    private func loadHighestMoney() {
        // This is now handled by loadGameData()
    }
    
    private func saveHighestMoney() {
        saveGameData()
    }
    
    private func loadTotalMoneyEarned() {
        // This is now handled by loadGameData()
    }
    
    private func saveTotalMoneyEarned() {
        saveGameData()
    }
    
    private func loadLastGameEarnings() {
        lastGameEarnings = UserDefaults.standard.integer(forKey: "LastGameEarnings")
    }
    
    private func saveLastGameEarnings() {
        UserDefaults.standard.set(lastGameEarnings, forKey: "LastGameEarnings")
    }
    
    private func loadMaxCorrectStreak() {
        maxCorrectStreak = UserDefaults.standard.integer(forKey: "MaxCorrectStreak")
    }
    
    private func saveMaxCorrectStreak() {
        UserDefaults.standard.set(maxCorrectStreak, forKey: "MaxCorrectStreak")
    }
    
    private func configureAudioSessionForPlayback() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.duckOthers, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("❌ DEBUG: Failed to configure audio session for playback: \(error.localizedDescription)")
        }
    }
    
    private func playAirHornAndVibrate() {
        // Trigger haptic feedback
        hapticFeedback.impactOccurred()
        
        // Ensure audio session allows playback
        configureAudioSessionForPlayback()
        
        // Play air horn sound using system sound
        AudioServicesPlaySystemSound(1016) // Air horn sound ID
    }
    
    private func playChaChingSound() {
        // Ensure audio session allows playback
        configureAudioSessionForPlayback()
        
        // Play cha-ching sound using system sound
        AudioServicesPlaySystemSound(1057) // Cash register/cha-ching sound ID
    }
    
    private func releaseBalloons() {
        // Calculate balloon count: n+1 for streak (1, 2, 3, 4, etc.)
        balloonCount = correctStreak
        showBalloons = true
        
        // Hide balloons after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            self.showBalloons = false
        }
    }
    
    private func showLightningStreak() {
        // Set lightning streak count based on current streak
        lightningStreakCount = correctStreak
        showLightning = true
        
        // Hide lightning after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.showLightning = false
        }
    }
    
    private func showCenterLightningBolt() {
        // Show center lightning bolt
        showCenterLightning = true
        
        // Vibrate phone for milestone celebration
        hapticFeedback.impactOccurred()
        
        // Hide center lightning after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.showCenterLightning = false
        }
    }
    
    private func startWinningsCountdown() {
        answerStartTime = Date()
        currentWinningsValue = 100
        
        winningsTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.answerStartTime else { return }
            
            let elapsed = Date().timeIntervalSince(startTime)
            
            // Calculate percentage: 100% to 0% over 10 seconds
            // Each 0.1 second = 1% decrease
            let percentage = max(0, 100 - Int(elapsed * 10))
            self.currentWinningsValue = percentage
        }
    }
    
    private func stopWinningsCountdown() {
        winningsTimer?.invalidate()
        winningsTimer = nil
        answerStartTime = nil
    }
    
    func stopWinningsCountdownForAnswer() {
        stopWinningsCountdown()
    }
    
    func buyHint() {
        guard let currentCard = currentCard else { return }
        
        // Check if player has enough money and it's a double digit answer
        if money >= 200 && currentCard.answer >= 10 { // $2.00 in cents
            money -= 200
            saveGameData()
            showHint = true
            
            // Play a subtle sound for hint purchase
            AudioServicesPlaySystemSound(1054) // Subtle click sound
        }
    }
    
    private func calculateWinnings() -> Int {
        // Calculate winnings based on current percentage value
        // Base winnings: $10.00 (1000 cents) for voice modes, $5.00 (500 cents) for display modes
        let baseWinnings: Int
        switch gameMode {
        case .voice, .voiceAddition, .voiceSubtraction, .voiceMixed:
            baseWinnings = 1000 // $10.00 in cents
        case .display, .displayAddition, .displaySubtraction, .displayMixed:
            baseWinnings = 500 // $5.00 in cents
        }
        let winnings = max(0, (currentWinningsValue * baseWinnings) / 100) // Minimum $0.00
        return winnings
    }
    
    func generateFlashcards() {
        var newFlashcards: [Flashcard] = []
        
        switch gameMode {
        case .voice, .display:
            // Generate all multiplication combinations from 1-12
            for multiplicand in 1...12 {
                for multiplier in 1...12 {
                    newFlashcards.append(Flashcard(firstNumber: multiplicand, secondNumber: multiplier, operation: .multiplication))
                }
            }
            
        case .voiceAddition, .displayAddition:
            // Generate addition problems with numbers 1-20
            for _ in 0..<100 {
                let firstNumber = Int.random(in: 1...20)
                let secondNumber = Int.random(in: 1...20)
                newFlashcards.append(Flashcard(firstNumber: firstNumber, secondNumber: secondNumber, operation: .addition))
            }
            
        case .voiceSubtraction, .displaySubtraction:
            // Generate subtraction problems ensuring positive results
            for _ in 0..<100 {
                let firstNumber = Int.random(in: 10...50)
                let secondNumber = Int.random(in: 1...firstNumber)
                newFlashcards.append(Flashcard(firstNumber: firstNumber, secondNumber: secondNumber, operation: .subtraction))
            }
            
        case .voiceMixed, .displayMixed:
            // Generate mixed problems with all three operations
            for _ in 0..<100 {
                let operation = OperationType.allCases.randomElement()!
                switch operation {
                case .multiplication:
                    let firstNumber = Int.random(in: 1...12)
                    let secondNumber = Int.random(in: 1...12)
                    newFlashcards.append(Flashcard(firstNumber: firstNumber, secondNumber: secondNumber, operation: .multiplication))
                case .addition:
                    let firstNumber = Int.random(in: 1...20)
                    let secondNumber = Int.random(in: 1...20)
                    newFlashcards.append(Flashcard(firstNumber: firstNumber, secondNumber: secondNumber, operation: .addition))
                case .subtraction:
                    let firstNumber = Int.random(in: 10...50)
                    let secondNumber = Int.random(in: 1...firstNumber)
                    newFlashcards.append(Flashcard(firstNumber: firstNumber, secondNumber: secondNumber, operation: .subtraction))
                }
            }
        }
        
        // Shuffle and take first 100 cards
        flashcards = Array(newFlashcards.shuffled().prefix(100))
        resetGame()
    }
    
    func startGame() {
        gameStarted = true
        gameCompleted = false
        startTime = Date()
        timeElapsed = 0
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let startTime = self.startTime {
                self.timeElapsed = Date().timeIntervalSince(startTime)
            }
        }
        
        // Generate answer options for display modes
        if gameMode == .display || gameMode == .displayAddition || gameMode == .displaySubtraction || gameMode == .displayMixed {
            generateAnswerOptions()
        }
        
        // Start the winnings countdown for the first card
        startWinningsCountdown()
    }
    
    func checkAnswer(_ userAnswer: Int) {
        guard let currentCard = currentCard else { return }
        
        if userAnswer == currentCard.answer {
            // Correct answer - calculate variable winnings
            let winnings = calculateWinnings()
            money += winnings
            totalMoneyEarned += winnings
            saveGameData()
            correctStreak += 1
            totalCorrectAnswers += 1
            
            // Update max streak if current streak is higher
            if correctStreak > maxCorrectStreak {
                maxCorrectStreak = correctStreak
                saveMaxCorrectStreak()
            }
            
            // Save total money earned
            saveTotalMoneyEarned()
            
            // Play cha-ching sound for earning money
            playChaChingSound()
            
            // Release balloons for correct answer streak
            releaseBalloons()
            
            // Show lightning for winning streaks (3+ consecutive correct answers)
            if correctStreak >= 3 {
                showLightningStreak()
            }
            
            // Show center lightning every 10 correct answers
            if totalCorrectAnswers % 10 == 0 {
                showCenterLightningBolt()
            }
            
            nextCard()
        } else {
            // Incorrect answer - don't deduct money from purse
            correctStreak = 0 // Reset streak
            showingIncorrectAnswer = true
            
            // Add wrong answer to tracking system for reuse
            addWrongAnswerForReuse(currentCard)
            
            // Play air horn sound and vibrate phone
            playAirHornAndVibrate()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.showingIncorrectAnswer = false
                self.nextCard()
            }
        }
    }
    
    func generateAnswerOptions() {
        guard let currentCard = currentCard else { return }
        let correctAnswer = currentCard.answer
        
        // Generate 3 wrong answers close to the correct answer
        var wrongAnswers: Set<Int> = []
        
        while wrongAnswers.count < 3 {
            let variation = Int.random(in: 1...5)
            let isPositive = Bool.random()
            let wrongAnswer = isPositive ? correctAnswer + variation : correctAnswer - variation
            
            // Make sure wrong answer is positive and different from correct answer
            if wrongAnswer > 0 && wrongAnswer != correctAnswer {
                wrongAnswers.insert(wrongAnswer)
            }
        }
        
        // Combine correct answer with wrong answers and shuffle
        answerOptions = ([correctAnswer] + Array(wrongAnswers)).shuffled()
    }
    
    func startGame(mode: GameMode) {
        gameMode = mode
        generateFlashcards()
        startGame()
    }
    
    func nextCard() {
        // Stop the current winnings countdown
        stopWinningsCountdown()
        
        // Reset hint state for new card
        showHint = false
        
        // Decrement wrong answer insertion queue
        decrementWrongAnswerQueue()
        
        // Check if we should insert a wrong answer (only if we haven't reached 100 questions)
        if let wrongAnswer = shouldInsertWrongAnswer(), flashcards.count < 100 {
            // Insert the wrong answer at the current position
            flashcards.insert(wrongAnswer, at: currentCardIndex)
        }
        
        currentCardIndex += 1
        
        // End game at exactly 100 questions or when we've gone through all cards
        if currentCardIndex >= 100 || currentCardIndex >= flashcards.count {
            endGame()
        } else {
            // Generate answer options for display modes
            if gameMode == .display || gameMode == .displayAddition || gameMode == .displaySubtraction || gameMode == .displayMixed {
                generateAnswerOptions()
            }
            
            // Start countdown for the new card
            startWinningsCountdown()
        }
    }
    
    func endGame() {
        gameCompleted = true
        gameStarted = false
        gameTimer?.invalidate()
        gameTimer = nil
        
        // Calculate final stats
        gameCompletionTime = timeElapsed
        finalAccuracy = currentAccuracy
        let gradeResult = calculateGrade(accuracy: finalAccuracy)
        finalGrade = gradeResult.grade
        passedGame = gradeResult.passed
        
        // Save last game earnings
        lastGameEarnings = money
        saveLastGameEarnings()
        
        // Check for new high money
        if money > highestMoney {
            highestMoney = money
            saveHighestMoney()
            showFireworks = true
            onNewHighScore?()
            
            // Hide fireworks after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.showFireworks = false
            }
        }
        
        // Show game stats after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showGameStats = true
        }
    }
    
    func resetGame() {
        currentCardIndex = 0
        money = 0
        gameStarted = false
        gameCompleted = false
        timeElapsed = 0
        showingCorrectAnswer = false
        showingIncorrectAnswer = false
        correctStreak = 0
        totalCorrectAnswers = 0
        showBalloons = false
        balloonCount = 0
        showLightning = false
        showCenterLightning = false
        currentWinningsValue = 100
        showHint = false
        showGameStats = false
        gameCompletionTime = 0
        finalAccuracy = 0
        finalGrade = ""
        passedGame = false
        wrongAnswers.removeAll()
        wrongAnswerInsertionQueue.removeAll()
        gameTimer?.invalidate()
        gameTimer = nil
        startTime = nil
        stopWinningsCountdown()
    }
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Persistence Functions
    
    func saveGameData() {
        let defaults = UserDefaults.standard
        
        // Save character information
        defaults.set(currentAvatar.name, forKey: "savedCharacterName")
        defaults.set(currentAvatar.animalType.rawValue, forKey: "savedCharacterAnimalType")
        
        // Save money information
        defaults.set(money, forKey: "savedMoney")
        defaults.set(highestMoney, forKey: "savedHighestMoney")
        defaults.set(totalMoneyEarned, forKey: "savedTotalMoneyEarned")
        
        // Save streak information
        defaults.set(maxCorrectStreak, forKey: "savedMaxCorrectStreak")
    }
    
    func loadGameData() {
        let defaults = UserDefaults.standard
        
        // Load character information
        let savedName = defaults.string(forKey: "savedCharacterName") ?? "Player"
        let savedAnimalTypeRaw = defaults.string(forKey: "savedCharacterAnimalType") ?? "cat"
        let savedAnimalType = AnimalType(rawValue: savedAnimalTypeRaw) ?? .cat
        
        currentAvatar = Avatar(name: savedName, animalType: savedAnimalType)
        
        // Load money information
        money = defaults.integer(forKey: "savedMoney")
        highestMoney = defaults.integer(forKey: "savedHighestMoney")
        totalMoneyEarned = defaults.integer(forKey: "savedTotalMoneyEarned")
        
        // Load streak information
        maxCorrectStreak = defaults.integer(forKey: "savedMaxCorrectStreak")
    }
}
