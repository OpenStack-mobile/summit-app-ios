//
//  ContentBackgroundView.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/20/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Cocoa

@IBDesignable final class ContentBackgroundView: NSView {

    @IBInspectable var backgroundColor = NSColor.black {
        
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        backgroundColor.set()
        NSRectFill(dirtyRect)
    }
}
