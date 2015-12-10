//
//  MyProfileViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/18/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XLPagerTabStrip

@objc
public protocol IMyProfileViewController {
    var presenter: IMyProfilePresenter! { get set }
    var title: String? { get set }
}

class MyProfileViewController: RevealTabStripViewController, IMyProfileViewController {
    
    var presenter: IMyProfilePresenter!
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBar.topItem?.title = title
    }
    
}