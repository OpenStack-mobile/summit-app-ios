//
//  EventDatesViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/4/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import SwiftFoundation
import CoreSummit

@objc(OSSTVEventDatesViewController)
final class EventDatesViewController: UITableViewController {
    
    // MARK: - Properties
        
    private(set) var state: State = .loading {
        
        didSet { updateUI() }
    }
    
    private static let dateFormatter: NSDateFormatter = {
       
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "MMMM d"
        
        return dateFormatter
    }()
    
    private static let performSegueDelay: NSTimeInterval = 0.1
    
    private var lastSelectedIndexPath: NSIndexPath?
    
    private let delayedSeguesOperationQueue = NSOperationQueue()
    
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
    
    @IBAction func loadData(sender: AnyObject? = nil) {
        
        state = .loading
        
        let summitID = SummitManager.shared.summit.value
        
        assert(summitID != 0, "No summit selected")
        
        if let summit = try! Summit.find(summitID, context: Store.shared.managedObjectContext) {
            
            self.state = State(summit: summit)
            
        } else {
            
            Store.shared.summit(summitID) { [weak self] (response) in
                
                guard let controller = self else { return }
                
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    
                    switch response {
                        
                    case let .Error(error):
                        
                        controller.state = .error(error)
                        
                    case let .Value(summit):
                        
                        controller.state = State(summit: summit)
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        tableView.reloadData()
        
        switch state {
            
        case .loading:
            
            self.title = "Loading Summit..."
            
        case let .error(error):
            
            self.title = "Error"
            
            // show alert
            showErrorAlert((error as NSError).localizedDescription, okHandler: { self.loadData() })
            
        case let .summit(_, _, name):
            
            self.title = name
            
            self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: true, scrollPosition: .None)
            self.performSegueWithIdentifier("showDayEvents", sender: self)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard case let .summit(start, end, _) = state
            else { return 0 }
        
        return end.toFoundation().mt_daysSinceDate(start.toFoundation())
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("EventDayTableViewCell")!
        
        guard case let .summit(start, _, _) = state
            else { fatalError("Invalid state") }
        
        let date = start.toFoundation().mt_dateDaysAfter(indexPath.row)
        
        cell.textLabel?.text = EventDatesViewController.dateFormatter.stringFromDate(date)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        // Check that the next focus view is a child of the table view.
        guard let nextFocusedView = context.nextFocusedView where nextFocusedView.isDescendantOfView(tableView) else { return }
        guard let indexPath = context.nextFocusedIndexPath else { return }
        
        // Cancel any previously queued segues.
        delayedSeguesOperationQueue.cancelAllOperations()
        
        // Create an `NSBlockOperation` to perform the detail segue after a delay.
        let performSegueOperation = NSBlockOperation()
        
        performSegueOperation.addExecutionBlock { [weak self, unowned performSegueOperation] in
            
            guard let controller = self else { return }
            
            // Pause the block so the segue isn't immediately performed.
            NSThread.sleepForTimeInterval(0.1)
            
            /*
             Check that the operation wasn't cancelled and that the segue identifier
             is different to the last performed segue identifier.
             */
            guard performSegueOperation.cancelled == false
                && indexPath != controller.lastSelectedIndexPath
                else { return }
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                
                // Record the last performed segue identifier.
                controller.lastSelectedIndexPath = indexPath
                
                /*
                 Select the focused cell so that the table view visibly reflects
                 which detail view is being shown.
                 */
                controller.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
                controller.performSegueWithIdentifier("showDayEvents", sender: self)
            }
        }
        
        delayedSeguesOperationQueue.addOperation(performSegueOperation)
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            
        case "showDayEvents":
            
            guard case let .summit(start, _, _) = state
                else { fatalError("Invalid state") }
            
            let indexPath = tableView.indexPathForSelectedRow!
            
            let selectedDate = start.toFoundation().mt_dateDaysAfter(indexPath.row)
            
            let endDate = selectedDate.mt_endOfCurrentDay()
            
            let predicate = NSPredicate(format: "start >= %@ AND end <= %@", selectedDate, endDate)
            
            let destinationViewController = segue.destinationViewController as! UINavigationController
            
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
        case error(ErrorType)
        case summit(Date, Date, String)
        
        init(summit: Summit) {
            
            self = .summit(summit.start, summit.end, summit.name)
        }
    }
}
