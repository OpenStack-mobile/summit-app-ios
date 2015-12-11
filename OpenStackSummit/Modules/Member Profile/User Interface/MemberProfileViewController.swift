//
//  MemberProfileViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XLPagerTabStrip

@objc
public protocol IMemberProfileViewController {
    var presenter: IMemberProfilePresenter! { get set }
    var title: String? { get set }
}

class MemberProfileViewController: RevealTabStripViewController, IMemberProfileViewController {
    
    var presenter: IMemberProfilePresenter!
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBar.topItem?.title = title
    }
    
}