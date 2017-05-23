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
    
    private var childContentWindowControllers = Set<NSWindowController>()
    
    // MARK: - Loading
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window!.titleVisibility = .hidden
        
        summitObserver = SummitManager.shared.summit.observe { [weak self] _ in self?.configureView() }
        
        configureView()
        
        // Show preferences
        
        let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: delayTime) { [weak self] in
            
            if try! Summit.find(SummitManager.shared.summit.value, context: Store.shared.managedObjectContext) == nil {
                
                self?.showPreferences()
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func contentTabChanged(_ sender: NSSegmentedControl) {
        
        self.currentContent = Content(rawValue: sender.selectedSegment)!
    }
    
    @IBAction func searchTermChanged(_ sender: NSSearchField) {
        
        self.searchTerm = sender.stringValue
    }
    
    @IBAction func showPreferences(_ sender: AnyObject? = nil) {
        
        preferencesWindowController = NSStoryboard(name: "Main", bundle: nil)
            .instantiateController(withIdentifier: "Preferences") as? NSWindowController
        
        preferencesWindowController?.showWindow(sender)
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        assert(isWindowLoaded)
        
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
    
    private func show<T: Unique>(childContent contentType: T.Type, identifier: Identifier) {
        
        let windowController: NSWindowController
        
        // try to get existing window
        if let existingController = childContentWindowControllers
            .first(where: { ($0 as? ContentController)?.contentIdentifier == identifier
                && (type(of: $0) as? ContentController.Type)?.contentType == contentType }) {
            
            windowController = existingController
            
        } else {
            
            // instantiate controller
            switch contentType {
                
            case is Event.Type:
                
                windowController = NSStoryboard(name: "Events", bundle: nil).instantiateController(withIdentifier: "EventWindowController") as! NSWindowController
                
            case is Speaker.Type:
                
                windowController = NSStoryboard(name: "Speakers", bundle: nil).instantiateController(withIdentifier: "SpeakerWindowController") as! NSWindowController
                
            default:
                
                fatalError("Cannot show \(contentType)")
            }
            
            // configure
            guard let contentController = windowController as? ContentController
                else { fatalError("\(windowController) is not a `ContentController`") }
            
            contentController.contentIdentifier = identifier
            
            // hold reference
            childContentWindowControllers.insert(windowController)
            
            let window = windowController.window!
            
            // release when closed
            NotificationCenter.default.addObserver(self,
                                                             selector: #selector(windowWillClose),
                                                             name: NSNotification.Name.NSWindowWillClose,
                                                             object: window)
        }
        
        // show window
        windowController.showWindow(nil)
    }
    
    // MARK: - NSSearchFieldDelegate
    
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
        
        
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        
        
    }
    
    // MARK: - SummitActivityHandling
    
    func view(data: AppActivitySummitDataType, identifier: Identifier)  {
        
         // find in cache
         guard let managedObject = try! data.managedObject.find(identifier, context: Store.shared.managedObjectContext)
            else { return }
         
         switch data {
         
         case .event:
            
            show(childContent: Event.self, identifier: identifier)
         
         case .speaker:
         
            show(childContent: Speaker.self, identifier: identifier)
         
         case .video:
         
            let video = Video(managedObject: managedObject as! VideoManagedObject)
            
            guard let url = URL(string: "https://www.youtube.com/watch?v=" + video.youtube)
                else { return }
         
            NSWorkspace.shared().open(url)
         
         case .venue:
            
            break
         
         case .venueRoom:
            
            break
         }
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
            
            self.showPreferences()
            
        case .inbox:
            
            break
        }
    }
    
    func search(_ searchTerm: String) {
        
        self.searchTerm = searchTerm
    }
    
    // MARK: - Notifications
    
    @objc private func windowWillClose(_ notification: Foundation.Notification) {
        
        let window = notification.object as! NSWindow
        
        NotificationCenter.default.removeObserver(self,
                                                            name: NSNotification.Name.NSWindowWillClose,
                                                            object: window)
        
        guard let controllerIndex = childContentWindowControllers.index(where: { $0.window === window })
            else { fatalError("Invalid notification: \(notification)") }
        
        // will release controller, and window
        childContentWindowControllers.remove(at: controllerIndex)
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
