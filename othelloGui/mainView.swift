//
//  mainView.swift
//  othelloGui
//
//  Created by Richard Griffin on 10/8/18.
//  Copyright © 2018 Richard Griffin. All rights reserved.
//

import Cocoa

class mainView: NSView {
    
    var arr:NSArray = []
    
    override func awakeFromNib() {
        var sq:NSView
        for row in 0...7{
            for column in 0...7{
                let r = (row * 80) + 2
                let c = (column * 80) + 2
                sq = square(col: c, row: r, pieceWhite: true)
                sq.wantsLayer = true
                sq.layer?.backgroundColor = NSColor.systemGreen.cgColor
                addSubview(sq)
            }
        }
        // add subviews to an array
        self.arr = self.subviews as NSArray
    }
    func highlightSquare(color:hl,row:Int,col:Int){
        var sq:square,index:Int
        index = self.getIndex(col: col, row: row)
        sq = self.arr.object(at: index) as! square
        sq.highlight(hl: color)
    }
    func setPiece(Value:pt,row:Int,col:Int){
        var sq:square,index:Int
        
        index = self.getIndex(col: col, row: row)
        sq = self.arr.object(at: index) as! square
        sq.setPiece(pc: Value)
    }
    
    func getIndex(col:Int,row:Int)->Int{
        return (((7-row)*8)+col)
    }
    
}
