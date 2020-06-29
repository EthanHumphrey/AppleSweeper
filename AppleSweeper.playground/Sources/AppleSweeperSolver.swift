//
//  AppleSweeperSolver.swift
//  AppleSweeperMac
//
//  Created by Ethan Humphrey on 5/16/20.
//  Copyright © 2020 Ethan Humphrey. All rights reserved.
//

import Foundation

class AppleSweeperSolver {
    
    func calculateWinRate(numberOfGames: Int, using game: Game) {
        game.isSimulating = true
        DispatchQueue(label: "SolverQueue").async {
            var gamesWon: Double = 0
            for gameNumber in 0 ..< numberOfGames {
                let newGame = Game(difficulty: game.currentDifficulty)
                self.solve(newGame)
                if newGame.didWin == true {
                    gamesWon += 1
                }
                if let didWin = newGame.didWin {
                    print("Game \(gameNumber): " + (didWin ? "Won" : "Lost"))
                }
                else {
                    print("Game \(gameNumber): Unfinished")
                }
            }
            let winRate = Double(gamesWon/Double(numberOfGames))*100.0
            print("Win Rate: \(winRate)%")
            DispatchQueue.main.async {
                game.isSimulating = false
                game.simulationResult = winRate
            }
        }
    }
    
    func solve(_ game: Game) {
        var accomplishedSomething = true
        var shouldAttemptStep3 = false
        var combinedSpaces: [Board.Space]?
        var attemptedCombinedSpaces = [[Board.Space]]()
        
        solveLoop: while game.didWin == nil && accomplishedSomething {
            accomplishedSomething = false
            if game.board.totalOpenSpaces == 0 {
                let guessCoordinate = Coordinate.random(xRange: 0 ..< game.board.width, yRange: 0 ..< game.board.height)
                game.board.openSpace(game.board.getSpace(at: guessCoordinate)!)
                accomplishedSomething = true
            }
            else {
                let numberedSpaces = game.board.flatBoard.filter { space -> Bool in
                    if let surroundingBombs = space.getSurroundingBombs()  {
                        return surroundingBombs > 0
                    }
                    return false
                }
                
                for space in numberedSpaces {
                    let surroundingSpaces = game.board.getSpaces(around: space)
                    
                    
                    var unopenedSurroundingSpaces = surroundingSpaces.filter { space -> Bool in
                        return space.state == .unopened
                    }
                    let markedSurroundingSpaces = surroundingSpaces.filter { space -> Bool in
                        return space.state == .marked
                    }
                    var numberOfMarkedSpaces = markedSurroundingSpaces.count
                    if combinedSpaces != nil {
                        let unopenededCombinedPoints = unopenedSurroundingSpaces.filter(combinedSpaces!.contains)
                        if unopenededCombinedPoints.count == 2 {
                            numberOfMarkedSpaces += 1
                            unopenedSurroundingSpaces.removeAll { (space) -> Bool in
                                unopenededCombinedPoints.contains(space)
                            }
                        }
                    }
                    
                    if let surroundingBombs = space.getSurroundingBombs() {
                        
                        // Step 1: If a space has exactly its value of unopened spaces around it, mark them all as bombs.
                        if unopenedSurroundingSpaces.count != 0 && unopenedSurroundingSpaces.count + numberOfMarkedSpaces == surroundingBombs {
                            DispatchQueue.main.async {
                                unopenedSurroundingSpaces.forEach { space in
                                    space.state = .marked
                                }
                            }
                            accomplishedSomething = true
                        }
                        
                        // Step 2: If a space has exactly its value of marked spaces around it, open all other unmarked spaces around it.
                        if unopenedSurroundingSpaces.count != 0 && surroundingBombs == numberOfMarkedSpaces {
                            DispatchQueue.main.async {
                                unopenedSurroundingSpaces.forEach { space in
                                    game.board.openSpace(space)
                                }
                            }
                            accomplishedSomething = true
                        }
                        
                        // Step 3: Done after rule 1 & 2 cannot be done. If number of marked is one less than value (value - 1) and number of unmarked is 2, AND 2 are adjacent, then act as though those are 1. Proceed to try rule 1 and 2 again.
                        if !accomplishedSomething && shouldAttemptStep3 && combinedSpaces == nil && markedSurroundingSpaces.count == surroundingBombs - 1 && unopenedSurroundingSpaces.count == 2 && unopenedSurroundingSpaces[0].coordinate.isAdjacentTo(unopenedSurroundingSpaces[1].coordinate) {
                            if !attemptedCombinedSpaces.contains(unopenedSurroundingSpaces) {
                                combinedSpaces = unopenedSurroundingSpaces
                                accomplishedSomething = true
                                shouldAttemptStep3 = false
                                attemptedCombinedSpaces.append(combinedSpaces!)
                                continue solveLoop
                            }
                        }
                        else if accomplishedSomething && combinedSpaces != nil {
                            combinedSpaces = nil
                            attemptedCombinedSpaces = [[Board.Space]]()
                        }
                    }
                }
            }
            
            if !accomplishedSomething {
                if combinedSpaces != nil {
                    combinedSpaces = nil
                }
                if !shouldAttemptStep3 {
                    shouldAttemptStep3 = true
                    accomplishedSomething = true
                }
                else {
                    let unopenedSpaces = game.board.flatBoard.filter { (space) -> Bool in
                        return space.state == .unopened
                    }
                    if let randomSpace = unopenedSpaces.randomElement() {
                        game.board.openSpace(randomSpace)
                        accomplishedSomething = true
                    }
                }
            }
        }
    }
}
