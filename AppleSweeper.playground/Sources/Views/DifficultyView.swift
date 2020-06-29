//
//  DifficultyView.swift
//  AppleSweeperMac
//
//  Created by Ethan Humphrey on 5/17/20.
//  Copyright © 2020 Ethan Humphrey. All rights reserved.
//

import SwiftUI

struct DifficultyView: View {
    
    @EnvironmentObject var game: Game
    
    var body: some View {
        VStack {
            Text("Difficulty")
            .font(.headline)
            
            HStack {
                Button(action: {
                    self.game.changeDifficulty(to: Game.Difficulty.beginner)
                }) {
                    Text("Beginner")
                }
                .disabled(game.currentDifficulty == .beginner)
                
                Button(action: {
                    self.game.changeDifficulty(to: Game.Difficulty.intermediate)
                }) {
                    Text("Intermediate")
                }
                .disabled(game.currentDifficulty == .intermediate)
                
                Button(action: {
                    self.game.changeDifficulty(to: Game.Difficulty.expert)
                }) {
                    Text("Expert")
                }
                .disabled(game.currentDifficulty == .expert)
            }
        }
        .padding()
    }
}
