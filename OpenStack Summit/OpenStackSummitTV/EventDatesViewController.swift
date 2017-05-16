//
//  EventDatesViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/4/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import Foundation
import CoreSummit
import Predicate

@objc(OSSTVEventDatesViewController)
final class EventDatesViewController: UITableViewController {
    
    // MARK: - Properties
        
    private(set) var state: State = .loading {
        
        didSet { updateUI() }
    }
    
    private static let dateFormatter: DateFormatter = {
       
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MMMM d"
        
        return dateFormatter
    }()
    
    private static let performSegueDelay: TimeInterval = 0.1
    
    private var lastSelectedIndexPath: IndexPath?
    
    private let delayedSeguesOperationQueue = OperationQueue()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /*
         Set `remembersLastFocusedIndexPath` to `true` to ensure the same row
         becomes focused whenever focus is returned to the table view.
         */
        tableView.remembersLastFocusedIndexPath = true
        
        /*
         Adjust the layout margins of the `tableView` to add a horizontal inset
         to the cells. This will allow for overscan on older TVs and space for
         the focus effect.
         */
        tableView.layoutMargins.left = 90
        tableView.layoutMargins.right = 20
        
        loadData()
    }
    
    // MARK: - Actions
    
    @IBAction func loadData(_ sender: AnyObject? = nil) {
        
        state = .loading
        
        let summitID = SummitManager.shared.summit.value
        
        assert(summitID != 0, "No summit selected")
        
        if let summit = try! Summit.find(summitID, context: Store.shared.managedObjectContext) {
            
            self.state = State(summit: summit)
            
        } else {
            
            Store.shared.summit(summitID) { [weak self] (response) in
                
                guard let controller = self else { return }
                
                OperationQueue.main.addOperation {
                    
                    switch response {
                        
                    case let .error(error):
                        
                        controller.state = .error(error)
                        
                    case let .value(summit):
                        
                        controller.state = State(summit: summit)
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        switch state {
            
        case .loading:
            
            self.title = "Loading Summit..."
            
        case let .error(error):
            
            self.title = "Error"
            
            // show alert
            showErrorAlert((error as NSError).localizedDescription, okHandler: { self.loadData() })
            
        case let .summit(_, _, name, timeZone):
            
            self.title = name
            
            NSDate.mt_setTimeZone(timeZone)
            
            self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
            self.performSegue(withIdentifier: "showDayEvents", sender: self)
        }
        
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard case let .summit(start, end, _, _) = state
            else { return 0 }
        
        return (end as NSDate).mt_days(since: start)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventDayTableViewCell")!
        
        guard case let .summit(start, _, _, _) = state
            else { fatalError("Invalid state") }
        
        let date = (start as NSDate).mt_dateDays(after: indexPath.row)!
        
        cell.textLabel?.text = EventDatesViewController.dateFormatter.string(from: date)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        // Check that the next focus view is a child of the table view.
        guard let nextFocusedView = context.nextFocusedView, nextFocusedView.isDescendant(of: tableView) else { return }
        guard let indexPath = context.nextFocusedIndexPath else { return }
        
        // Cancel any previously queued segues.
        delayedSeguesOperationQueue.cancelAllOperations()
        
        // Create an `NSBlockOperation` to perform the detail segue after a delay.
        let performSegueOperation = BlockOperation()
        
        performSegueOperation.addExecutionBlock { [weak self, unowned performSegueOperation] in
            
            guard let controller = self else { return }
            
            // Pause the block so the segue isn't immediately performed.
            Thread.sleep(forTimeInterval: 0.1)
            
            /*
             Check that the operation wasn't cancelled and that the segue identifier
             is different to the last performed segue identifier.
             */
            guard performSegueOperation.isCancelled == false
                && indexPath != controller.lastSelectedIndexPath
                else { return }
            
            OperationQueue.main.addOperation {
                
                // Record the last performed segue identifier.
                controller.lastSelectedIndexPath = indexPath
                
                /*
                 Select the focused cell so that the table view visibly reflects
                 which detail view is being shown.
                 */
                controller.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                controller.performSegue(withIdentifier: "showDayEvents", sender: self)
            }
        }
        
        delayedSeguesOperationQueue.addOperation(performSegueOperation)
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
            
        case "showDayEvents":
            
            guard case let .summit(start, _, _, _) = state
                else { fatalError("Invalid state") }
            
            let indexPath = tableView.indexPathForSelectedRow!
            
            let selectedDate = (start as NSDate).mt_dateDays(after: indexPath.row)!
            
            let endDate = (selectedDate as NSDate).mt_endOfCurrentDay()!
            
            //let predicate = NSPredicate(format: "start >= %@ AND end <= %@", selectedDate, endDate)
            let predicate: Predicate = #keyPath(EventManagedObject.start) >= selectedDate
                && #keyPath(EventManagedObject.end) <= endDate
            
            let destinationViewController = segue.destination as! UINavigationController
            
            let eventsViewController = destinationViewController.topViewController as! EventsViewController
            
            eventsViewController.predicate = predicate
            
            // adjust margins for VC
            eventsViewController.tableView.layoutMargins.left = 20
            eventsViewController.tableView.layoutMargins.right = 90
            
        default: fatalError("Unknown segue: \(segue)")
        }
    }
}

// MARK: - Supporting Types

extension EventDatesViewController {
    
    enum State {
        
        case loading
        case error(Error)
        case summit(start: Date, end: Date, name: String, timeZone: Foundation.TimeZone)
        
        init(summit: Summit) {
            
            let start = (summit.start as NSDate).mt_startOfCurrentDay()!
            
            let end = (summit.end as NSDate).mt_dateDays(after: 1)!
            
            let timeZone = TimeZone(identifier: summit.timeZone)!
            
            self = .summit(start: start, end: end, name: summit.name, timeZone: timeZone)
        }
    }
}
