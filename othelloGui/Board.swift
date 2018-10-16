//
//  board.swift
//  othelloGuiV5
//
//  Created by Richard Griffin on 10/14/18.
//  Copyright © 2018 Richard Griffin. All rights reserved.
//

import Foundation
struct moves:Equatable{
    var r:Int,c:Int,flpd:Int
    init(r:Int,c:Int,flpd:Int){
        self.r=r;self.c=c;self.flpd = flpd
    }
    static func == (lhs:moves,rhs:moves)->Bool{
        return (lhs.r == rhs.r && lhs.c == rhs.c)
    }
}
enum direction:Int{case N=0,S,E,W,NE,NW,SE,SW}
extension direction{
    static var drtnArray:[direction]{
        var a:[direction]=[]
        switch direction.N{
        case .N:a.append(.N);fallthrough
        case .S:a.append(.S);fallthrough
        case .E:a.append(.E);fallthrough
        case .W:a.append(.W);fallthrough
        case .NE:a.append(.NE);fallthrough
        case .NW:a.append(.NW);fallthrough
        case .SE:a.append(.SE);fallthrough
        case .SW:a.append(.SW)
        }
        return a
    }
}

class Board{
    var board:[[othello]]
    var color:pt
    var opColor:pt
    var movesAvailable=0
    var myMoves:[moves]=[]
    var piecesPlaced=0
    let rating:[[Int]] = [[10,1,9,5,5,9,1,10],
                          [1,1,4,4,4,4,1,1],
                          [9,3,6,6,6,6,3,9],
                          [5,4,6,6,6,6,4,5],
                          [5,4,6,6,6,6,4,5],
                          [9,3,6,6,6,6,3,9],
                          [1,1,4,4,4,4,1,1],
                          [10,1,9,5,5,9,1,10]]

    init(board:[[othello]],forColor:pt){
        var flpCnt=0
        self.board = board
        color = forColor
        opColor = (forColor == .WHITE) ? .BLACK : .WHITE
        for r in 0...7{
            for c in 0...7{
                if getVal(r: r, c: c) != .EMPTY{piecesPlaced += 1}
                if(isSquareValid(r: r, c: c, flpdCnt: &flpCnt)){
                    //Make sure it's not a duplicate
                    if(!myMoves.contains(moves(r:r,c:c, flpd: flpCnt))){
                        myMoves.append(moves(r: r, c: c, flpd: flpCnt))
                        movesAvailable += 1
                    }
                    
                }
            }
        }
    }
    
    func getVal(r:Int,c:Int)->pt{
        return board[r][c].piece
    }

    func isSquareValid(r:Int,c:Int,flpdCnt:inout Int)->Bool{
        var flpd:[cp]=[]
        // If square is not empty, then return
        if(getVal(r: r, c: c) != .EMPTY){return false}
        
        // Square must be next to a piece
        for d in direction.drtnArray{
            if(checkForSandwich(drctn: d, strtR: r, strtC: c) == true){
                getPiecesToBeFlipped(drctn: d, strtR: r, strtC: c, ca: &flpd)
            }
        }
        flpdCnt = flpd.count
        if(flpdCnt > 0){return true}
        return false
    }
    func checkForSandwich(drctn:direction,
                          strtR:Int,strtC:Int)->Bool{
        var nextR=0,nextC=0,iR=0,iC=0,retVal:Bool!,cell:pt!
        let opColor:pt = (self.color == .WHITE) ? .BLACK : .WHITE
        
        // If we can move in that direction and cell is next to opposing color
        if(getNext(drtn: drctn, r: strtR, c: strtC, nextR: &nextR, nextC: &nextC)
            == true && getVal(r: nextR, c: nextC) == opColor){
            // Check we have a sandwich
            repeat{
                retVal = getNext(drtn: drctn, r: nextR, c: nextC,
                                 nextR: &iR, nextC: &iC)
                nextR = iR;nextC = iC
                if(retVal == true){cell = getVal(r: nextR, c: nextC) }
            }while(retVal == true && cell == opColor)
            
            if(retVal == true && cell == self.color){
                // We have a sandwich
                return true
            }else{return false}
        }
        return false
    }
    
    func getPiecesToBeFlipped(drctn:direction,
                              strtR:Int,strtC:Int, ca:inout [cp]){
        var iR1 = strtR,iC1 = strtC,iR2=0,iC2=0,retVal:Bool!
        var piece:pt!
        
        repeat{
            if(!ca.contains(cp(r: iR1, c: iC1, color: color))){
                ca.append(cp(r: iR1, c: iC1, color: color))
            }
            
            retVal = self.getNext(drtn: drctn, r: iR1, c: iC1, nextR: &iR2, nextC: &iC2)
            iR1 = iR2;iC1 = iC2
            piece = self.getVal(r: iR1, c: iC1)
        }while(retVal == true && piece != color)
    }
    
