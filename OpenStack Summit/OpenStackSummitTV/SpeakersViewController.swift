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
import RealmSwift
import Haneke

// MARK: - Navigation Controller

final class SpeakersViewController: UINavigationController {
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Speakers", bundle: nil)
        let searchResultsController = storyboard.instantiateViewControllerWithIdentifier("SpeakerSearchResults") as! SpeakerSearchResultsViewController
        
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

// MARK: - Search Results Controller

final class SpeakerSearchResultsViewController: UITableViewController, UISearchResultsUpdating {
    
    // MARK: - Properties
    
    var filterString = "" {
        
        didSet {
            
            // Return if the filter string hasn't changed.
            guard filterString != oldValue && isViewLoaded() else { return }
            
            updateUI()
        }
    }
    
    private(set) var filteredSpeakers = [PresentationSpeaker]()
    
    private var notificationToken: NotificationToken!
    
    // MARK: - Loading
    
    deinit {
        
        notificationToken?.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        tableView.layoutMargins.left = 90
        tableView.layoutMargins.right = 90
        
        updateUI()
        
        notificationToken = Store.shared.realm.addNotificationBlock { _ in self.updateUI() }
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        // fetch all speakers
        let allSpeakers = Store.shared.realm.objects(RealmPresentationSpeaker).sorted(PresentationSpeaker.sortProperties).filter("firstName != '' || lastName != ''")
        
        let realmFilteredSpeakers = filterString.isEmpty ? allSpeakers : allSpeakers.filter("firstName CONTAINS [c] %@ or lastName CONTAINS [c] %@", filterString, filterString)
        
        filteredSpeakers = PresentationSpeaker.from(realm: realmFilteredSpeakers)
        
        // Reload the table view to reflect the changes.
        tableView?.reloadData()
    }
    
    @inline(__always)
    private func configure(cell cell: SpeakerTableViewCell, at indexPath: NSIndexPath) {
        
        let speaker = filteredSpeakers[indexPath.row]
        
        cell.nameLabel.text = speaker.name
        cell.titleLabel.text = speaker.title ?? ""
        cell.speakerImageView.hnk_setImageFromURL(NSURL(string: speaker.pictureURL)!, placeholder: UIImage(named: "generic-user-avatar"))
        cell.speakerImageView.layer.cornerRadius = cell.speakerImageView.frame.size.width / 2
        cell.speakerImageView.clipsToBounds = true
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        // update filter string
        filterString = searchController.searchBar.text ?? ""
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredSpeakers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(SpeakerTableViewCell.identifier, forIndexPath: indexPath) as! SpeakerTableViewCell
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
}

// MARK: - Supporting Types

final class SpeakerTableViewCell: UITableViewCell {
    
    static let identifier = "SpeakerTableViewCell"
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var speakerImageView: UIImageView!
}
