//
//  SpeakerWindowController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/20/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit

final class SpeakerWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        configureWindowAppearance()
    }
    
    private func configureWindowAppearance() {
        
        if let window = self.window {
            
            if let view = window.contentView {
                view.wantsLayer = true
            }
            
            window.styleMask.insert(.FullSizeContentView)
            window.titleVisibility = .Hidden
            window.titlebarAppearsTransparent = true
        }
    }
}
