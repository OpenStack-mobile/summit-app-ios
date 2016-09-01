//
//  FetchDataInterfaceController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import WatchKit
import Foundation
import CoreSummit

final class FetchDataInterfaceController: WKInterfaceController {
    
    // MARK: - Properties
    
    @IBOutlet weak var loadingButton: WKInterfaceButton!
    
    // MARK: - Loading
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        loadData()
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
    
    @IBAction func loadData(sender: AnyObject? = nil) {
        
        print("Loading Summit data")
        
        loadingButton.setTitle("Loading...")
        loadingButton.setEnabled(false)
        
        Store.shared.summit { [weak self] (response) in
            
            guard let controller = self else { return }
            
            controller.loadingButton.setEnabled(true)
            
            switch response {
                
            case let .Error(error):
                
                print(error)
                
                controller.loadingButton.setTitle("Try again?")
                
                controller.presentAlertControllerWithTitle("Error", message: (error as NSError).localizedDescription, preferredStyle: WKAlertControllerStyle.Alert, actions: [WKAlertAction(title: "OK", style: WKAlertActionStyle.Cancel, handler: {  })])
                
            case let .Value(summit):
                
                print("Fetched \(summit.name) summit")
                
                // cache summit in memory
                cachedSummit = summit
                
                controller.presentControllerWithName("Events", context: nil)
            }
        }
    }
}