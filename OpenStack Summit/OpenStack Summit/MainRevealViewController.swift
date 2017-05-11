//
//  MainRevealViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 5/8/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import typealias CoreSummit.Identifier

final class MainRevealViewController: SWRevealViewController, SummitActivityHandlingViewController {
    
    // MARK: - Properties
    
    var menuViewController: MenuViewController { return rearViewController as! MenuViewController }
    
    // MARK: - Initialization
    
    init() {
        
        let menuViewController = R.storyboard.menu.menuViewController()!
        
        let frontViewController = UINavigationController(rootViewController: menuViewController.generalScheduleViewController)
        
        super.init(rearViewController: menuViewController, frontViewController: frontViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // MARK: - SummitActivityHandling
    
    func view(data: AppActivitySummitDataType, identifier: Identifier) {
        
        // change to menu item section first
        switch data {
        case .event: menuViewController.showEvents()
        case .speaker: menuViewController.showSpeakers()
        case .venue, .venueRoom: menuViewController.showVenues()
        case .video: break
        }
        
        // show detail view controller
        frontViewController.show(data, identifier: identifier)
    }
    
    func view(screen: AppActivityScreen) {
        
        menuViewController.view(screen)
    }
    
    func search(searchTerm: String) {
        
        menuViewController.search(searchTerm)
    }
}
