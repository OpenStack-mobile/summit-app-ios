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

final class MainWindowController: NSWindowController, SearchableController, NSSearchFieldDelegate, SummitActivityHandling {
    
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
    
    // Controller references
    
    private var preferencesWindowController: NSWindowController?
    
    private var contentViewControllers = [Content: NSViewController]()
    
    private var childContentWindowControllers = [ChildContent: NSWindowController]()
    
    // MARK: - Loading
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window!.titleVisibility = .Hidden
        
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
    
    @IBAction func contentTabChanged(sender: NSSegmentedControl) {
        
        self.currentContent = Content(rawValue: sender.selectedSegment)!
    }
    
    @IBAction func searchTermChanged(sender: NSSearchField) {
        
        self.searchTerm = sender.stringValue
    }
    
    @IBAction func showPreferences(sender: AnyObject? = nil) {
        
        preferencesWindowController = NSStoryboard(name: "Main", bundle: nil)
            .instantiateControllerWithIdentifier("Preferences") as? NSWindowController
        
        preferencesWindowController?.showWindow(sender)
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
        
        if let cachedViewController = contentViewControllers[content] {
            
            contentViewController = cachedViewController
            
        } else {
            
            let storyboard = NSStoryboard(name: storyboardName, bundle: nil)
            
            let viewController = storyboard.instantiateInitialController() as? NSViewController
            
            contentViewControllers[content] = viewController
            
            contentViewController = viewController
        }
        
        // restore old frame
        window!.setFrame(windowFrame, display: true)
        
        // apply filter to new content view controller
        filter()
    }
    
    private func show(childContent childContent: ChildContent) {
        
        let windowController: NSWindowController
        
        // try to get existing window
        if let existingController = self.childContentWindowControllers[childContent] {
            
            windowController = existingController
            
        } else {
            
            // instantiate controller
            switch childContent.content {
                
            case .event:
                
                windowController = NSStoryboard(name: "Events", bundle: nil).instantiateControllerWithIdentifier("EventWindowController") as! NSWindowController
                
            case .speaker:
                
                windowController = NSStoryboard(name: "Speakers", bundle: nil).instantiateControllerWithIdentifier("SpeakerWindowController") as! NSWindowController
            }
            
            // configure
            guard let contentController = windowController as? ContentController
                else { fatalError("\(windowController) is not a `ContentController`") }
            
            contentController.contentIdentifier = childContent.identifier
            
            // hold reference
            childContentWindowControllers[childContent] = windowController
            
            let window = windowController.window!
            
            // release when closed
            if window.releasedWhenClosed {
                
                NSNotificationCenter.defaultCenter().addObserver(self,
                                                                 selector: #selector(windowWillClose),
                                                                 name: NSWindowWillCloseNotification,
                                                                 object: window)
            }
        }
        
        // show window
        windowController.showWindow(nil)
    }
    
    // MARK: - NSSearchFieldDelegate
    
    func searchFieldDidStartSearching(sender: NSSearchField) {
        
        
    }
    
    func searchFieldDidEndSearching(sender: NSSearchField) {
        
        
    }
    
    // MARK: - SummitActivityHandling
    
    func view(data: AppActivitySummitDataType, identifier: Identifier) -> Bool  {
        
         // find in cache
         guard let managedObject = try! data.managedObject.find(identifier, context: Store.shared.managedObjectContext)
         else { return false }
         
         switch data {
         
         case .event:
            
            show(childContent: ChildContent(content: .event, identifier: identifier))
         
         case .speaker:
         
            show(childContent: ChildContent(content: .speaker, identifier: identifier))
         
         case .video:
         
            let video = Video(managedObject: managedObject as! VideoManagedObject)
            
            guard let url = NSURL(string: "https://www.youtube.com/watch?v=" + video.youtube)
                else { return false }
         
            return NSWorkspace.sharedWorkspace().openURL(url)
         
         case .venue:
            
            break
         
         case .venueRoom:
            
            break
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
            
            showPreferences()
        }
    }
    
    // MARK: - Notifications
    
    @objc private func windowWillClose(notification: NSNotification) {
        
        let window = notification.object as! NSWindow
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: NSWindowWillCloseNotification,
                                                            object: window)
        
        guard let controllerIndex = childContentWindowControllers.indexOf({ $0.1 === window.windowController })
            else { fatalError("Invalid notification: \(notification)") }
        
        // will release controller, and window
        childContentWindowControllers.removeAtIndex(controllerIndex)
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

private struct ChildContent: Hashable {
    
    enum Content: String {
        
        case event
        case speaker
    }
    
    let content: Content
    
    let identifier: Identifier
    
    let hashValue: Int
    
    init(content: Content, identifier: Identifier) {
        
        self.content = content
        self.identifier = identifier
        
        // more efficient and simple hash than computed
        self.hashValue = "\(content)\(identifier)".hashValue
    }
}

private func == (lhs: ChildContent, rhs: ChildContent) -> Bool {
    
    return lhs.content == rhs.content
        && lhs.content == rhs.content
}
