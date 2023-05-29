//
//  ContentView.swift
//  WordGarden-SwiftUI
//
//  Created by Lori Rothermel on 5/27/23.
//

import SwiftUI
import AVFAudio


struct ContentView: View {
    @State private var wordsGuessed = 0
    @State private var wordsMissed = 0
    @State private var wordToGuess = ""
    @State private var revealedWord = ""
    @State private var lettersGuessed = ""
    @State private var guessesRemaining = 8
    @State private var currentWordIndex = 0
    @State private var gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
    @State private var guessedLetter = ""
    @State private var imageName = "flower8"
    @State private var playAgainHidden: Bool = true
    @State private var playAgainButtonLabel = "Another Word?"
    @State private var audioPlayer: AVAudioPlayer!
    
    @FocusState private var isTextFieldFocused: Bool
    
    
    private let wordsToGuess = ["SWIFT", "DOG", "CAT"]
    private let maximumGuesses = 8
    
    
    var body: some View {
        
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Words Guessed: \(wordsGuessed)")
                    Text("Words Missed: \(wordsMissed)")
                }  // VStack
                Spacer()
                VStack(alignment: .leading) {
                    Text("Words to Guess: \(wordsToGuess.count - (wordsGuessed + wordsMissed))")
                    Text("Words in Game: \(wordsToGuess.count)")
                }  // VStack
            }  // HStack
            .padding(.horizontal)
            
            Spacer()
            
            Text(gameStatusMessage)
                .font(.title)
                .multilineTextAlignment(.center)
                .frame(height: 80)
                .minimumScaleFactor(0.5)
                .padding()
            
            Spacer()
            
            // TODO: Switch to wordsToGuess[currentWord]
            Text(revealedWord)
                .font(.title)
            
            
            if playAgainHidden {
                HStack {
                    TextField("", text: $guessedLetter)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 30)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.gray, lineWidth: 2)
                        }  // .overlay
                        .keyboardType(.asciiCapable)
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                        .onChange(of: guessedLetter) { _ in
                            guessedLetter = guessedLetter.trimmingCharacters(in: .letters.inverted)
                            guard let lastChar = guessedLetter.last else { return }
                            guessedLetter = String(lastChar).uppercased()
                        }  // .onChange
                        .onSubmit {
                            guard guessedLetter != "" else { return }
                            guessALetter()
                            updateGamePlay()
                        }
                        .focused($isTextFieldFocused)
                    
                    
                    Button("Guess A Letter") {
                        guessALetter()
                        updateGamePlay()
                    }  // Button - Guess A Letter
                    .buttonStyle(.bordered)
                    .tint(.mint)
                    .disabled(guessedLetter.isEmpty)
                }  // HStack
            } else {
                Button(playAgainButtonLabel) {
                    // If all words have been guessed
                    if currentWordIndex == wordsToGuess.count {
                        currentWordIndex = 0
                        wordsGuessed = 0
                        wordsMissed = 0
                        playAgainButtonLabel = "Another Word?"
                    }  // if
                    
                    // Reset after a word was guessed or missed.
                    wordToGuess = wordsToGuess[currentWordIndex]
                    revealedWord = "_" + String(repeating: " _", count: wordToGuess.count-1)
                    lettersGuessed = ""
                    guessesRemaining = maximumGuesses
                    imageName = "flower\(guessesRemaining)"
                    gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
                    playAgainHidden = true
                }  // Button - Another Word?
                .buttonStyle(.borderedProminent)
                .tint(.mint)
            }
            
            Image(imageName)
                .resizable()
                .scaledToFit()
                .animation(.easeIn(duration: 0.75), value: imageName)
            Spacer()
        }  // VStack
        .edgesIgnoringSafeArea(.bottom)
        .onAppear() {
            wordToGuess = wordsToGuess[currentWordIndex]
            revealedWord = "_" + String(repeating: " _", count: wordToGuess.count-1)
            guessesRemaining = maximumGuesses
        }  // .onAppear
        
    }  // some View
    
    
    func guessALetter() {
        
        isTextFieldFocused = false
        
        lettersGuessed = lettersGuessed + guessedLetter
        
        revealedWord = ""

        // Loop through all the letters in wordToGuess
        for letter in wordToGuess {
            // Check if letter is in wordToGuess is in lettersGuessed - Did you guess this letter already?
            if lettersGuessed.contains(letter) {
                revealedWord = revealedWord + "\(letter) "
            } else {
                // If not add an underscore + a blank space to revealedWord
                revealedWord = revealedWord + "_ "
            }  // if
            
        }  // for
        
        revealedWord.removeLast()
        
    }  // guessALetter
    
    func updateGamePlay() {
                
        if !wordToGuess.contains(guessedLetter) {
            guessesRemaining -= 1
            
            // Animate crumbling leaf and play incorrect sound
            imageName = "wilt\(guessesRemaining)"
            playSound(soundName: "incorrect")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                imageName = "flower\(guessesRemaining)"
            }  // DispatchQueue
            
        } else {
            playSound(soundName: "correct")
        }  // if...else
        
        // When do we play another word?
        if !revealedWord.contains("_") {
            gameStatusMessage = "You Guessed It❗️ It Took You \(lettersGuessed.count) Guesses to Guess the Word."
            wordsGuessed += 1
            currentWordIndex += 1
            playAgainHidden = false
            playSound(soundName: "word-guessed")
        } else if guessesRemaining == 0 {
            gameStatusMessage = "So Sorry❗️ You're All Out of Guesses."
            wordsMissed += 1
            currentWordIndex += 1
            playAgainHidden = false
            playSound(soundName: "word-not-guessed")
        } else {
            gameStatusMessage = "You've Made \(lettersGuessed.count) Guess\(lettersGuessed.count == 1 ? "" : "es")"
        }
        
        if currentWordIndex == wordsToGuess.count {
            playAgainButtonLabel = "Restart Game?"
            gameStatusMessage = "You've Tried All of the Words. Restart From the Beginning?"
        }
        
        guessedLetter = ""
    }
    
    
    func playSound(soundName: String) {
        
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("❗️ Could not read file named \(soundName)")
            return
        }  // guard let
        
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        } catch {
            print("❗️ ERROR: \(error.localizedDescription)")
        }  // do...catch
        
    }  // playSound
    
    
    
}  // ContentView

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
