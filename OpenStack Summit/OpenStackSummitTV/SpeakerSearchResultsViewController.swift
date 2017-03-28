//
//  SpeakerSearchResultsViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/11/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreSummit
import Haneke
import CoreData

final class SpeakerSearchResultsViewController: TableViewController, UISearchResultsUpdating {
    
    // MARK: - Properties
        
    var filterString = "" {
        
        didSet {
            
            // Return if the filter string hasn't changed.
            guard filterString != oldValue && isViewLoaded() else { return }
            
            filterChanged()
        }
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        tableView.layoutMargins.left = 90
        tableView.layoutMargins.right = 90
        
        filterChanged()
    }
    
    // MARK: - Private Methods
    
    private func filterChanged() {
        
        var predicates = [NSPredicate]()
        
        let summitID = NSNumber(longLong: Int64(SummitManager.shared.summit.value))
        
        let summitPredicate = NSPredicate(format: "%@ IN summits.id", summitID)
        
        predicates.append(summitPredicate)
        
        if filterString.isEmpty == false {
            
            let filterPredicate = NSPredicate(format: "firstName CONTAINS [c] %@ or lastName CONTAINS [c] %@", filterString, filterString)
            
            predicates.append(filterPredicate)
        }
        
        let predicate: NSPredicate?
        
        if predicates.count > 0 {
            
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            
        } else {
            
            predicate = predicates.first
        }
        
        self.fetchedResultsController = NSFetchedResultsController(Speaker.self,
                                                                   delegate: self,
                                                                   predicate: predicate,
                                                                   sortDescriptors: SpeakerManagedObject.sortDescriptors,
                                                                   sectionNameKeyPath: nil,
                                                                   context: Store.shared.managedObjectContext)
        
        self.fetchedResultsController.fetchRequest.fetchBatchSize = 20
        
        try! self.fetchedResultsController.performFetch()
        
        self.tableView.reloadData()
    }
    
    @inline(__always)
    private func configure(cell cell: SpeakerTableViewCell, at indexPath: NSIndexPath) {
        
        let speaker = self[indexPath]
        
        cell.nameLabel.text = speaker.name
        cell.titleLabel.text = speaker.title ?? ""
        cell.speakerImageView.hnk_setImageFromURL(NSURL(string: speaker.pictureURL)!, placeholder: UIImage(named: "generic-user-avatar"))
        cell.speakerImageView.layer.cornerRadius = cell.speakerImageView.frame.size.width / 2
        cell.speakerImageView.clipsToBounds = true
    }
    
    private subscript (indexPath: NSIndexPath) -> Speaker {
        
        let managedObject = self.fetchedResultsController.objectAtIndexPath(indexPath) as! SpeakerManagedObject
        
        return Speaker(managedObject: managedObject)
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        // update filter string
        filterString = searchController.searchBar.text ?? ""
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(SpeakerTableViewCell.identifier, forIndexPath: indexPath) as! SpeakerTableViewCell
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            
        case "showSpeakerDetail":
            
            let speaker = self[tableView.indexPathForSelectedRow!]
            
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let speakerDetailViewController = navigationController.topViewController as! SpeakerDetailViewController
            
            speakerDetailViewController.speaker = speaker.identifier
            
        default: fatalError("Unknown segue: \(segue)")
            
        }
    }
}

// MARK: - Supporting Types

final class SpeakerTableViewCell: UITableViewCell {
    
    static let identifier = "SpeakerTableViewCell"
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var speakerImageView: UIImageView!
}
