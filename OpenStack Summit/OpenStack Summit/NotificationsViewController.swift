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
    
    private lazy var dateFormatter: DateFormatter = {
       
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .short
        
        dateFormatter.timeStyle = .medium
        
        return dateFormatter
    }()
    
    private var unreadNotificationsObserver: Int?
    
    // MARK: - Loading
    
    deinit {
        
        if let observer = self.unreadNotificationsObserver {
            
            PushNotificationManager.shared.unreadNotifications.remove(observer)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.unreadNotificationsObserver = PushNotificationManager.shared.unreadNotifications.observe(unreadNotificationsChanged)
        
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        self.navigationController?.setToolbarHidden(!self.isEditing, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    // MARK: - Actions
    
    @IBAction func toggleEdit(_ sender: UIBarButtonItem) {
        
        let willEdit = !self.isEditing
        
        self.setEditing(willEdit, animated: true)
        
        self.navigationController?.setToolbarHidden(!willEdit, animated: true)
    }
    
    @IBAction func deleteItems(_ sender: UIBarButtonItem) {
        
        let selectedIndexPaths = self.tableView.indexPathsForSelectedRows ?? []
        
        let selectedItems = selectedIndexPaths.map { self.fetchedResultsController.object(at: $0) as! NotificationManagedObject }
        
        let context = Store.shared.privateQueueManagedObjectContext
        
        context.perform {
            
            let managedObjects = selectedItems.map { context.object(with: $0.objectID) }
            
            managedObjects.forEach { context.delete($0) }
            
            try! context.save()
        }
    }
    
    @IBAction func markAll(_ sender: UIBarButtonItem) {
        
        let indexPaths = (self.fetchedResultsController.fetchedObjects ?? []).map { self.fetchedResultsController.indexPath(forObject: $0) }
        
        indexPaths.forEach { self.tableView.selectRow(at: $0, animated: true, scrollPosition: .none) }
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        let sort = [NSSortDescriptor(key: "channel", ascending: true), NSSortDescriptor(key: "id", ascending: false)]
        
        self.fetchedResultsController = NSFetchedResultsController(CoreSummit.Notification.self,
                                                                   delegate: self,
                                                                   predicate: nil,
                                                                   sortDescriptors: sort,
                                                                   sectionNameKeyPath: "channel",
                                                                   context: Store.shared.managedObjectContext) as! NSFetchedResultsController<NSManagedObject>
        
        try! self.fetchedResultsController.performFetch()
        
        self.tableView.reloadData()
    }
    
    private subscript (indexPath: IndexPath) -> CoreSummit.Notification {
        
        let managedObject = self.fetchedResultsController.object(at: indexPath) as! CoreSummit.Notification.ManagedObject
        
        return Notification(managedObject: managedObject)
    }
    
    private func configure(cell: NotificationTableViewCell, at indexPath: IndexPath) {
        
        let notification = self[indexPath]
        
        cell.notificationLabel.text = notification.body
        
        let unread = PushNotificationManager.shared.unreadNotifications.value.contains(notification.identifier)
        
        cell.notificationLabel.font = unread ? UIFont.boldSystemFont(ofSize: 17) : UIFont.systemFont(ofSize: 17)
        
        cell.dateLabel.text = self.dateFormatter.string(from: notification.created)
    }
    
    private func unreadNotificationsChanged(_ newValue: Set<Identifier>, _ oldValue: Set<Identifier>) {
        
        let managedObjects = (self.fetchedResultsController.fetchedObjects ?? []) as! [NotificationManagedObject]
        
        let changedNotifications = managedObjects.filter { newValue.contains($0.id) } 
        
        let indexPaths = changedNotifications.map { fetchedResultsController.indexPath(forObject: $0)! }
        
        tableView.beginUpdates()
        
        tableView.reloadRows(at: indexPaths, with: .none)
        
        tableView.endUpdates()
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.notificationCell)!
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
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
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        return UITableViewCellEditingStyle(rawValue: 3)!
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Notifications")
    }
    
    // MARK: - Segue
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        switch identifier {
            
        case R.segue.notificationsViewController.showNotification.identifier:
            
            return isEditing == false
            
        default: fatalError()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
            
        case R.segue.notificationsViewController.showNotification.identifier:
            
            let notification = self[tableView.indexPathForSelectedRow!]
            
            let notificationViewController = segue.destination as! NotificationDetailViewController
            
            notificationViewController.notification = notification
            
        default: fatalError()
        }
    }
}

// MARK: - Supporting Types

final class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet private(set) weak var notificationLabel: UILabel!
    
    @IBOutlet private(set) weak var dateLabel: UILabel!
}
