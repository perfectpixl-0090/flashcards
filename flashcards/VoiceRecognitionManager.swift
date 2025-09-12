import Foundation
import Speech
import AVFoundation
import AudioToolbox
import UIKit

class VoiceRecognitionManager: NSObject, ObservableObject {
    @Published var isListening = false
    @Published var recognizedText = ""
    @Published var recognizedNumber: String = ""
    @Published var errorMessage: String?
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    
    private let speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var recognitionTimeout: Timer?
    
    var onNumberRecognized: ((Int) -> Void)?
    
    override init() {
        super.init()
        requestPermissions()
    }
    
    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                self?.authorizationStatus = authStatus
            }
        }
    }
    
    func startListening() {
        print("🎤 DEBUG: startListening() called")
        guard authorizationStatus == .authorized else {
            print("🎤 DEBUG: Speech recognition not authorized")
            errorMessage = "Speech recognition not authorized"
            return
        }
        
        guard !isListening else { 
            print("🎤 DEBUG: Already listening, returning")
            return 
        }
        print("🎤 DEBUG: Starting speech recognition setup")
        
        // Configure audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("✅ DEBUG: Audio session configured successfully")
        } catch {
            print("❌ DEBUG: Audio session setup failed: \(error.localizedDescription)")
            errorMessage = "Audio session setup failed: \(error.localizedDescription)"
            return
        }
        
        // Stop any existing recognition
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("❌ DEBUG: Unable to create recognition request")
            errorMessage = "Unable to create recognition request"
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Add contextual strings to help with number recognition
        recognitionRequest.contextualStrings = [
            "1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
            "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
            "21", "22", "23", "24", "25", "26", "27", "28", "29", "30",
            "31", "32", "33", "34", "35", "36", "37", "38", "39", "40",
            "41", "42", "43", "44", "45", "46", "47", "48", "49", "50",
            "51", "52", "53", "54", "55", "56", "57", "58", "59", "60",
            "61", "62", "63", "64", "65", "66", "67", "68", "69", "70",
            "71", "72", "73", "74", "75", "76", "77", "78", "79", "80",
            "81", "82", "83", "84", "85", "86", "87", "88", "89", "90",
            "91", "92", "93", "94", "95", "96", "97", "98", "99", "100",
            "101", "102", "103", "104", "105", "106", "107", "108", "109", "110",
            "111", "112", "113", "114", "115", "116", "117", "118", "119", "120",
            "121", "122", "123", "124", "125", "126", "127", "128", "129", "130",
            "131", "132", "133", "134", "135", "136", "137", "138", "139", "140",
            "141", "142", "143", "144"
        ]
        
        // Configure audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        // Start audio engine
        do {
            try audioEngine.start()
            isListening = true
            
            // Play start listening sound
            playStartListeningSound()
            
            // Set up a 2.3-second timeout to automatically stop listening
            recognitionTimeout = Timer.scheduledTimer(withTimeInterval: 2.3, repeats: false) { [weak self] _ in
                print("⏰ DEBUG: 2.3-second timeout reached, processing final result")
                self?.processFinalResult()
            }
            
            print("✅ DEBUG: Audio engine started successfully")
        } catch {
            print("❌ DEBUG: Audio engine start failed: \(error.localizedDescription)")
            errorMessage = "Audio engine start failed: \(error.localizedDescription)"
            return
        }
        
        // Start recognition
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let result = result {
                    let text = result.bestTranscription.formattedString
                    print("🎤 DEBUG: Recognized text: '\(text)'")
                    self.recognizedText = text
                    
                    // Extract numeric value for display
                    if let number = self.extractNumber(from: text) {
                        self.recognizedNumber = String(number)
                    } else {
                        self.recognizedNumber = ""
                    }
                    
                    // If this is a final result, process it immediately
                    if result.isFinal {
                        print("✅ DEBUG: Final result received, processing")
                        self.processFinalResult()
                    }
                }
                
                if let error = error {
                    print("❌ DEBUG: Recognition error: \(error.localizedDescription)")
                    self.errorMessage = "Recognition error: \(error.localizedDescription)"
                    self.stopListening()
                }
            }
        }
        
        print("✅ DEBUG: Speech recognition started successfully")
    }
    
    func stopListening() {
        print("🛑 DEBUG: stopListening() called")
        
        recognitionTimeout?.invalidate()
        recognitionTimeout = nil
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        isListening = false
        
        // Play stop listening sound
        playStopListeningSound()
        
        print("✅ DEBUG: Speech recognition stopped")
    }
    
    private func processFinalResult() {
        print("🔍 DEBUG: Processing final result: '\(recognizedText)'")
        
        let number = extractNumber(from: recognizedText)
        print("🔢 DEBUG: Extracted number: \(number ?? -1)")
        
        if let number = number {
            print("✅ DEBUG: Valid number found: \(number)")
            onNumberRecognized?(number)
        } else {
            print("❌ DEBUG: No valid number found in: '\(recognizedText)'")
            errorMessage = "No valid number found"
        }
        
        stopListening()
    }
    
    private func extractNumber(from text: String) -> Int? {
        let cleanText = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        print("🔍 DEBUG: Extracting number from: '\(cleanText)'")
        
        // First, try to find numeric digits
        let digitPattern = "\\d+"
        if let range = cleanText.range(of: digitPattern, options: .regularExpression) {
            let digitString = String(cleanText[range])
            if let number = Int(digitString) {
                print("✅ DEBUG: Found numeric digits: \(number)")
                return number
            }
        }
        
        // Fallback to basic word-to-number conversion
        return basicWordToNumber(cleanText)
    }
    
    private func basicWordToNumber(_ text: String) -> Int? {
        let numberWords: [String: Int] = [
            "zero": 0, "one": 1, "two": 2, "three": 3, "four": 4,
            "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9,
            "ten": 10, "eleven": 11, "twelve": 12, "thirteen": 13, "fourteen": 14,
            "fifteen": 15, "sixteen": 16, "seventeen": 17, "eighteen": 18, "nineteen": 19,
            "twenty": 20, "thirty": 30, "forty": 40, "fifty": 50, "sixty": 60,
            "seventy": 70, "eighty": 80, "ninety": 90, "hundred": 100,
            // Common misrecognitions
            "hey": 8, "ate": 8, "hate": 8, "great": 8
        ]
        
        // Try exact match first
        if let number = numberWords[text] {
            print("✅ DEBUG: Found exact word match: \(number)")
            return number
        }
        
        // Try compound numbers like "twenty three"
        let words = text.components(separatedBy: .whitespaces)
        if words.count == 2 {
            let firstWord = words[0]
            let secondWord = words[1]
            
            if let firstNumber = numberWords[firstWord], let secondNumber = numberWords[secondWord] {
                let result = firstNumber + secondNumber
                print("✅ DEBUG: Found compound number: \(firstNumber) + \(secondNumber) = \(result)")
                return result
            }
        }
        
        print("❌ DEBUG: No word match found for: '\(text)'")
        return nil
    }
    
    func clearRecognizedText() {
        recognizedText = ""
        recognizedNumber = ""
        errorMessage = nil
    }
    
    // MARK: - Sound Effects
    private func configureAudioSessionForPlayback() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.duckOthers, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("❌ DEBUG: Failed to configure audio session for playback: \(error.localizedDescription)")
        }
    }
    
    private func playStartListeningSound() {
        // Play a simple click sound when listening begins
        print("🔊 DEBUG: Playing start listening sound")
        
        // Ensure audio session allows playback
        configureAudioSessionForPlayback()
        
        // Use a simple click sound
        AudioServicesPlaySystemSound(1104) // Simple click sound
        
        // Add haptic feedback for better user experience
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func playStopListeningSound() {
        // Play a simple click sound when listening ends
        print("🔊 DEBUG: Playing stop listening sound")
        
        // Ensure audio session allows playback
        configureAudioSessionForPlayback()
        
        // Use a simple click sound
        AudioServicesPlaySystemSound(1104) // Simple click sound
        
        // Add haptic feedback for better user experience
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}