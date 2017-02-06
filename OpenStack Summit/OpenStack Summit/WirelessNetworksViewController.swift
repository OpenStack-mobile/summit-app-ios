//
//  WirelessNetworksViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/6/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreSummit

final class WirelessNetworksViewController: TableViewController {
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableViewAutomaticDimension
        
        configureView()
    }
    
    // MARK: - Actions
    
    @IBAction func done(sender: AnyObject? = nil) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    @inline(__always)
    private func configureView() {
        
        let summitID = NSNumber(longLong: Int64(SummitManager.shared.summit.value))
        
        let predicate = NSPredicate(format: "summit.id == %@", summitID)
        
        let sort = [NSSortDescriptor(key: "name", ascending: true)]
        
        self.fetchedResultsController = NSFetchedResultsController.init(WirelessNetwork.self,
                                                                        delegate: self,
                                                                        predicate: predicate,
                                                                        sortDescriptors: sort,
                                                                        context: Store.shared.managedObjectContext)
        
        try! self.fetchedResultsController.performFetch()
        
        self.tableView.reloadData()
    }
    
    private subscript (indexPath: NSIndexPath) -> WirelessNetwork {
        
        let managedObject = self.fetchedResultsController.objectAtIndexPath(indexPath) as! WirelessNetwork.ManagedObject
        
        return WirelessNetwork(managedObject: managedObject)
    }
    
    @inline(__always)
    private func configure(cell cell: WirelessNetworkCell, at indexPath: NSIndexPath) {
        
        let network = self[indexPath]
        
        cell.nameLabel.text = network.name
        
        cell.passwordLabel.text = network.password
        
        if let descriptionHTML = network.descriptionText,
            let data = "<style>p:last-of-type { display:compact }</style><span style=\"font-family: Arial; font-size: 13\">\(descriptionHTML)</span>".dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false),
            let attributedText = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) {
            
            cell.descriptionTextView.attributedText = attributedText
            
            cell.descriptionTextView.removeConstraint(cell.descriptionTextViewHeightConstraint)
            
            cell.descriptionTextView.sizeToFit()
            
        } else {
            
            cell.descriptionTextView.text = ""
            
            cell.descriptionTextView.addConstraint(cell.descriptionTextViewHeightConstraint)
        }
        
        cell.descriptionTextView.updateConstraints()
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.wirelessNetworkCell)!
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
}

// MARK: - Supporting Types

final class WirelessNetworkCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: CopyableLabel!
    
    @IBOutlet weak var passwordLabel: CopyableLabel!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet var descriptionTextViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        descriptionTextViewHeightConstraint.constant = 0
        
        descriptionTextViewHeightConstraint.active = false
        
        descriptionTextView.textContainerInset = UIEdgeInsetsZero
        
        descriptionTextView.removeConstraint(descriptionTextViewHeightConstraint)
        
        descriptionTextView.updateConstraints()
    }
}
