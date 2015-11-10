//
//  BaseViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        navigationController?.navigationBar.topItem?.title = ""
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = UIColor(red: 33/255, green: 64/255, blue: 101/255, alpha: 1.0)
        navigationController?.navigationBar.translucent = false

        
        super.viewDidLoad()
    }
}
