//
//  EventDetailInterfaceController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import WatchKit
import Foundation
import CoreSummit

final class EventDetailInterfaceController: WKInterfaceController {
    
    static let identifier = "EventDetail"
    
    // MARK: - IB Outlets
    
    // MARK: - Properties
    
    private var event: Event!
    
    // MARK: - Loading
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        guard let event = (context as? Context<SummitEvent>)?.value
            else { fatalError("Invalid context") }
        
        self.event = event
        
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
    
    // MARK: - Actions
    
    @IBAction func play(sender: AnyObject? = nil) {
        /*
        self.presentMediaPlayerControllerWithURL(<#T##URL: NSURL##NSURL#>, options: <#T##[NSObject : AnyObject]?#>) { (<#Bool#>, <#NSTimeInterval#>, <#NSError?#>) in
            <#code#>
        }*/
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        
    }
}