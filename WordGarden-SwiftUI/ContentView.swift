//
//  ContentView.swift
//  WordGarden-SwiftUI
//
//  Created by Lori Rothermel on 8/30/24.
//

import SwiftUI

struct ContentView: View {
    @State private var wordsGuessed = 0
    @State private var wordsMissed = 0
    @State private var wordsToGuess = ["SWIFT","DOG","CAT","MOUSE"]
    @State private var gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
    @State private var currentWord = 0
    @State private var guessedLetter = ""
    @State private var imageName = "flower8"
    @State private var playAgainHidden = true
    @FocusState private var textFieldIsFocus: Bool
    
    
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
                .padding()
            
            Spacer()
            
            // TODO: Switch to wordsToGuess[currentWord]
                      
            Text("- - - - -")
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
                            
                            guard let lastChar = guessedLetter.last else {
                                return
                            }  // guard let
                            guessedLetter = String(lastChar).uppercased()
                        }  // .onChange
                        .focused($textFieldIsFocus)
                    
                    Button("Guess A Letter") {
                        // TODO: Guess A Letter Button Action Here
                        textFieldIsFocus = false
                        
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
                
                Button("Another Word?") {
                    // TODO: Another Word Button Action Here
                    
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
                       
            
        }  // VStack
        .ignoresSafeArea(edges: .bottom)
        
        
    }
}

#Preview {
    ContentView()
}


