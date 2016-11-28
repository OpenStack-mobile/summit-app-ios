//
//  AboutViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 4/6/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import CoreSummit

final class AboutViewController: UIViewController, RevealViewController {

    // MARK: - IB Outlets
    
    @IBOutlet weak var summitTextLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var buildNumberLabel: UILabel!
    @IBOutlet weak var nameAndDateLabel: UILabel!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMenuButton()
        
        nameAndDateLabel.text = buildNameDate()
        versionLabel.text = "Version \(AppVersion)"
        buildNumberLabel.text = "Build Number \(AppBuild)"
        
        navigationItem.title = "ABOUT"
        summitTextLabel.sizeToFit()
        
        // set user activity for handoff
        let userActivity = NSUserActivity(activityType: AppActivity.screen.rawValue)
        userActivity.title = "About the Summit"
        userActivity.webpageURL = NSURL(string: AppEnvironment.configuration.webpageURL)
        userActivity.userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.about.rawValue]
        
        self.userActivity = userActivity
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        userActivity?.becomeCurrent()
        
        let webpageURL: NSURL
        
        if let summit = try! Store.shared.managedObjectContext.managedObjects(SummitManagedObject.self).first {
            
            webpageURL = NSURL(string: summit.webpageURL)!
            
        } else {
            
            webpageURL = NSURL(string: AppEnvironment.configuration.webpageURL)!
        }
        
        userActivity?.webpageURL = webpageURL
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if #available(iOS 9.0, *) {
            userActivity?.resignCurrent()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func websiteTouch(sender: AnyObject) {
        let url = NSURL(string: "https://openstack.org")!
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func codeOfConductTouch(sender: AnyObject) {
        let url = NSURL(string: "https://www.openstack.org/summit/barcelona-2016/code-of-conduct")!
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    // MARK: - Private Methods
    
    private func buildNameDate() -> String {
        
        guard let summit = try! Store.shared.managedObjectContext.managedObjects(SummitManagedObject.self).first
            else { return "" }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: summit.timeZone);
        dateFormatter.dateFormat = "MMMM dd-"
        let stringDateFrom = dateFormatter.stringFromDate(summit.start)
        
        dateFormatter.dateFormat = "dd, yyyy"
        let stringDateTo = dateFormatter.stringFromDate(summit.end)
        
        return "\(summit.name) - \(stringDateFrom)\(stringDateTo)"
    }
}
