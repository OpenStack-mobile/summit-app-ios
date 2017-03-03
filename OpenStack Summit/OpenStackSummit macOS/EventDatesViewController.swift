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

final class EventDatesViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSOutlineViewDataSource {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var tableView: NSTableView!
    
    // MARK: - Properties
    
    weak var delegate: EventDatesViewControllerDelegate?
    
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
    
    // MARK: - Actions
    
    @IBAction func tableViewClick(sender: AnyObject? = nil) {
                
        guard tableView.selectedRow >= 0
            else { return }
        
        let selectedDate = summitCache!.start.mt_dateDaysAfter(tableView.selectedRow)
        
        delegate?.eventDatesViewController(self, didSelect: selectedDate)
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
        
        self.tableView.reloadData()
        
        // select first row
        NSOperationQueue.mainQueue().addOperationWithBlock {
            
            if self.tableView.numberOfRows > 0 {
                
                self.tableView.selectRowIndexes(NSIndexSet(index: 0), byExtendingSelection: false)
                
                self.tableViewClick()
            }
        }
    }
    
    // MARK: - NSTableViewDataSource
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        
        guard let summit = summitCache
            else { return 0 }
        
        return summit.end.mt_daysSinceDate(summit.start)
    }
    
    // MARK: - NSTableViewDelegate
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cell = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: nil) as! NSTableCellView
        
        let date = summitCache!.start.mt_dateDaysAfter(row)
        
        cell.textField?.stringValue = dateFormatter.stringFromDate(date)
        
        return cell
    }
}

// MARK: - Supporting Types

@objc protocol EventDatesViewControllerDelegate: class {
    
    func eventDatesViewController(controller: EventDatesViewController, didSelect date: NSDate)
}
