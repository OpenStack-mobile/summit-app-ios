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

final class SpeakerWindowController: NSWindowController, ContentController {
    
    static let contentType: Any.Type = Speaker.self
    
    var contentIdentifier: Identifier = 0 {
        
        didSet { configureView() }
    }
    
    var speakerViewController: SpeakerViewController {
        
        return contentViewController as! SpeakerViewController
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        configureWindowAppearance()
    }
    
    private func configureWindowAppearance() {
        
        if let window = self.window {
            
            if let view = window.contentView {
                view.wantsLayer = true
            }
            
            window.styleMask.insert(.fullSizeContentView)
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
        }
    }
    
    private func configureView() {
        
        // configure child view controller
        speakerViewController.speaker = contentIdentifier
        
        // set title
        if let speaker = try! Speaker.find(contentIdentifier, context: Store.shared.managedObjectContext) {
            
            window?.title = speaker.name
            
        } else {
            
            window?.title = "Speaker"
        }
    }
}
