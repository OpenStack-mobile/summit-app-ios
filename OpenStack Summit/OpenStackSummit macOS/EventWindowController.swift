//
//  EventWindowController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/20/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit
import CoreSummit

final class EventWindowController: NSWindowController {
    
    var event: Identifier? {
        
        didSet { configureView() }
    }
    
    var eventViewController: EventDetailViewController {
        
        return contentViewController as! EventDetailViewController
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
        eventViewController.event = event
        
        // set title
        if let identifier = self.event,
            let event = try! Event.find(identifier, context: Store.shared.managedObjectContext) {
            
            window?.title = event.name
            
        } else {
            
            window?.title = "Event"
        }
    }
}
