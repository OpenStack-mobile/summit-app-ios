//
//  SummitViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/19/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit
import CoreData
import CoreSummit

final class SummitViewController: NSViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var contentView: NSView!
    
    @IBOutlet weak var emptyView: NSView!
    
    @IBOutlet weak var nameLabel: NSTextField!
    
    @IBOutlet weak var dateLabel: NSTextField!
    
    @IBOutlet weak var wirelessNetworkButton: NSButton!
    
    // MARK: - Properties
    
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
        
        self.contentView.hidden = self.currentSummit == nil
        self.emptyView.hidden = self.currentSummit != nil
        
        if let summit = self.currentSummit {
            
            nameLabel.stringValue = summit.name
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeZone = NSTimeZone(name: summit.timeZone)
            dateFormatter.dateFormat = "MMMM dd-"
            let stringDateFrom = dateFormatter.stringFromDate(summit.start)
            
            dateFormatter.dateFormat = "dd, yyyy"
            let stringDateTo = dateFormatter.stringFromDate(summit.end)
            
            dateLabel.stringValue = stringDateFrom + stringDateTo
            
            let today = NSDate()
            
            let summitActive = today.mt_isBetweenDate(summit.start, andDate: summit.end)
            
            #if !DEBUG // never hide for debug builds
            wirelessNetworkButton.hidden = summitActive == false
            #endif
        }
    }
}
