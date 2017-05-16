//
//  VenuesViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/18/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XLPagerTabStrip
import KTCenterFlowLayout
import CoreSummit

final class VenuesViewController: RevealTabStripViewController {
    
    // MARK: - Properties
    
    let venuesMapViewController = VenuesMapViewController()
    let venueListViewController = R.storyboard.venue.venueListViewController()!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "VENUES"
        buttonBarView.collectionViewLayout = KTCenterFlowLayout()
        
        if let summitManagedObject = self.currentSummit {
            
            let summit = Summit(managedObject: summitManagedObject)
            
            // set user activity for handoff
            let userActivity = NSUserActivity(activityType: AppActivity.screen.rawValue)
            userActivity.title = "Venues"
            userActivity.webpageURL = summit.webpage.appendingPathComponent("travel")
            userActivity.userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.venues.rawValue]
            userActivity.requiredUserInfoKeys = [AppActivityUserInfo.screen.rawValue]
            userActivity.becomeCurrent()
            
            self.userActivity = userActivity
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userActivity?.becomeCurrent()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        userActivity?.resignCurrent()
    }
    
    override func updateUserActivityState(_ userActivity: NSUserActivity) {
        
        let userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.venues.rawValue]
        
        userActivity.addUserInfoEntries(from: userInfo as [AnyHashable: Any])
        
        super.updateUserActivityState(userActivity)
    }
    
    // MARK: - PagerTabStripViewControllerDelegate
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        return [venuesMapViewController, venueListViewController]
    }
}
