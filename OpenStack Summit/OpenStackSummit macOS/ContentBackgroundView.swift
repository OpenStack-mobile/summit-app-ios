//
//  ContentBackgroundView.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/20/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Cocoa

@IBDesignable final class ContentBackgroundView: NSView {

    @IBInspectable var backgroundColor = NSColor.blackColor() {
        
        didSet {
            setNeedsDisplayInRect(bounds)
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        backgroundColor.set()
        NSRectFill(dirtyRect)
    }
}
