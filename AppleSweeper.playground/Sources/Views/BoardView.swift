//
//  BoardView.swift
//  AppleSweeper
//
//  Created by Ethan Humphrey on 5/14/20.
//  Copyright © 2020 Ethan Humphrey. All rights reserved.
//

import SwiftUI

struct BoardView: View {
    
    let board: Board
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ForEach (0 ..< board.height) { y in
                HStack(alignment: .center, spacing: 0) {
                    ForEach (0 ..< self.board.width) { x in
                        if self.board.getSpace(at: Coordinate(x: x, y: y)) != nil {
                            SpaceView(space: self.board.getSpace(at: Coordinate(x: x, y: y))!, board: self.board)
                        }
                    }
                }
            }
        }
        .frame(width: CGFloat(board.width)*SpaceView.cellSize, height: CGFloat(board.height)*SpaceView.cellSize, alignment: .center)
        .padding()
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
