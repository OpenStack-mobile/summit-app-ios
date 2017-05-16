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
    
    private var entityController: EntityController<Summit>?
    
    // MARK: - Loading
    
    deinit {
        
        if let observer = summitObserver {
            
            SummitManager.shared.summit.remove(observer)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        summitObserver = SummitManager.shared.summit.observe { [weak self] _ in self?.setupController() }
        
        setupController()
    }
    
    // MARK: - Private Methods
    
    private func setupController() {
        
        let summitID = SummitManager.shared.summit.value
        
        guard summitID > 0 else { self.entityController = nil; return }
        
        let entityController = EntityController<Summit>(identifier: summitID,
                                                        entity: Summit.ManagedObject.self,
                                                        context: Store.shared.managedObjectContext)
        
        entityController.event.inserted = { [weak self] in self?.configureView($0) }
        
        entityController.event.updated = { [weak self] in self?.configureView($0) }
        
        entityController.event.deleted = { [weak self] _ in self?.configureView(nil) }
        
        entityController.enabled = true
        
        self.entityController = entityController
    }
    
    private func configureView(_ summit: Summit?) {
        
        self.contentView.isHidden = summit == nil
        self.emptyView.isHidden = summit != nil
        
        if let summit = summit {
            
            nameLabel.stringValue = summit.name
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(identifier: summit.timeZone)
            dateFormatter.dateFormat = "MMMM dd-"
            let stringDateFrom = dateFormatter.string(from: summit.start)
            
            dateFormatter.dateFormat = "dd, yyyy"
            let stringDateTo = dateFormatter.string(from: summit.end)
            
            dateLabel.stringValue = stringDateFrom + stringDateTo
            
            let today = Date()
            
            let summitActive = (today as NSDate).mt_isBetweenDate(summit.start, andDate: summit.end)
            
            #if !DEBUG // never hide for debug builds
            wirelessNetworkButton.isHidden = summitActive == false
            #endif
        }
    }
}
