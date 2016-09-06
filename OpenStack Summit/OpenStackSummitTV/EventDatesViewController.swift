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
import RealmSwift
import RealmResultsController

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
    
    private static let dayFormatter: NSDateFormatter = {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "EEEE"
        
        return dateFormatter
    }()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadData()
    }
    
    // MARK: - Actions
    
    @IBAction func loadData(sender: AnyObject? = nil) {
        
        state = .loading
        
        if let realmSummit = Store.shared.realm.objects(RealmSummit).first {
            
            let summit = Summit(realmEntity: realmSummit)
            
            self.state = State(summit: summit)
            
        } else {
            
            Store.shared.summit { [weak self] (response) in
                
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
            showErrorAlert((error as NSError).localizedDescription, retryHandler: { self.loadData() })
            
        case let .summit(_, _, name):
            
            self.title = name
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
            
            let request = RealmRequest<RealmSummitEvent>(predicate: predicate, realm: Store.shared.realm, sortDescriptors: RealmSummitEvent.sortProperties)
            
            let destinationViewController = segue.destinationViewController as! EventsViewController
            
            destinationViewController.state = .events(request)
            
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
            
            let year = DateComponents(fromDate: summit.start).year
            
            let summitName = summit.name + " " + "\(year)"
            
            self = .summit(summit.start, summit.end, summitName)
        }
    }
}
