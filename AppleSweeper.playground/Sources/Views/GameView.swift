//
//  GameView.swift
//  AppleSweeper
//
//  Created by Ethan Humphrey on 5/14/20.
//  Copyright © 2020 Ethan Humphrey. All rights reserved.
//

import SwiftUI

public struct GameView: View {
    
    public static let hostedView = GameView()
    
    @EnvironmentObject var game: Game
    
    public var body: some View {
        ScrollView {
            VStack {
                Text("Welcome to AppleSweeper!")
                    .font(.largeTitle)
                    .padding()
                
                if game.didWin == false {
                    Text("Game Over!")
                        .font(.headline)
                        .padding(.bottom)
                }
                else if game.didWin == true {
                    Text("You Win!")
                        .font(.headline)
                        .padding(.bottom)
                }
                
                Text("Time: \(formatTime(game.seconds))")
                    .font(.headline)
                    .padding(.bottom)
                
                Text("Total Bombs: \(game.board.numberOfBombs)")
                
                if !game.isLoading {
                    BoardView(board: game.board)
                }
                else {
                    Text("Loading...")
                        .frame(height: SpaceView.cellSize*CGFloat(game.board.height))
                }
                
                Button(action: {
                    self.game.resetGame()
                }) {
                    Text("Reset Game")
                }
                
                DifficultyView()
                SolverView()
            }
        }
    }
    
    func formatTime(_ seconds: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: TimeInterval(seconds))!
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
