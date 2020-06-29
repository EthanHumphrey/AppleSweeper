//
//  CellView.swift
//  AppleSweeper
//
//  Created by Ethan Humphrey on 5/14/20.
//  Copyright © 2020 Ethan Humphrey. All rights reserved.
//

import SwiftUI

struct SpaceView: View {
    
    @ObservedObject var space: Board.Space
    @State var isHighlighted = false
    let board: Board
    
    static let cellSize: CGFloat = 25
    
    var body: some View {
        Group {
            if space.state == .open && space.getSurroundingBombs()! > 0 && !space.containsBomb()! {
                Text("\(space.getSurroundingBombs()!)")
            }
            else if space.containsBomb() == true {
                Text("💣")
            }
            else if space.state == .marked {
                Text("🏴‍☠️")
            }
            else {
                Text(" ")
            }
        }
        .foregroundColor(.black)
        .frame(width: SpaceView.cellSize, height: SpaceView.cellSize, alignment: .center)
        .background(isHighlighted ? Color(.lightGray) : Color(space.getSpaceColor()))
        .border(Color.black, width: 0.5)
        .modifier(OnClick(isHighlighted: $isHighlighted, leftClick: {
            self.board.openSpace(self.space)
        }, rightClick: {
            self.board.toggleMarked(for: self.space)
        }))
    }
}
