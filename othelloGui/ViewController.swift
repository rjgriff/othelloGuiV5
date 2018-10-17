//
//  ViewController.swift
//  othelloGui
//
//  Created by Richard Griffin on 10/8/18.
//  Copyright © 2018 Richard Griffin. All rights reserved.
//

import Cocoa
protocol updateGrid:class{
    func setPiece(value: pt, row: Int, col: Int)
    func updateStatus(computerTurn:Bool)
    func displayCount(black:Int,white:Int)
    func highlight(color:hl,row:Int,col:Int)
    func displayWinner(result:pt)
}
enum hl:Int{case OFF=0, AV, HL,OH,IGNORE}

class ViewController: NSViewController {
    var m:Model!
    var playerFirst:Bool = false
    @IBOutlet var Board: mainView!
    @IBOutlet var status: NSTextField!
    @IBOutlet var blackCnt: NSTextField!
    @IBOutlet var whiteCnt: NSTextField!
    @IBOutlet var playBlack: NSButton!
    @IBOutlet var pub: NSPopUpButton!
    
    @IBAction func pubA(_ sender: Any) {
        let btn = sender as! NSPopUpButton
        let index = btn.indexOfSelectedItem
       
        switch(index){
        
        case 1: m.setDelay(delay: 0)
        case 2: m.setDelay(delay: 200000)
        case 3: m.setDelay(delay: 1500000)
        default: m.setDelay(delay: 500000)
        }
    }
    
    @IBAction func reDisplayMove(_ sender: Any) {
        m.reDisplayBoard()
    }
    
    @IBAction func newGame(_ sender: Any) {
        m = nil
        if(playBlack.state == .on){
            self.playerFirst = true
            m = Model(playerFirst: true)
            status.stringValue = "You go first"
        }
        else{
            self.playerFirst = false
            m = Model(playerFirst: false)
        }
        m.delegate = self
        m.initBoard()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pub.addItem(withTitle: "Default")
        pub.addItem(withTitle: "No Delay")
        pub.addItem(withTitle: "Fast")
        pub.addItem(withTitle: "Slow")
    }
    override func viewDidAppear() {
        view.window!.styleMask.remove(.resizable)
        view.window?.setFrame(NSRect(x: 300, y: 300, width: 850, height: 770), display: true)
    }
}

extension ViewController:updateGrid{
    func setPiece(value: pt, row: Int, col: Int){
        Board.setPiece(Value: value, row: row, col: col)
    }
    
    func updateStatus(computerTurn:Bool) {
        let yst = "Your turn", cst = "Computer's turn"
        status.stringValue = (computerTurn == true) ? cst : yst
    }
    func displayWinner(result:pt){
        let yw = "You win!!",cw = "Computer wins"

        switch result{
        case .BLACK:status.stringValue = (playerFirst == true) ? yw : cw
        case .WHITE:status.stringValue = (playerFirst == true) ? cw : yw
        case .EMPTY:status.stringValue = "It's a tie"
        }
    }
    func displayCount(black: Int, white: Int) {
        blackCnt.stringValue = String(black)
        whiteCnt.stringValue = String(white)
    }
    
    func highlight(color: hl, row: Int, col: Int) {
        Board.highlightSquare(color: color, row: row, col: col)
    }
}
