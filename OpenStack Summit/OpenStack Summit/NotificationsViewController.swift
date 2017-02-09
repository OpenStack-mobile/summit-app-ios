//
//  NotificationsViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/26/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreSummit
import XLPagerTabStrip

final class NotificationsViewController: TableViewController, IndicatorInfoProvider {
    
    // MARK: - Properties
    
    private lazy var dateFormatter: NSDateFormatter = {
       
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = .ShortStyle
        
        dateFormatter.timeStyle = .ShortStyle
        
        return dateFormatter
    }()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
                
        self.navigationController?.setToolbarHidden(!self.editing, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    // MARK: - Actions
    
    @IBAction func toggleEdit(sender: UIBarButtonItem) {
        
        let willEdit = !self.editing
        
        self.setEditing(willEdit, animated: true)
        
        self.navigationController?.setToolbarHidden(!willEdit, animated: true)
    }
    
    @IBAction func deleteItems(sender: UIBarButtonItem) {
        
        let selectedIndexPaths = self.tableView.indexPathsForSelectedRows ?? []
        
        let selectedItems = selectedIndexPaths.map { self.fetchedResultsController.objectAtIndexPath($0) as! NotificationManagedObject }
        
        let context = Store.shared.privateQueueManagedObjectContext
        
        context.performBlock {
            
            let managedObjects = selectedItems.map { context.objectWithID($0.objectID) }
            
            managedObjects.forEach { context.deleteObject($0) }
            
            try! context.save()
        }
    }
    
    @IBAction func markAll(sender: UIBarButtonItem) {
        
        let indexPaths = (self.fetchedResultsController.fetchedObjects ?? []).map { self.fetchedResultsController.indexPathForObject($0) }
        
        indexPaths.forEach { self.tableView.selectRowAtIndexPath($0, animated: true, scrollPosition: .None) }
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        let sort = [NSSortDescriptor(key: "channel", ascending: true), NSSortDescriptor(key: "id", ascending: false)]
        
        self.fetchedResultsController = NSFetchedResultsController(Notification.self,
                                                                   delegate: self,
                                                                   predicate: nil,
                                                                   sortDescriptors: sort,
                                                                   sectionNameKeyPath: "channel",
                                                                   context: Store.shared.managedObjectContext)
        
        try! self.fetchedResultsController.performFetch()
        
        self.tableView.reloadData()
    }
    
    private subscript (indexPath: NSIndexPath) -> Notification {
        
        let managedObject = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Notification.ManagedObject
        
        return Notification(managedObject: managedObject)
    }
    
    private func configure(cell cell: UITableViewCell, at indexPath: NSIndexPath) {
        
        let notification = self[indexPath]
        
        cell.textLabel!.text = notification.body
        
        cell.detailTextLabel!.text = self.dateFormatter.stringFromDate(notification.created.toFoundation())
        
        if let _ = notification.event {
            
            cell.accessoryType = .DisclosureIndicator
            
            cell.selectionStyle = .Default
            
        } else {
            
            cell.accessoryType = .None
            
            cell.selectionStyle = .None
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.notificationCell)!
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let channelString = self.fetchedResultsController.sections?[section].name,
            let channel = Notification.Channel(rawValue: channelString)
        else { return nil }
        
        switch channel {
        case .attendees:    return "Attendees"
        case .everyone:     return "Everyone"
        case .event:        return "Events"
        case .group:        return "Groups"
        case .members:      return "Members"
        case .summit:       return "Summit"
        case .speakers:     return "Speakers"
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        return UITableViewCellEditingStyle(rawValue: 3)!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let notification = self[indexPath]
        
        guard let event = notification.event else { return }
        
        let eventDetailViewController = R.storyboard.event.eventDetailViewController()!
        
        eventDetailViewController.event = event
        
        self.showViewController(eventDetailViewController, sender: self)
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Notifications")
    }
}
