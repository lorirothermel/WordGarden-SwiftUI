//
//  ContentView.swift
//  WordGarden-SwiftUI
//
//  Created by Lori Rothermel on 8/30/24.
//

import SwiftUI
import AVFAudio


struct ContentView: View {
    @State private var wordsGuessed = 0
    @State private var wordsMissed = 0
    @State private var gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
    @State private var currentWordIndex = 0
    @State private var wordToGuess = ""
    @State private var revealedWord = ""
    @State private var lettersGuessed = ""
    @State private var guessedLetter = ""
    @State private var guessesRemaining = 8
    @State private var imageName = "flower8"
    @State private var playAgainHidden = true
    @State private var playAgainButtonLabel = "Another Word?"
    @State private var audioPlayer: AVAudioPlayer!
        
    @FocusState private var textFieldIsFocus: Bool
    
    
    private let wordsToGuess = ["SWIFT","DOG","CAT"]
    private let maximumGuesses = 8
    
    
    var body: some View {
        VStack {
            
            HStack {
                
                VStack(alignment: .leading) {
                    Text("Words Guessed: \(wordsGuessed)")
                    Text("Words Missed: \(wordsMissed)")
                }  // VStack
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Words to Guess: \(wordsToGuess.count - wordsGuessed + wordsMissed)")
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
                                             
            Text(revealedWord)
                .font(.title)
                .fontWeight(.black)
                        
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
                        .onChange(of: guessedLetter) { _, _ in
                            guessedLetter = guessedLetter.trimmingCharacters(in: .letters.inverted)
                            
                            guard let lastChar = guessedLetter.last else { return }
                            guessedLetter = String(lastChar).uppercased()
                        }  // .onChange
                        .onSubmit {
                            guard guessedLetter != "" else { return }
                            guessALetter()
                            updateGamePlay()
                        }  // .onSubmit
                        .focused($textFieldIsFocus)
                    
                    
                    Button("Guess A Letter") {
                        textFieldIsFocus = false
                        guessALetter()
                        updateGamePlay()
 
                    }  // Button
                    .font(.system(size: 25))
                    .bold()
                    .tint(.mint)
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                    .padding(.bottom)
                    .disabled(guessedLetter.isEmpty)
                    
                }  // HStack
            } else {
                Button(playAgainButtonLabel) {
                    
                    // If all the wprds have been quessed...
                    if currentWordIndex == wordsToGuess.count {
                        currentWordIndex = 0
                        wordsGuessed = 0
                        wordsMissed = 0
                        playAgainButtonLabel = "Another Word?"
                    }  // if
                                        
                    // Reset After a Word was Guessed or Missed
                    wordToGuess = wordsToGuess[currentWordIndex]
                    revealedWord = "_" + String(repeating: " _", count: wordToGuess.count - 1)
                    lettersGuessed = ""
                    guessesRemaining = maximumGuesses
                    imageName = "flower\(guessesRemaining)"
                    gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
                    playAgainHidden = true
                }  // Button
                .font(.system(size: 25))
                .bold()
                .buttonBorderShape(.roundedRectangle(radius: 12))
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }  // if
            
            Spacer()
            
            Image(imageName)
                .resizable()
                .scaledToFit()
                .animation(.easeIn(duration: 0.75), value: imageName)
                       
            
        }  // VStack
        .ignoresSafeArea(edges: .bottom)
        .onAppear() {
            wordToGuess = wordsToGuess[currentWordIndex]
            revealedWord = "_" + String(repeating: " _", count: wordToGuess.count - 1)
            guessesRemaining = maximumGuesses
        }  // .onAppear
        
    }
    
//    func guessALetter() {
//                        
//        lettersGuessed = lettersGuessed + guessedLetter
//        
//        revealedWord = ""
//
//
//        for letter in wordToGuess {
//            if lettersGuessed.contains(letter) {
//                revealedWord = revealedWord + "\(letter) "
//            } else {
//                revealedWord = revealedWord + "_ "
//            }  // if
//        }  // for
//        
//        revealedWord.removeLast()
//        guessedLetter = ""
//        
//    }  // guessALetter
 

    func guessALetter() {
        
        lettersGuessed = lettersGuessed + guessedLetter
        
        revealedWord = ""
        
        for letter in wordToGuess {
            if lettersGuessed.contains(letter) {
                revealedWord = revealedWord + "\(letter) "
            } else {
                revealedWord = revealedWord + "_ "
            }  // if...else
        }  // for
        
        revealedWord.removeLast()
                
    }  // func guessALetter
    
    
    func updateGamePlay() {
                
        if !wordToGuess.contains(guessedLetter) {
            guessesRemaining = guessesRemaining - 1
            
            // Animate Crumbling Leaf and Play "Incorrect" Sound
            imageName = "wilt\(guessesRemaining)"
            playSound(soundName: "incorrect")
            
            // Delay Change to Flower Image Until After Wilt Animation is Done.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                imageName = "flower\(guessesRemaining)"
            }  // DispatchQueue.main
                                    
        } else {
            playSound(soundName: "correct")
        }
        
        // When do we play another word?
        if !revealedWord.contains("_") {   /* Guessed when no _ in revealedWord */
            gameStatusMessage = "You've Guessed It! It Took You \(lettersGuessed.count) Guesses tp Guess the Word."
            wordsGuessed = wordsGuessed + 1
            currentWordIndex = currentWordIndex + 1
            playAgainHidden = false
            playSound(soundName: "word-guessed")
        } else if guessesRemaining == 0 {  /* Word Missed */
            gameStatusMessage = "So Sorry... You're All Out of Guesses."
            wordsMissed = wordsMissed + 1
            currentWordIndex = currentWordIndex + 1
            playAgainHidden = false
            playSound(soundName: "word-not-guessed")
        } else {
            gameStatusMessage = "You've Made \(lettersGuessed.count) Guess\(lettersGuessed.count == 1 ? "" : "es")"
        }
        
        if currentWordIndex == wordsToGuess.count {
            playAgainButtonLabel = "Restart Game?"
            gameStatusMessage = gameStatusMessage + "\nYou've Tried All of the Words. Restart from the Beginning?"
     
        }

        guessedLetter = ""
    }
        
    func playSound(soundName: String) {
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("❗️Could not read file named \(soundName)")
            return
        }  // guard let
        
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        } catch {
            print("ERROR: \(error.localizedDescription). Creating audioPlayer.")
        }  // do...catch
    }
    
    

}

#Preview {
    ContentView()
}

