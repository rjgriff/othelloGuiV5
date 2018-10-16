//
//  square.swift
//  othelloGui
//
//  Created by Richard Griffin on 10/8/18.
//  Copyright © 2018 Richard Griffin. All rights reserved.
//

import Cocoa

class square: NSBox {
    var row:Int,col:Int
    var pim:NSImageView!
    init(col:Int,row:Int,pieceWhite:Bool){
        self.col = (col-2)/80
        self.row = 7 - (row-2)/80
        super.init(frame:NSMakeRect(CGFloat(col), CGFloat(row), 80, 80 ))
        self.boxType = .custom
        self.borderType = .bezelBorder
        self.titlePosition = NSBox.TitlePosition.noTitle
        self.fillColor = NSColor.systemGreen
        pim = NSImageView(frame: NSMakeRect(0, 0, 65, 65))
        self.addSubview(pim)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func highlight(hl:hl){
        
        switch(hl){
        case .OFF: self.fillColor = NSColor.systemGreen
        case .AV: self.fillColor = NSColor.lightGray
        case .HL:self.fillColor = NSColor.systemOrange
        default:break
        }
       
    }
    
    func setPiece(pc:pt){
        switch(pc){
        case .WHITE:self.pim.image = NSImage(named: "wp")
        case .EMPTY:self.pim.image = nil
        case .BLACK:self.pim.image = NSImage(named: "bp")
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        let squareVal = ["col": col, "row": row] as [String : Any]
        NotificationCenter.default.post(name:
            NSNotification.Name(rawValue: "squareSelected"),
                                        object: nil,userInfo: squareVal)
        
    }
}
