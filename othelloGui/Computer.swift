//
//  computer.swift
//  othelloGuiV4
//
//  Created by Richard Griffin on 10/13/18.
//  Copyright © 2018 Richard Griffin. All rights reserved.
//

import Foundation
/*
class Node{
    var row:Int
    var column:Int
    var board:Board
    var children:[Node] = []
    weak var parent: Node?
    init(r:Int,c:Int,b: Board){
        row = r;column = c; board = b
    }
    func add(child: Node){
        children.append(child)
        child.parent = self
    }
}
*/

class Computer{
    weak var delegate:support?
    var computerColor:pt!
    var playerColor:pt!
    var currentBoard:[[othello]]!
    var totalMovesAhead = 5
    var playerFirst:Bool

    init(computerColor:pt, playerFirst:Bool){
        self.computerColor = computerColor
        self.playerColor = (computerColor == .BLACK) ? .WHITE : .BLACK
        self.playerFirst = playerFirst
    }
    
    func retrieveBoard()->[[othello]]{
        return((delegate?.getCurrentBoard())!)
    }
    
    func move(r:Int,c:Int){
        delegate?.setPiece(r: r,c: c)
    }
    
    func computerToMove(){
        // Retrieve current board and instantiate class for computer color
        let b = Board(board: retrieveBoard(), forColor: computerColor)
        
        // Check if computer has moves available
        if(b.movesAvailable > 0){
            var m = moves(r: 0, c: 0, flpd: 0)
            if(b.getBestMove(move: &m) == true){
                if(!playerFirst){
                    delegate?.saveBoard(r: m.r, c: m.c, forComputer: true)
                }
                move(r: m.r, c: m.c)
            }
            
        }else{
            //If not, check if player has moves available. If so,prompt
            // player to move
            if(Board(board: retrieveBoard(),
                     forColor: playerColor).movesAvailable > 0){
                delegate?.updateStatus(computerNext: false)
            }else{
                // Neither can move so count pieces and determine winner
                var blk=0,wht=0
                delegate?.updateCount(black: &blk, white: &wht)
                if(blk > wht){
                    delegate?.displayWinner(color: .BLACK)
                }else if(wht > blk){
                    delegate?.displayWinner(color: .WHITE)
                }else{
                    delegate?.displayWinner(color: .EMPTY)
                }
            }
        }
  
    }
/*
    func findMoves(parent:Node,movesAhead:Int){
        var nm:[moves]=[]
        let opCol:pt = (parent.board.color == .WHITE) ? .BLACK : .WHITE
        let colstr = (parent.board.color == .WHITE) ? "White" : "Black"
        
        if(parent.board.getValidMoves(arr: &nm) > 0 && movesAhead < totalMovesAhead){
            print(String(format: "For parent node r:%d c:%d, move color: %@",
                         parent.row,parent.column,colstr))
            print(String(format: "Available Moves: %@",nm))
            for move in nm{
                let newBoard = parent.board.getBoardAfterMove(r: move.r, c: move.c, color: parent.board.color)
                let aNode = Node(r: move.r, c: move.c, b: Board(board: newBoard, forColor: opCol))
                parent.add(child: aNode)
                findMoves(parent: aNode, movesAhead: movesAhead+1)
            }
        }
        // This node is the highest on the tree
        print("ppp")
    }
    
    func calcScore(board:Board,color:pt){
        var gameComplete:Bool=true
        let b = board.getBoard()
        for r in 0...7{ for c in 0...7{
            if(b[r][c].piece == .EMPTY){gameComplete = false}
            }
        }
        
        if gameComplete == true{
        }
    }*/
}
