//
//  SolverView.swift
//  AppleSweeperMac
//
//  Created by Ethan Humphrey on 5/17/20.
//  Copyright © 2020 Ethan Humphrey. All rights reserved.
//

import SwiftUI

struct SolverView: View {
    
    @EnvironmentObject var game: Game
    
    var body: some View {
        VStack {
            Text("Solver AI Options")
            .font(.headline)
            
            Button(action: {
                DispatchQueue(label: "SolverQueue").async {
                    AppleSweeperSolver().solve(self.game)
                }
            }) {
                Text("Solve!")
            }
            
            if game.isSimulating {
                Text("Simulation in Progress...")
            }
            else if game.simulationResult != nil {
                Text(String(format: "Solver Win Rate: %.2f%%", game.simulationResult!))
            }
            
            HStack {
                Button(action: {
                    AppleSweeperSolver().calculateWinRate(numberOfGames: 100, using: self.game)
                }) {
                    Text("Simulate 100 Games")
                }
                Button(action: {
                    AppleSweeperSolver().calculateWinRate(numberOfGames: 500, using: self.game)
                }) {
                    Text("Simulate 500 Games")
                }
                Button(action: {
                    AppleSweeperSolver().calculateWinRate(numberOfGames: 1000, using: self.game)
                }) {
                    Text("Simulate 1,000 Games")
                }
            }
            .disabled(self.game.isSimulating)
        }
        .padding()
    }
}
