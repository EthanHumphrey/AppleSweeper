//
//  Board.swift
//  AppleSweeper
//
//  Created by Ethan Humphrey on 5/14/20.
//  Copyright © 2020 Ethan Humphrey. All rights reserved.
//

import Foundation
import Combine
import AppKit

public class Board {
    
    var board = [[Space]]()
    var game: Game!
    
    
    var numberOfBombs: Int!
    fileprivate var bombCoordinates = [Coordinate]()
    
    var totalEmptySpaces = 0
    var totalOpenSpaces = 0
    var totalMarked = 0
    
    var flatBoard: [Space] {
        var flatArray = [Space]()
        board.forEach { (row) in
            flatArray.append(contentsOf: row)
        }
        return flatArray
    }
    
    var height: Int {
        return board.count
    }
    
    var width: Int {
        if let first = board.first {
            return first.count
        }
        return 0
    }
    
    public init(height: Int, width: Int, numberOfBombs: Int) {
        self.numberOfBombs = numberOfBombs
        totalEmptySpaces = height*width - numberOfBombs
        calculateBombPlacements(height: height, width: width)
        makeBoardArray(height: height, width: width)
        calculateSpaceValues()
    }
    
    func makeBoardArray(height: Int, width: Int) {
        for y in 0 ..< height {
            var rowArray = [Space]()
            for x in 0 ..< width {
                let currentCoordinate = Coordinate(x: x, y: y)
                rowArray.append(
                    Space(
                        contains: bombCoordinates.contains(currentCoordinate) ? .bomb : .nothing,
                        at: currentCoordinate,
                        board: self
                    )
                )
            }
            board.append(rowArray)
        }
    }
    
    func calculateSpaceValues() {
        for space in flatBoard {
            space.surroundingBombs = findBombs(around: space)
        }
    }
    
    func calculateBombPlacements(height: Int, width: Int) {
        while bombCoordinates.count < numberOfBombs {
            let newCoordinate = Coordinate.random(xRange: 0 ..< width, yRange: 0 ..< height)
            if !bombCoordinates.contains(newCoordinate) {
                bombCoordinates.append(newCoordinate)
            }
        }
    }
    
    func getSpace(at coordinate: Coordinate) -> Space? {
        if let firstRow = board.first {
            if coordinate.y >= 0 && coordinate.y < board.count && coordinate.x >= 0 && coordinate.x < firstRow.count {
                return board[coordinate.y][coordinate.x]
            }
        }
        return nil
    }
    
    func replaceSpace(at coordinate: Coordinate, with newSpace: Space) {
        board[coordinate.y][coordinate.x] = newSpace
    }
    
    func openSpace(_ space: Space) {
        self.game.beginTimerIfNeeded()
        if game.didWin == nil {
            game.beginTimerIfNeeded()
            if space.state == .unopened {
                if totalOpenSpaces == 0 && (space.surroundingBombs! > 0 || space.trueValue == .bomb) {
                    moveBombs(around: space)
                }
                space.state = .open
                switch space.trueValue {
                case .nothing:
                    totalOpenSpaces += 1
                    if space.surroundingBombs == 0 {
                        for sideCoordinate in space.coordinate.getSurroundingCoordinates() {
                            if let sideSpace = self.getSpace(at: sideCoordinate), sideSpace.state == .unopened && sideSpace.trueValue == .nothing {
                                self.openSpace(sideSpace)
                            }
                        }
                    }
                    checkForWin()
                case .bomb:
                    game.gameOver()
                    for coordinate in bombCoordinates {
                        let space = getSpace(at: coordinate)
                        space?.state = .open
                    }
                }
            }
        }
    }
    
    fileprivate func moveBombs(around space: Space) {
        var numberOfBombsToMove = space.surroundingBombs!
        var surroundingCoordinates = space.coordinate.getSurroundingCoordinates()
        surroundingCoordinates.append(space.coordinate)
        while numberOfBombsToMove > 0 {
            let newCoordinate = Coordinate.random(xRange: 0 ..< width, yRange: 0 ..< height)
            if !bombCoordinates.contains(newCoordinate) && !surroundingCoordinates.contains(newCoordinate) {
                bombCoordinates.append(newCoordinate)
                getSpace(at: newCoordinate)?.trueValue = .bomb
                numberOfBombsToMove -= 1
            }
        }
        for coordinate in surroundingCoordinates {
            if let space = getSpace(at: coordinate), space.trueValue == .bomb {
                bombCoordinates.removeAll { bombCoordinate -> Bool in
                    return bombCoordinate == coordinate
                }
                space.trueValue = .nothing
            }
        }
        calculateSpaceValues()
    }
    
    func checkForWin() {
        if totalEmptySpaces == totalOpenSpaces {
            DispatchQueue.main.async {
                self.game.didWin = true
                self.game.timer?.invalidate()
            }
        }
    }
    
    func getSpaces(around space: Space) -> [Space] {
        let surroundingCoordinates = space.coordinate.getSurroundingCoordinates()
            
        var surroundingSpaces = [Space]()
        for sideCoordinate in surroundingCoordinates {
            if let sideSpace = getSpace(at: sideCoordinate) {
                surroundingSpaces.append(sideSpace)
            }
        }
        return surroundingSpaces
    }
    
    fileprivate func findBombs(around space: Space) -> Int {
        var numberOfBombs = 0
        let surroundingSpaces = getSpaces(around: space)
        for space in surroundingSpaces {
            if space.trueValue == .bomb {
                numberOfBombs += 1
            }
        }
        return numberOfBombs
    }
    
    
    func toggleMarked(for space: Space) {
        if game.didWin == nil {
            switch space.state {
            case .marked:
                space.state = .unopened
            case .unopened:
                space.state = .marked
            default:
                break
            }
        }
    }
    
    class Space: ObservableObject, Equatable {
        
        let board: Board!
        
        @Published var state: State = .unopened
        fileprivate var trueValue: Value
        var coordinate: Coordinate
        
        fileprivate var surroundingBombs: Int?
        
        init(contains trueValue: Value, at coordinate: Coordinate, board: Board) {
            self.trueValue = trueValue
            self.coordinate = coordinate
            self.board = board
        }
     
        enum State {
            case unopened
            case open
            case marked
        }
        
        enum Value {
            case nothing
            case bomb
        }
        
        func getSpaceColor() -> NSColor {
            if board.game.didWin == false && trueValue == .bomb {
                return .systemRed
            }
            else {
                switch state {
                case .unopened, .marked:
                    return .darkGray
                case .open:
                    switch trueValue {
                    case .bomb:
                        return .systemRed
                    case .nothing:
                        return .systemGray
                    }
                }
            }
        }
        
        func getSurroundingBombs() -> Int? {
            if state == .open {
                return surroundingBombs
            }
            else {
                return nil
            }
        }
        
        func containsBomb() -> Bool? {
            if state == .open {
                return trueValue == .bomb
            }
            return nil
        }
        
        static func == (lhs: Board.Space, rhs: Board.Space) -> Bool {
            return lhs.coordinate == rhs.coordinate && lhs.state == rhs.state && lhs.trueValue == rhs.trueValue
        }
    }
}
