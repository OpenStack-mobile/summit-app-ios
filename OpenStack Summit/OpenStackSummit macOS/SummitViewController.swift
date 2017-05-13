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
    
    @IBOutlet private(set) weak var contentView: NSView!
    
    @IBOutlet private(set) weak var emptyView: NSView!
    
    @IBOutlet private(set) weak var nameLabel: NSTextField!
    
    @IBOutlet private(set) weak var dateLabel: NSTextField!
    
    @IBOutlet private(set) weak var wirelessNetworkButton: NSButton!
    
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
        
        self.contentView.isHidden = self.currentSummit == nil
        self.emptyView.isHidden = self.currentSummit != nil
        
        if let summit = self.currentSummit {
            
            nameLabel.stringValue = summit.name
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(identifier: summit.timeZone)
            dateFormatter.dateFormat = "MMMM dd-"
            let stringDateFrom = dateFormatter.string(from: summit.start)
            
            dateFormatter.dateFormat = "dd, yyyy"
            let stringDateTo = dateFormatter.string(from: summit.end)
            
            dateLabel.stringValue = stringDateFrom + stringDateTo
            
            let today = Date()
            
            let summitActive = today.mt_isBetweenDate(summit.start, andDate: summit.end)
            
            #if !DEBUG // never hide for debug builds
            wirelessNetworkButton.hidden = summitActive == false
            #endif
        }
    }
}
