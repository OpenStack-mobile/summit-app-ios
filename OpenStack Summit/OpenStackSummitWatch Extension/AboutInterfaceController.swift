//
//  AboutInterfaceController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import WatchKit
import SwiftFoundation
import CoreSummit

final class AboutInterfaceController: WKInterfaceController {
    
    static let identifier = "About"
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var summitNameLabel: WKInterfaceLabel!
    
    @IBOutlet weak var versionLabel: WKInterfaceLabel!
    
    // MARK: - Loading
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        updateUI()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        let webpageURL: Foundation.URL
        
        if let summit = Store.shared.cache {
            
             webpageURL = Foundation.URL(string: summit.webpageURL)!
            
        } else {
            
            webpageURL = Foundation.URL(string: AppEnvironment.configuration.webpageURL)!
        }
        
        updateUserActivity(AppActivity.screen.rawValue, userInfo: [AppActivityUserInfo.screen.rawValue: AppActivityScreen.about.rawValue], webpageURL: webpageURL)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        invalidateUserActivity()
    }
    
    // MARK: - Actions
    
    @IBAction func refreshData(_ sender: AnyObject? = nil) {
        
        try! Store.shared.clear()
        
        Store.shared.cache = nil
        
        self.popToRootController()
    }
    
    // MARK: - Private Methods
    
    fileprivate func updateUI() {
        
        // set summit info
        
        if let summit = Store.shared.cache {
            
            summitNameLabel.setHidden(false)
            summitNameLabel.setText(summit.name)
            
        } else {
            
            summitNameLabel.setHidden(true)
        }
        
        // set version
        
        let version = "v\(AppVersion) \(AppBuild)"
        
        versionLabel.setText(version)
    }
}
