//
//  RoomsInterfaceController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import WatchKit
import Foundation
import CoreSummit

final class RoomsInterfaceController: WKInterfaceController {
    
    static let identifier = "Rooms"
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var tableView: WKInterfaceTable!
    
    // MARK: - Properties
    
    let rooms = cachedSummit?.locations.reduce([VenueRoom](), combine: {
        
        guard case let .room(room) = $1
            else { return $0 }
        
        var rooms = $0
        rooms.append(room)
        
        return rooms
        
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
        
        let room = rooms[rowIndex]
        
        return Context(room)
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        tableView.setNumberOfRows(rooms.count, withRowType: LabelCellController.identifier)
        
        for (index, location) in rooms.enumerate() {
            
            let cell = tableView.rowControllerAtIndex(index) as! LabelCellController
            
            cell.textLabel.setText(location.name)
        }
    }
}