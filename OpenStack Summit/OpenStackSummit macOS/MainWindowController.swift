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

final class MainWindowController: NSWindowController, NSSearchFieldDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var contentSegmentedControl: NSSegmentedControl!
    
    // MARK: - Properties
    
    var mainViewController: MainViewController {
        
        return contentViewController as! MainViewController
    }
    
    // MARK: - Loading
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window!.titleVisibility = .Hidden
    }
    
    // MARK: - Actions
    
    @IBAction func contentTabChanged(sender: NSSegmentedControl) {
        
        self.mainViewController.currentContent = MainViewController.Content(rawValue: sender.selectedSegment)!
    }
    
    @IBAction func searchTermChanged(sender: NSSearchField) {
        
        self.mainViewController.searchTerm = sender.stringValue
    }
    
    // MARK: - NSSearchFieldDelegate
    
    func searchFieldDidStartSearching(sender: NSSearchField) {
        
        
    }
    
    func searchFieldDidEndSearching(sender: NSSearchField) {
        
        
    }
}
