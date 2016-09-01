//
//  VenuesInterfaceController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import WatchKit
import Foundation
import CoreSummit

final class VenuesInterfaceController: WKInterfaceController {
    
    static let identifier = "Venues"
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var tableView: WKInterfaceTable!
    
    // MARK: - Properties
    
    let venues = cachedSummit?.locations.reduce([Venue](), combine: {
        
        guard case let .venue(venue) = $1
            else { return $0 }
        
        var venues = $0
        venues.append(venue)
        
        return venues
        
    }) ?? []
    
    // MARK: - Loading
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        updateUI()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK: - Segue
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        
        let venue = venues[rowIndex]
        
        return Context(venue)
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        tableView.setNumberOfRows(venues.count, withRowType: LabelCellController.identifier)
        
        for (index, location) in venues.enumerate() {
            
            let cell = tableView.rowControllerAtIndex(index) as! LabelCellController
            
            cell.textLabel.setText(location.name)
        }
    }
}
