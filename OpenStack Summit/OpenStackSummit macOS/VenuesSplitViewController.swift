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
    
    override func updateUserActivityState(userActivity: NSUserActivity) {
        
        let userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.venues.rawValue]
        
        userActivity.addUserInfoEntriesFromDictionary(userInfo as [NSObject : AnyObject])
        
        super.updateUserActivityState(userActivity)
    }
    
    // MARK: - Private Functions
    
    private func configureView() {
        
        let searchPredicate: NSPredicate
        
        if searchTerm.isEmpty {
            
            searchPredicate = NSPredicate(value: true)
            
        } else {
            
            searchPredicate = NSPredicate(format: "name CONTAINS[c] %@ OR address CONTAINS[c] %@ OR city CONTAINS[c] %@ OR state CONTAINS[c] %@ OR country CONTAINS[c] %@ OR zipCode CONTAINS[c] %@", searchTerm, searchTerm, searchTerm, searchTerm, searchTerm, searchTerm)
        }
        
        let mapVenuesPredicate = NSPredicate(format: "latitude != nil AND longitude != nil")
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [mapVenuesPredicate, searchPredicate])
        
        venueDirectoryViewController.predicate = predicate
        
        // set user activity
        if let summitManagedObject = self.currentSummit {
            
            let summit = Summit(managedObject: summitManagedObject)
            
            // set user activity for handoff
            let userActivity = NSUserActivity(activityType: AppActivity.screen.rawValue)
            userActivity.title = "Venues"
            userActivity.webpageURL = NSURL(string: summit.webpageURL + "/travel")
            userActivity.userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.venues.rawValue]
            userActivity.requiredUserInfoKeys = [AppActivityUserInfo.screen.rawValue]
            userActivity.becomeCurrent()
            
            self.userActivity = userActivity
        }
    }
    
    // MARK: - VenueDirectoryViewControllerDelegate
    
    func venueDirectoryViewController(controller: VenueDirectoryViewController, didSelect venue: Identifier) {
        
        venueMapViewController.showSelectedVenue(venue)
    }
}
