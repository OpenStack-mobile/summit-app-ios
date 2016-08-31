//
//  VenuesViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/18/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XLPagerTabStrip
import KTCenterFlowLayout

final class VenuesViewController: RevealTabStripViewController {
    
    // MARK: - Properties
    
    let venuesMapViewController = VenuesMapViewController()
    let venueListViewController = R.storyboard.venue.venueListViewController()!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "VENUES"
        buttonBarView.collectionViewLayout = KTCenterFlowLayout()
        
        // set user activity for handoff
        let userActivity = NSUserActivity(activityType: AppActivity.screen.rawValue)
        userActivity.title = "Venues"
        userActivity.webpageURL = NSURL(string: "https://dev-openstack.org-site/summit/barcelona-2016/travel/")
        userActivity.userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.venues.rawValue]
        
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
    
    // MARK: - PagerTabStripViewControllerDelegate
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        return [venuesMapViewController, venueListViewController]
    }
}
