//
//  VenuesViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/18/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XLPagerTabStrip
import KTCenterFlowLayout

class VenuesViewController: RevealTabStripViewController {
    var presenter: IVenuesPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "VENUES"
        buttonBarView.collectionViewLayout = KTCenterFlowLayout()
    }
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return presenter.getChildViews()
    }
}
