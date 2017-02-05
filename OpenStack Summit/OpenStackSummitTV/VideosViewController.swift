//
//  VideosViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/4/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreSummit

@objc(OSSTVVideosViewController)
final class VideosViewController: UINavigationController {
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Videos", bundle: nil)
        let searchResultsController = storyboard.instantiateViewControllerWithIdentifier("VideoSearchResults") as! VideoSearchResultsViewController
        
        /*
         Create a UISearchController, passing the `searchResultsController` to
         use to display search results.
         */
        let searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = searchResultsController
        searchController.searchBar.placeholder = "Search Videos"
        
        // Contain the `UISearchController` in a `UISearchContainerViewController`.
        let searchContainer = UISearchContainerViewController(searchController: searchController)
        searchContainer.title = "Videos"
        
        // Finally contain the `UISearchContainerViewController` in a `UINavigationController`.
        self.setViewControllers([searchContainer], animated: false)
    }
}
