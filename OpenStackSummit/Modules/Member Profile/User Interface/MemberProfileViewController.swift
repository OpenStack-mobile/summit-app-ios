//
//  MemberProfileViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XLPagerTabStrip
import KTCenterFlowLayout

@objc
public protocol IMemberProfileViewController {
    var presenter: IMemberProfilePresenter! { get set }
    var title: String? { get set }
}

class MemberProfileViewController: RevealTabStripViewController, IMemberProfileViewController {
    
    var presenter: IMemberProfilePresenter!
    var isFirstTime = true
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.viewLoad()
        if !isFirstTime {
            reloadPagerTabStripView()
        }
        isFirstTime = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonBarView.collectionViewLayout = KTCenterFlowLayout()
    }
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return presenter.getChildViews()
    }
}