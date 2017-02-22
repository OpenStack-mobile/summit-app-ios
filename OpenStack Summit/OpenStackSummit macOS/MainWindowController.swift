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

final class MainWindowController: NSWindowController, SearchableController, NSSearchFieldDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var contentSegmentedControl: NSSegmentedControl!
    
    // MARK: - Properties
    
    var searchTerm = "" {
        
        didSet {
            
            // Return if the filter string hasn't changed.
            guard searchTerm != oldValue else { return }
            
            filter()
        }
    }
    
    var currentContent = Content() {
        
        didSet { updateContent() }
    }
    
    private var summitObserver: Int?
    
    private var contentViewControllersCache = [Content: NSViewController]()
    
    // MARK: - Loading
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window!.titleVisibility = .Hidden
        
        summitObserver = SummitManager.shared.summit.observe { [weak self] _ in self?.configureView() }
        
        configureView()
    }
    
    // MARK: - Actions
    
    @IBAction func contentTabChanged(sender: NSSegmentedControl) {
        
        self.currentContent = Content(rawValue: sender.selectedSegment)!
    }
    
    @IBAction func searchTermChanged(sender: NSSearchField) {
        
        self.searchTerm = sender.stringValue
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        assert(windowLoaded)
        
        // set window name
        
        var title = "OpenStack Summit"
        
        let summitID = SummitManager.shared.summit.value
        
        if let summit = try! Summit.find(summitID, context: Store.shared.managedObjectContext) {
            
            title += " - " + summit.name
        }
        
        window?.title = title
        
        // update content view controller
        updateContent()
    }
    
    private func filter() {
        
        // filter content view controller
        (contentViewController as? SearchableController)?.searchTerm = self.searchTerm
    }
    
    private func updateContent() {
        
        // set content tab
        
        let windowFrame = window!.frame
        
        let storyboardName: String
        
        let content = self.currentContent
        
        switch content {
        case .events: storyboardName = "Events"
        case .venues: storyboardName = "Venues"
        case .speakers: storyboardName = "Speakers"
        case .videos: storyboardName = "Videos"
        }
        
        // set content view controler
        
        if let cachedViewController = contentViewControllersCache[content] {
            
            contentViewController = cachedViewController
            
        } else {
            
            let storyboard = NSStoryboard(name: storyboardName, bundle: nil)
            
            let viewController = storyboard.instantiateInitialController() as? NSViewController
            
            contentViewControllersCache[content] = viewController
            
            contentViewController = viewController
        }
        
        // restore old frame
        window!.setFrame(windowFrame, display: true)
        
        // apply filter to new content view controller
        filter()
    }
    
    // MARK: - NSSearchFieldDelegate
    
    func searchFieldDidStartSearching(sender: NSSearchField) {
        
        
    }
    
    func searchFieldDidEndSearching(sender: NSSearchField) {
        
        
    }
}

// MARK: - Supporting Types

extension MainWindowController {
    
    enum Content: Int {
        
        case events
        case venues
        case speakers
        case videos
        
        init() { self = .events }
    }
}
