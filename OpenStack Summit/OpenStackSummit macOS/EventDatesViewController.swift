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
    
    private var summitCache: (start: Date, end: Date, timeZone: Foundation.TimeZone, name: String)?
    
    private lazy var dateFormatter: DateFormatter = {
        
        let dateFormatter = DateFormatter()
        
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
    
    @IBAction func tableViewClick(_ sender: AnyObject? = nil) {
                
        guard tableView.selectedRow >= 0
            else { return }
        
        let selectedDate = (summitCache!.start as NSDate).mt_dateDays(after: tableView.selectedRow)!
        
        delegate?.eventDatesViewController(self, didSelect: selectedDate)
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        if let summit = self.currentSummit {
            
            let start = (summit.start as NSDate).mt_startOfCurrentDay()!
            
            let end = (summit.end as NSDate).mt_dateDays(after: 1)!
            
            let timeZone = TimeZone(identifier: summit.timeZone)!
            
            self.summitCache = (start: start, end: end, timeZone: timeZone, name: summit.name)
            
        } else {
            
            self.summitCache = nil
        }
        
        self.tableView.reloadData()
        
        // select first row
        OperationQueue.main.addOperation {
            
            if self.tableView.numberOfRows > 0 {
                
                self.tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
                
                self.tableViewClick()
            }
        }
    }
    
    // MARK: - NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        guard let summit = summitCache
            else { return 0 }
        
        return (summit.end as NSDate).mt_days(since: summit.start)
    }
    
    // MARK: - NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cell = tableView.make(withIdentifier: tableColumn!.identifier, owner: nil) as! NSTableCellView
        
        let date = (summitCache!.start as NSDate).mt_dateDays(after: row)!
        
        cell.textField?.stringValue = dateFormatter.string(from: date)
        
        return cell
    }
}

// MARK: - Supporting Types

@objc protocol EventDatesViewControllerDelegate: class {
    
    func eventDatesViewController(_ controller: EventDatesViewController, didSelect date: Date)
}
