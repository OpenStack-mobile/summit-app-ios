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

final class VenuesSplitViewController: NSSplitViewController, VenueDirectoryViewControllerDelegate {
    
    // MARK: - Properties
    
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
    }
    
    // MARK: - VenueDirectoryViewControllerDelegate
    
    func venueDirectoryViewController(controller: VenueDirectoryViewController, didSelect venue: Identifier) {
        
        venueMapViewController.showSelectedVenue(venue)
    }
}
