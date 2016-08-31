//
//  AboutViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 4/6/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import CoreSummit
import RealmSwift

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
        userActivity.webpageURL = NSURL(string: "https://dev-openstack.org-site/summit/barcelona-2016/")
        userActivity.userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.about.rawValue]
        
        self.userActivity = userActivity
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        userActivity?.becomeCurrent()
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
    
    // MARK: - Private Methods
    
    private func buildNameDate() -> String {
        
        guard let realmSummit = Store.shared.realm.objects(RealmSummit).first
            else { return "" }
        
        let summit = Summit(realmEntity: realmSummit)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: summit.timeZone);
        dateFormatter.dateFormat = "MMMM dd-"
        let stringDateFrom = dateFormatter.stringFromDate(summit.start.toFoundation())
        
        dateFormatter.dateFormat = "dd, yyyy"
        let stringDateTo = dateFormatter.stringFromDate(summit.end.toFoundation())
        
        return "\(summit.name) - \(stringDateFrom)\(stringDateTo)"
    }
}
