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
    
    @IBOutlet private(set) weak var contentSegmentedControl: NSSegmentedControl!
    
    @IBOutlet private(set) weak var toggleSidebarToolbarItem: NSToolbarItem!
    
    private var summitObserver: Int?
    
    private var contentViewControllersCache = [String: NSViewController]()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.titleVisibility = .Hidden
        
        summitObserver = SummitManager.shared.summit.observe { [weak self] _ in self?.updateTitle() }
        
        updateTitle()
        
        // update content view controller
        contentTabChanged(contentSegmentedControl)
    }
    
    private func updateTitle() {
        
        var title = "OpenStack Summit"
        
        let summitID = SummitManager.shared.summit.value
        
        if let summit = try! Summit.find(summitID, context: Store.shared.managedObjectContext) {
            
            title += " - " + summit.name
        }
        
        window?.title = title
    }
    
    // MARK: - Actions
    
    @IBAction func contentTabChanged(sender: NSSegmentedControl) {
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        
        let content = ContentTab(rawValue: sender.selectedSegment)!
        
        let contentViewControllerID: String
                
        switch content {
        case .events: contentViewControllerID = "Events"
        case .venues: contentViewControllerID = "Venues"
        case .speakers: contentViewControllerID = "Speakers"
        case .videos: contentViewControllerID = "Videos"
        }
        
        if let cachedViewController = contentViewControllersCache[contentViewControllerID] {
            
            contentViewController = cachedViewController
            
        } else {
            
            let viewController = storyboard.instantiateControllerWithIdentifier(contentViewControllerID) as! NSViewController
            
            contentViewControllersCache[contentViewControllerID] = viewController
            
            contentViewController = viewController
        }
        
        toggleSidebarToolbarItem.enabled = (contentViewController is NSSplitViewController)
    }
    
    @IBAction func toggleSidebar(sender: NSToolbarItem) {
        
        (contentViewController as? NSSplitViewController)?.toggleSidebar(sender)
    }
}

// MARK: - Supporting Types

private extension MainWindowController {
    
    enum ContentTab: Int {
        
        case events
        case venues
        case speakers
        case videos
    }
}
