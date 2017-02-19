//
//  EventDatesViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/19/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit
import CoreSummit

final class EventDatesViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var outlineView: NSOutlineView!
    
    // MARK: - Properties
    
    private var summitCache: (start: NSDate, end: NSDate, timeZone: NSTimeZone, name: String)?
    
    private lazy var dateFormatter: NSDateFormatter = {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "MMMM d"
        
        return dateFormatter
    }()
    
    private var summitObserver: Int?
    
    // MARK: - Loading
    
    deinit {
        
        if let observer = summitObserver {
            
            SummitManager.shared.summit.remove(observer)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        summitObserver = SummitManager.shared.summit.observe { [weak self] _ in self?.configureView() }
        
        configureView()
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        if let summit = self.currentSummit {
            
            let start = summit.start.mt_startOfCurrentDay()
            
            let end = summit.end.mt_dateDaysAfter(1)
            
            let timeZone = NSTimeZone(name: summit.timeZone)!
            
            self.summitCache = (start: start, end: end, timeZone: timeZone, name: summit.name)
            
        } else {
            
            self.summitCache = nil
        }
    }
    
    // MARK: - NSOutlineViewDelegate
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        
        let cell = outlineView.makeViewWithIdentifier(tableColumn!.identifier, owner: nil) as! NSTableCellView
        
        let date = summitCache!.start.mt_dateDaysAfter(row)
        
        cell.textField?.stringValue = dateFormatter.stringFromDate(date)
        
        return cell
    }
    
    // MARK: - NSOutlineViewDataSource
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        
        guard let summit = summitCache
            else { return 0 }
        
        return summit.end.mt_daysSinceDate(summit.start)
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        
        return false
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        
        fatalError()
    }
    
    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        
        return NSObject()
    }
}
