//
//  VenuesSplitViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/20/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit
import CoreSummit
import Predicate

final class VenuesSplitViewController: NSSplitViewController, SearchableController, VenueDirectoryViewControllerDelegate {
    
    // MARK: - Properties
    
    var searchTerm = "" {
        
        didSet { configureView() }
    }
    
    var venueDirectoryViewController: VenueDirectoryViewController {
        
        return childViewControllers[0] as! VenueDirectoryViewController
    }
    
    var venueMapViewController: VenueMapViewController {
        
        return childViewControllers[1] as! VenueMapViewController
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        venueDirectoryViewController.delegate = self
        
        configureView()
    }
    
    override func updateUserActivityState(_ userActivity: NSUserActivity) {
        
        let userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.venues.rawValue]
        
        userActivity.addUserInfoEntries(from: userInfo as [AnyHashable: Any])
        
        super.updateUserActivityState(userActivity)
    }
    
    // MARK: - Private Functions
    
    private func configureView() {
        
        let searchPredicate: Predicate
        
        if searchTerm.isEmpty {
            
            searchPredicate = .value(true)
            
        } else {
            
            let value = Expression.value(.string(searchTerm))
            
            //searchPredicate = NSPredicate(format: "name CONTAINS[c] %@ OR address CONTAINS[c] %@ OR city CONTAINS[c] %@ OR state CONTAINS[c] %@ OR country CONTAINS[c] %@ OR zipCode CONTAINS[c] %@", searchTerm, searchTerm, searchTerm, searchTerm, searchTerm, searchTerm)
            
            searchPredicate = (#keyPath(VenueManagedObject.name)).compare(.contains, [.caseInsensitive], value)
                || (#keyPath(VenueManagedObject.address)).compare(.contains, [.caseInsensitive], value)
                || (#keyPath(VenueManagedObject.city)).compare(.contains, [.caseInsensitive], value)
                || (#keyPath(VenueManagedObject.state)).compare(.contains, [.caseInsensitive], value)
                || (#keyPath(VenueManagedObject.country)).compare(.contains, [.caseInsensitive], value)
                || (#keyPath(VenueManagedObject.zipCode)).compare(.contains, [.caseInsensitive], value)
        }
        
        //let mapVenuesPredicate = NSPredicate(format: "latitude != nil AND longitude != nil")
        let mapVenuesPredicate: Predicate = .keyPath(#keyPath(VenueManagedObject.latitude)) != .value(.null)
            && .keyPath(#keyPath(VenueManagedObject.longitude)) != .value(.null)
        
        let predicate: Predicate = .compound(.and([mapVenuesPredicate, searchPredicate]))
        
        venueDirectoryViewController.predicate = predicate
        
        // set user activity
        if let summitManagedObject = self.currentSummit {
            
            let summit = Summit(managedObject: summitManagedObject)
            
            // set user activity for handoff
            let userActivity = NSUserActivity(activityType: AppActivity.screen.rawValue)
            userActivity.title = "Venues"
            userActivity.webpageURL = summit.webpage.appendingPathComponent("travel")
            userActivity.userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.venues.rawValue]
            userActivity.requiredUserInfoKeys = [AppActivityUserInfo.screen.rawValue]
            userActivity.becomeCurrent()
            
            self.userActivity = userActivity
        }
    }
    
    // MARK: - VenueDirectoryViewControllerDelegate
    
    func venueDirectoryViewController(_ controller: VenueDirectoryViewController, didSelect venue: Identifier) {
        
        venueMapViewController.showSelectedVenue(venue)
    }
}
