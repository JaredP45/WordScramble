//
//  ContentView.swift
//  WordScramble
//
//  Created by student on 3/10/21.
//  Copyright © 2021 IN185 BS. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
                VStack {
                    TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .autocapitalization(.none)
                    
                    List(usedWords, id: \.self) {
                        Image(systemName: "\($0.count).circle")
                        Text($0)
                    }
                }
                .navigationBarTitle(rootWord)
                .onAppear(perform: startGame)
                .alert(isPresented: $showingError) {
                    Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("Okay")))
            }
        }
    }
    
    
    func isOriginal(word: String) -> Bool {
        // Checks wheteher a word has been used or not
        
        !usedWords.contains(word)
    }
    
    
    func isPossible(word: String) -> Bool {
        // Create copy of root word
        // loop over each letter to check if letter exists in copy
        // If true, remove it from copy (so that it won't be used twice)
        // If false, there's a mistake and returns false
        
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    
    func isReal(word: String) -> Bool {
        // Create NSRange to scan entire length of string
        // Call rangeOfMisspelledWord() to check for wrong words
        // Call NSRange again to find misspelled word
        // If the word is okay, return the location of NSRange to NSNotFound
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
              
        return misspelledRange.location == NSNotFound
    }
    
    
    func wordError(title: String, message: String) {
        // Sets title and message based on parameters it receives
        // Then flips showingError boolean to true
        
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    
    func addNewWord() {
        // Makes user's word lowercased, and displays character counter
        
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        // Validation Alerts
        guard isOriginal(word: answer) else {
            wordError(title: "Word has been used already", message: "Unique word required")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word is not recognized", message: "Try again")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word is not possible", message: "This isn't a real word")
            return
        }
        
        // Insert at the beginning of list, not end
        usedWords.insert(answer, at: 0)
        newWord = ""
    }

    
    func startGame() {
        // Find the URL for start.txt in app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")
                
                // Pick one random word, or use a default word if nil
                rootWord = allWords.randomElement() ?? "grapefruit"
                    
                return
            }
        }
        
        // If a problem triggers, fatalError will close app and send the report
        fatalError("Could not load start.txt from bundle.")
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
