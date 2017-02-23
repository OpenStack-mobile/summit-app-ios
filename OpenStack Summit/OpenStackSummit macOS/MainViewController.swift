//
//  MainViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/23/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit
import CoreSummit

final class MainViewController: NSViewController, SearchableController, SummitActivityHandling {
    
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
    
    private(set) var contentViewController: NSViewController!
    
    private var summitObserver: Int?
    
    private var contentViewControllersCache = [Content: NSViewController]()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        summitObserver = SummitManager.shared.summit.observe { [weak self] _ in self?.configureView() }
        
        configureView()
        
        // Show preferences
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            
            if try! Summit.find(SummitManager.shared.summit.value, context: Store.shared.managedObjectContext) == nil {
                
                self?.showPreferences()
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func showPreferences(sender: AnyObject? = nil) {
        
        self.performSegueWithIdentifier("showPreferences", sender: nil)
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        assert(viewLoaded)
        
        // set window name
        
        var title = "OpenStack Summit"
        
        let summitID = SummitManager.shared.summit.value
        
        if let summit = try! Summit.find(summitID, context: Store.shared.managedObjectContext) {
            
            title += " - " + summit.name
        }
        
        self.title = title
        
        // update content view controller
        updateContent()
    }
    
    private func filter() {
        
        // filter content view controller
        (contentViewController as? SearchableController)?.searchTerm = self.searchTerm
    }
    
    private func updateContent() {
        
        // set content tab
                
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
    
    // MARK: - SummitActivityHandling
    
    func view(data: AppActivitySummitDataType, identifier: Identifier) -> Bool  {
        
        // find in cache
        guard let managedObject = try! data.managedObject.find(identifier, context: Store.shared.managedObjectContext)
            else { return false }
        
        switch data {
            
        case .event:
            
            
            
        case .speaker:
            
            
            
        case .video:
            
            let video = Video(managedObject: managedObject as! VideoManagedObject)
            
            guard let url = NSURL(string: "https://www.youtube.com/watch?v=" + video.youtube)
                else { return false }
            
            NSWorkspace.sharedWorkspace().openURL(url)
            
        case .venue
            
        case .venueRoom:
            
            
        }
        
        return true
    }
    
    func view(screen: AppActivityScreen) {
        
        switch screen {
            
        case .venues:
            
            self.window!.makeKeyAndOrderFront(nil)
            self.currentContent = .venues
            
        case .events:
            
            self.window!.makeKeyAndOrderFront(nil)
            self.currentContent = .events
            
        case .speakers:
            
            self.window!.makeKeyAndOrderFront(nil)
            self.currentContent = .speakers
            
        case .about:
            
            self.window!.makeKeyAndOrderFront(nil)
            self.currentContent = .venues
        }
    }
}

// MARK: - Supporting Types

extension MainViewController {
    
    enum Content: Int {
        
        case events
        case venues
        case speakers
        case videos
        
        init() { self = .events }
    }
}
