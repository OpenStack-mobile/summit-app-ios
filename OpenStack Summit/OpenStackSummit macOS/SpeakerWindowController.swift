//
//  SpeakerWindowController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/20/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit
import CoreSummit

final class SpeakerWindowController: NSWindowController {
    
    var speaker: Identifier? {
        
        didSet { configureView() }
    }
    
    var speakerViewController: SpeakerViewController {
        
        return contentViewController as! SpeakerViewController
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        configureWindowAppearance()
        
        configureView()
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
    
    private func configureView() {
        
        // configure child view controller
        speakerViewController.speaker = speaker
        
        // set title
        if let identifier = self.speaker,
            let speaker = try! Speaker.find(identifier, context: Store.shared.managedObjectContext) {
            
            window?.title = speaker.name
            
        } else {
            
            window?.title = "Speaker"
        }
    }
}
