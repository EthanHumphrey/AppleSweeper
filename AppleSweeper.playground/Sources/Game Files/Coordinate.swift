//
//  Coordinate.swift
//  AppleSweeperMac
//
//  Created by Ethan Humphrey on 5/16/20.
//  Copyright © 2020 Ethan Humphrey. All rights reserved.
//

import Foundation

struct Coordinate: Equatable {
    var x: Int
    var y: Int
    
    func move(_ directions: Set<Direction>, steps: Int = 1) -> Coordinate {
        var newPoint = self
        for direction in directions {
            switch direction {
            case .left:
                newPoint.x -= steps
            case .right:
                newPoint.x += steps
            case .up:
                newPoint.y -= steps
            case .down:
                newPoint.y += steps
            }
        }
        return newPoint
    }
    
    func getSurroundingCoordinates() -> [Coordinate] {
        return [
            move([.left, .up]),
            move([.up]),
            move([.right, .up]),
            move([.right]),
            move([.right, .down]),
            move([.down]),
            move([.left, .down]),
            move([.left])
        ]
    }
    
    func isAdjacentTo(_ otherCoordinate: Coordinate) -> Bool {
        let xDifference = abs(otherCoordinate.x - self.x)
        let yDifference = abs(otherCoordinate.y - self.y)
        return (xDifference == 1 && yDifference == 0) || (xDifference == 0 && yDifference == 1)
    }
    
    static func random(xRange: Range<Int>, yRange: Range<Int>) -> Coordinate {
        return Coordinate(x: Int.random(in: xRange), y: Int.random(in: yRange))
    }
    
    static func == (first: Coordinate, second: Coordinate) -> Bool {
        return first.x == second.x && first.y == second.y
    }
}
