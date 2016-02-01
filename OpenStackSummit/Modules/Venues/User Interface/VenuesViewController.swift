//
//  VenuesViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/18/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XLPagerTabStrip

class VenuesViewController: RevealTabStripViewController {
    
    var venuesMapViewController: VenuesMapViewController!
    var venueListViewController: VenueListViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "VENUES"
    }
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return [venuesMapViewController, venueListViewController]
    }
    
}
