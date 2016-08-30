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
    
    let venuesMapViewController = VenuesMapViewController()
    let venueListViewController = R.storyboard.venue.venueListViewController()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "VENUES"
        buttonBarView.collectionViewLayout = KTCenterFlowLayout()
    }
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        return [venuesMapViewController, venueListViewController]
    }
}
