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
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        updateUI()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        let webpageURL: NSURL
        
        if let summit = Store.shared.cache {
            
             webpageURL = NSURL(string: AppConfiguration[.WebsiteURL] + "/" + summit.webIdentifier)!
            
        } else {
            
            webpageURL = NSURL(string: AppConfiguration[.WebsiteURL])!
        }
        
        updateUserActivity(AppActivity.screen.rawValue, userInfo: [AppActivityUserInfo.screen.rawValue: AppActivityScreen.about.rawValue], webpageURL: webpageURL)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        invalidateUserActivity()
    }
    
    // MARK: - Actions
    
    @IBAction func refreshData(sender: AnyObject? = nil) {
        
        Store.shared.clear()
        
        self.popToRootController()
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        // set summit info
        
        if let summit = Store.shared.cache {
            
            let year = DateComponents(fromDate: summit.start).year
            
            let summitName = summit.name + " " + "\(year)"
            
            summitNameLabel.setHidden(false)
            summitNameLabel.setText(summitName)
            
        } else {
            
            summitNameLabel.setHidden(true)
        }
        
        // set version
        
        let version = "v\(AppVersion) \(AppBuild)"
        
        versionLabel.setText(version)
    }
}
