//
//  Game.swift
//  AppleSweeperMac
//
//  Created by Ethan Humphrey on 5/16/20.
//  Copyright © 2020 Ethan Humphrey. All rights reserved.
//

import Foundation

public class Game: ObservableObject {
    
    @Published var didWin: Bool?
    @Published var seconds: Int = 0
    @Published var isLoading = true
    @Published var currentDifficulty: Difficulty = .expert
    
    @Published var isSimulating = false
    @Published var simulationResult: Double?
    
    var board: Board!
    var timer: Timer?
    
    public init(difficulty: Difficulty) {
        initializeGame(difficulty: difficulty)
    }
    
    func initializeGame(difficulty: Difficulty) {
        currentDifficulty = difficulty
        board = Board(height: difficulty.height, width: difficulty.width, numberOfBombs: difficulty.numberOfBombs)
        board.game = self
        isLoading = false
    }
    
    func changeDifficulty(to difficulty: Difficulty) {
        currentDifficulty = difficulty
        isLoading = true
        seconds = 0
        didWin = nil
        timer?.invalidate()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            self.initializeGame(difficulty: difficulty)
        }
    }
    
    func resetGame() {
        isLoading = true
        seconds = 0
        didWin = nil
        timer?.invalidate()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            self.initializeGame(difficulty: self.currentDifficulty)
        }
    }
    
    func resetGameForBot() {
        isLoading = true
        seconds = 0
        didWin = nil
        timer?.invalidate()
        self.initializeGame(difficulty: currentDifficulty)
    }
    
    func beginTimerIfNeeded() {
        if (timer?.isValid ?? false) == false {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.seconds += 1
            }
        }
    }
    
    func gameOver() {
        timer?.invalidate()
        didWin = false
    }
    
    public struct Difficulty: Equatable {
        var height: Int
        var width: Int
        var numberOfBombs: Int
        
        public static let beginner = Difficulty(height: 9, width: 9, numberOfBombs: 10)
        public static let intermediate = Difficulty(height: 16, width: 16, numberOfBombs: 30)
        public static let expert = Difficulty(height: 16, width: 30, numberOfBombs: 50)
    }
    
}
