//
//  VenuesDirectoryViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/10/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import SwiftFoundation
import CoreSummit
import RealmSwift

@objc(OSSTVVenuesDirectoryViewController)
final class VenuesDirectoryViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var internalVenues = [Venue]()
    
    private var externalVenues = [Venue]()
    
    private var notificationToken: NotificationToken!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         Set `remembersLastFocusedIndexPath` to `true` to ensure the same row
         becomes focused whenever focus is returned to the table view.
         */
        tableView.remembersLastFocusedIndexPath = true
        
        /*
         Adjust the layout margins of the `tableView` to add a horizontal inset
         to the cells. This will allow for overscan on older TVs and space for
         the focus effect.
         */
        tableView.layoutMargins.left = 90
        tableView.layoutMargins.right = 20
        
        updateUI()
        
        notificationToken = Store.shared.realm.addNotificationBlock { _ in self.updateUI() }
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        let dataLoaded = Store.shared.realm.objects(RealmSummit).isEmpty == false
        
        self.title = dataLoaded ? "Venues" : "Loading..."
        
        self.internalVenues = Venue.from(realm: Store.shared.realm.objects(RealmVenue)).filter { $0.isInternal }
        self.externalVenues = Venue.from(realm: Store.shared.realm.objects(RealmVenue)).filter { $0.isInternal == false }
        
        tableView.reloadData()
    }
    
    private subscript (indexPath: NSIndexPath) -> Venue {
        
        let section = Section(rawValue: indexPath.section)!
        
        switch section {
        case .Internal: return internalVenues[indexPath.row]
        case .External: return externalVenues[indexPath.row]
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        let dataLoaded = Store.shared.realm.objects(RealmSummit).isEmpty == false
        
        return dataLoaded ? Section.count : 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let section = Section(rawValue: section)!
        
        switch section {
        case .Internal: return internalVenues.count
        case .External: return externalVenues.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("VenueTableViewCell", forIndexPath: indexPath)
        
        let venue = self[indexPath]
        
        cell.textLabel!.text = venue.name
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let section = Section(rawValue: section)!
        
        switch section {
        case .Internal: return nil
        case .External: return "External Venues"
        }
    }
    
    // MARK: - Segue
}


// MARK: - Supporting Types

private extension VenuesDirectoryViewController {
    
    enum Section: Int {
        
        static let count = 2
        
        case Internal, External
    }
}