    func getNext(drtn:direction,r:Int,c:Int,nextR:inout Int,nextC: inout Int)->Bool{
        nextR = r;nextC = c
        switch(drtn){
        case .N:    nextR -= 1
        case .S:    nextR += 1
        case .E:    nextC += 1;
        case .W:    nextC -= 1;
        case .NE:   nextR -= 1;nextC += 1;
        case .NW:   nextR -= 1;nextC -= 1;
        case .SE:   nextR += 1;nextC += 1;
        case .SW:   nextR += 1;nextC -= 1;
        }
        
        if(nextC < 0 || nextR < 0 || nextC > 7 || nextR > 7){
            return false
        }
        return true
    }

    func getScore(r:Int,c:Int)->Int{
        //return rating[r][c]
        
        // If piece is on the edge, don't place it next to an opposing
        // piece if possible, but if we can put it in the middle of two
        // opposing pieces, that is better
        if(r == 0 || r == 7){
            // Not a corner piece
            if(c > 0 && c < 7){
                if(getVal(r: r, c: c+1) == opColor){
                    if(getVal(r: r, c: c-1) == opColor){
                        // we can stick it in the middle so boost score
                        return(rating[r][c]+2)
                    }
                    return (rating[r][c] - 2)
                }
                if(getVal(r: r, c: c-1) == opColor){
                    if(getVal(r: r, c: c+1) == opColor){
                        // we can stick it in the middle so boost score
                        return(rating[r][c]+2)
                    }
                    return (rating[r][c] - 2)
                }
            }
        }
        if(c == 0 || c == 7){
            // Not a corner piece
            if(r > 0 && r < 7){
                if(getVal(r: r+1, c: c) == opColor){
                    if(getVal(r: r-1, c: c) == opColor){
                        // we can stick it in the middle so boost score
                        return(rating[r][c]+2)
                    }
                    return (rating[r][c] - 2)
                }
                if(getVal(r: r-1, c: c) == opColor){
                    if(getVal(r: r+1, c: c) == opColor){
                        // we can stick it in the middle so boost score
                        return(rating[r][c]+2)
                    }
                    return (rating[r][c] - 2)
                }
            }
        }
        return rating[r][c]
    }
    
    func getBestMove(move:inout moves)->Bool{
        var rtg:[moves]=[]
        var same:[moves]=[]
        if(self.movesAvailable > 0){
            for m in self.myMoves{
                rtg.append(moves(r: m.r, c: m.c, flpd: getScore(r: m.r, c: m.c)))
            }
            
            //Sort by highest score - flpd is used for the score
            let srtdRtg =  rtg.sorted(by: {$0.flpd > $1.flpd})
            
            // For those with equal scores, choose the one that flips the
            // fewest pieces
            let hr = srtdRtg[0].flpd
            
            for idx in srtdRtg{
                if idx.flpd == hr{
                    same.append(moves(r: idx.r, c: idx.c,
                                      flpd: getVM(move: moves(r: idx.r,c: idx.c, flpd: 0))))
                }
            }
            var rst:[moves]=[]
            // Sort by lowest number of pieces flipped
            if(piecesPlaced < 40){
                rst = same.sorted(by: {$0.flpd < $1.flpd})
            }else{
                rst = same.sorted(by: {$0.flpd > $1.flpd})
                
            }
            
            // Return the move with highest rating and lowest # of pieces flipped
            move = rst[0]
            return true
        }
        return false
    }
    
    func getVM(move:moves)->Int{
        for m in self.myMoves{
            if m.r == move.r && m.c == move.c{
                return m.flpd
            }
        }
        return 100
    }
 /*   func getValidMoves(arr:inout[moves])->Int{
        var count=0
        var flpd=0
        for r in 0...7{
            for c in 0...7{
                if(isSquareValid(r: r, c: c, flpdCnt: &flpd)==true){
                    if(!arr.contains(moves(r:r,c:c, flpd: flpd))){
                        arr.append(moves(r: r, c: c, flpd: flpd));count += 1
                    }
                }
            }
        }
        return count
    }*/
    
    func getBoardAfterMove(r:Int,c:Int,color:pt)->[[othello]]{
        var ca:[cp]=[]
        // Get list of pieces changed to new color including
        // piece just placed
        getFlippedPiecesAfterMove(r:r,c:c,flipped: &ca)
        // Update board
        var newBoard = self.board
        for p in ca{
            newBoard[p.r][p.c].piece = p.color
        }
        return newBoard
    }
 
    func getFlippedPiecesAfterMove(r:Int,c:Int,flipped:inout [cp]){
        for d in direction.drtnArray{
            if(checkForSandwich(drctn: d, strtR: r, strtC: c) == true){
                getPiecesToBeFlipped(drctn: d, strtR: r, strtC: c, ca: &flipped)
            }
        }
    }
    
    func isGameComplete()->Bool{
        var gameComplete:Bool=true
        
        for r in 0...7{ for c in 0...7{
            if(self.board[r][c].piece == .EMPTY){gameComplete = false}
            }
        }
        return gameComplete
    }
    
    func getNumPieces()->Int{
        var count=0
        for r in 0...7{for c in 0...7{if board[r][c].piece == color{count+=1}}}
        return count
    }
    
    func getBoard()->[[othello]]{
        return self.board
    }
   
}
