//
//  MainWindowController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/19/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit
import CoreSummit

final class MainWindowController: NSWindowController {
    
    private var summitObserver: Int?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.titleVisibility = .Hidden
        
        summitObserver = SummitManager.shared.summit.observe { [weak self] _ in self?.updateTitle() }
        
        updateTitle()
    }
    
    private func updateTitle() {
        
        var title = "OpenStack Summit"
        
        let summitID = SummitManager.shared.summit.value
        
        if let summit = try! Summit.find(summitID, context: Store.shared.managedObjectContext) {
            
            title += " - " + summit.name
        }
        
        window?.title = title
    }
}
