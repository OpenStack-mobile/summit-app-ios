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
import Predicate

final class SpeakerSearchResultsViewController: TableViewController, UISearchResultsUpdating {
    
    // MARK: - Properties
        
    var filterString = "" {
        
        didSet {
            
            // Return if the filter string hasn't changed.
            guard filterString != oldValue && isViewLoaded else { return }
            
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
        
        let summitID = SummitManager.shared.summit.value
        
        //let summitPredicate = NSPredicate(format: "%@ IN summits.id", summitID)
        var predicate: Predicate = (#keyPath(SpeakerManagedObject.summits.id)).in([summitID])
        
        if filterString.isEmpty == false {
            
            let value: Expression = .value(.string(filterString))
            
            //let filterPredicate = NSPredicate(format: "firstName CONTAINS [c] %@ or lastName CONTAINS [c] %@", filterString, filterString)
            let filterPredicate: Predicate = (#keyPath(SpeakerManagedObject.firstName)).compare(.contains, [.caseInsensitive], value)
                || (#keyPath(SpeakerManagedObject.lastName)).compare(.contains, [.caseInsensitive], value)
            
            predicate = predicate && filterPredicate
        }
                
        self.fetchedResultsController = NSFetchedResultsController(Speaker.self,
                                                                   delegate: self,
                                                                   predicate: predicate,
                                                                   sortDescriptors: SpeakerManagedObject.sortDescriptors,
                                                                   sectionNameKeyPath: nil,
                                                                   context: Store.shared.managedObjectContext) as! NSFetchedResultsController<NSManagedObject>
        
        self.fetchedResultsController.fetchRequest.fetchBatchSize = 20
        
        try! self.fetchedResultsController.performFetch()
        
        self.tableView.reloadData()
    }
    
    @inline(__always)
    private func configure(cell: SpeakerTableViewCell, at indexPath: IndexPath) {
        
        let speaker = self[indexPath]
        
        cell.nameLabel.text = speaker.name
        cell.titleLabel.text = speaker.title ?? ""
        cell.speakerImageView.hnk_setImageFromURL(speaker.picture.environmentScheme, placeholder: #imageLiteral(resourceName: "generic-user-avatar"))
        cell.speakerImageView.layer.cornerRadius = cell.speakerImageView.frame.size.width / 2
        cell.speakerImageView.clipsToBounds = true
    }
    
    private subscript (indexPath: IndexPath) -> Speaker {
        
        let managedObject = self.fetchedResultsController.object(at: indexPath) as! SpeakerManagedObject
        
        return Speaker(managedObject: managedObject)
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        
        // update filter string
        filterString = searchController.searchBar.text ?? ""
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SpeakerTableViewCell.identifier, for: indexPath) as! SpeakerTableViewCell
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
            
        case "showSpeakerDetail":
            
            let speaker = self[tableView.indexPathForSelectedRow!]
            
            let navigationController = segue.destination as! UINavigationController
            
            let speakerDetailViewController = navigationController.topViewController as! SpeakerDetailViewController
            
            speakerDetailViewController.speaker = speaker.identifier
            
        default: fatalError("Unknown segue: \(segue)")
            
        }
    }
}

// MARK: - Supporting Types

final class SpeakerTableViewCell: UITableViewCell {
    
    static let identifier = "SpeakerTableViewCell"
    
    @IBOutlet private(set) weak var nameLabel: UILabel!
    
    @IBOutlet private(set) weak var titleLabel: UILabel!
    
    @IBOutlet private(set) weak var speakerImageView: UIImageView!
}
