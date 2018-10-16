//
//  model.swift
//  othelloGui
//
//  Created by Richard Griffin on 10/8/18.
//  Copyright © 2018 Richard Griffin. All rights reserved.
//

import Foundation
import AppKit
protocol support:class{
    func setPiece(r: Int,c:Int)
    func getCurrentBoard()->[[othello]]
}
enum pt:Int{case EMPTY=0,WHITE,BLACK}
struct othello{
    var piece:pt, bkgrd:hl
    init(piece:pt,bkgrd:hl){
        self.piece = piece;self.bkgrd = bkgrd
    }
}
struct cp:Equatable{
    var r:Int,c:Int,color:pt
    init(r:Int,c:Int,color:pt){
        self.r=r;self.c=c;self.color=color
    }
    static func == (lhs:cp,rhs:cp)->Bool{
        return (lhs.r == rhs.r && lhs.c == rhs.c)
    }
}


class Model{
    weak var delegate:updateGrid?
    var board = [[othello]](repeating: [othello](repeating:
        othello(piece: .EMPTY,bkgrd: .OFF), count: 8), count: 8)
    var updateBoardFlag:Bool = true, delayTime:Int=500000,playerColor:pt
    var playerFirst:Bool,computerColor:pt
    var compClass:Computer!
    init(playerFirst:Bool){
        self.playerFirst = playerFirst
        (self.playerColor,self.computerColor) = (playerFirst == true)
            ? (.BLACK, .WHITE) : (.WHITE, .BLACK)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.clicked(notification:)),
            name: NSNotification.Name(rawValue: "squareSelected"), object: nil)
        
        compClass = nil
        compClass = Computer(computerColor: self.computerColor)
        compClass.delegate = self
    }
    
    func initBoard(){
        resetBoard()
        setPiece(row: 3, column: 3, toColor: .WHITE, sq: .OFF)
        setPiece(row: 3, column: 4, toColor: .BLACK, sq: .OFF)
        setPiece(row: 4, column: 3, toColor: .BLACK, sq: .OFF)
        setPiece(row: 4, column: 4, toColor: .WHITE, sq: .OFF)
        var blk=0,wht=0
        updateCount(black: &blk, white: &wht)
        
        if(playerFirst){
            highlightAvailable(forComputer: false)
        }else{
            updateStatus(computerNext: true)
            compClass.computerToMove()
        }
    }
    
    // Method called once square is selected
    @objc func clicked(notification:NSNotification){
        //   if(computersTurn == true){return}
        let row = notification.userInfo?["row"] as? Int
        let col = notification.userInfo?["col"] as? Int
        let b = Board(board: self.board, forColor: self.playerColor)
        var flpCnt=0
        if(b.isSquareValid(r:row!, c: col!, flpdCnt: &flpCnt) == true){
            updateBoard(r: row!, c: col!, forComputer: false)
        }
    }
    private func updateBoard(r:Int,c:Int,forComputer:Bool){
        var ca:[cp] = []
        let color = getColor(forComputer: forComputer)
        let b = Board(board: self.board, forColor: color)
        b.getFlippedPiecesAfterMove(r: r, c: c, flipped: &ca)
        simulateFlip(forComputer: forComputer, flipped: ca)
    }
    
    private func simulateFlip(forComputer:Bool, flipped:[cp]){
        let g = DispatchGroup()
        g.enter()
        DispatchQueue.global().async {
            var first:Bool = true
            for p in flipped{
                DispatchQueue.main.async{
                    if(first == true){
                        self.resetHighlight(hlt: false)
                        self.setPiece(row: p.r, column: p.c, toColor: p.color, sq: .HL)
                    }else{
                        self.setPiece(row: p.r, column: p.c, toColor: p.color, sq: .OFF)
                        NSSound(named: NSSound.Name("Pop"))!.play()
                    }
                    first = false
                }
                usleep(useconds_t(self.delayTime))
            }
            g.leave()
        }
        
        g.notify(queue: .main){
            if(forComputer == true){
                self.highlightAvailable(forComputer: false)
            }
            if(self.isGameComplete(board: self.board) == false){
                if(forComputer == false){
                    self.updateStatus(computerNext: true)
                    self.compClass.computerToMove()
                }
                else{
                    self.updateStatus(computerNext: false)
                }
            }
        }
    }
    
    
    func setDelay(delay:Int){
        self.delayTime = delay
    }
    
    private func getColor(forComputer:Bool)->pt{
        if((forComputer == true && playerFirst == false) ||
            (forComputer == false && playerFirst == true)){
            return(.BLACK)
        }
        return .WHITE
    }
    
    private func setPiece(row:Int,column:Int,toColor:pt,sq:hl){
        board[row][column] = othello(piece: toColor, bkgrd: sq)
        self.delegate?.setPiece(value: toColor, row: row, col: column)
        self.delegate?.highlight(color: sq, row: row, col: column)
    }
    
    private func updateCount(black:inout Int,white:inout Int){
        black=0;white=0;
        for r in 0...7{
            for c in 0...7{
                if(board[r][c].piece == .WHITE){white+=1}
                if(board[r][c].piece == .BLACK){black+=1}
            }
        }
        delegate?.displayCount(black: black, white: white)
    }
    
    private func isGameComplete(board:[[othello]])->Bool{
        var blk=0,wht=0
        updateCount(black: &blk, white: &wht)
        let comp = Board(board: board, forColor: computerColor).movesAvailable
        let plyr = Board(board: board, forColor: playerColor).movesAvailable
      
        if(comp > 0 || plyr > 0){
            return false
        }
        if(blk > wht){delegate?.displayWinner(result: .BLACK)}
        else if(wht > blk){delegate?.displayWinner(result: .WHITE)}
        else{delegate?.displayWinner(result: .EMPTY)}
        resetHighlight(hlt: false)
        return true
    }

    private func resetBoard(){
        for r in 0...7{ for c in 0...7{
            setPiece(row: r, column: c, toColor: .EMPTY, sq: .OFF)
            }
        }
    }
    
    private func resetHighlight(hlt:Bool){
        for r in 0...7{ for c in 0...7{ rsthl(hlt: hlt, r: r, c: c)}}
    }
    
    func rsthl(hlt:Bool,r:Int,c:Int){
        if(hlt == true && self.board[r][c].bkgrd == .AV){
            self.board[r][c].bkgrd = .OFF
            self.delegate?.highlight(color: .OFF, row: r, col: c)
        }else{
            self.board[r][c].bkgrd = .OFF
            self.delegate?.highlight(color: .OFF, row: r, col: c)
        }
    }
    private func highlightAvailable(forComputer:Bool){
        resetHighlight(hlt: true)
        let c = getColor(forComputer: forComputer)
        let b = Board(board: self.board, forColor: c)
        var flpcnt=0
        for r in 0...7{
            for c in 0...7{
                if(b.isSquareValid(r: r, c: c, flpdCnt: &flpcnt)==true){
                    self.board[r][c].bkgrd = .AV
                    self.delegate?.highlight(color: .AV, row: r, col: c)
                }
            }
        }
    }
    
    private func updateStatus(computerNext:Bool){
        delegate?.updateStatus(computerTurn: computerNext)
    }
}

extension Model:support{
    
    func setPiece(r: Int,c:Int){
        updateBoard(r: r, c: c, forComputer: true)
    }
    
    func getCurrentBoard()->[[othello]]{
        return board
    }
}
