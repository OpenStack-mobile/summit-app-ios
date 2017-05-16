//
//  SpeakersViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/11/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreSummit

@objc(OSSTVSpeakersViewController)
final class SpeakersViewController: UINavigationController {
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Speakers", bundle: nil)
        let searchResultsController = storyboard.instantiateViewController(withIdentifier: "SpeakerSearchResults") as! SpeakerSearchResultsViewController
        
        /*
         Create a UISearchController, passing the `searchResultsController` to
         use to display search results.
         */
        let searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = searchResultsController
        searchController.searchBar.placeholder = "Search speakers by name"
        
        // Contain the `UISearchController` in a `UISearchContainerViewController`.
        let searchContainer = UISearchContainerViewController(searchController: searchController)
        searchContainer.title = "Speakers"
        
        // Finally contain the `UISearchContainerViewController` in a `UINavigationController`.
        self.setViewControllers([searchContainer], animated: false)
    }
}
