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
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        navigationController?.navigationBar.barTintColor = UIColor(red: 33/255, green: 64/255, blue: 101/255, alpha: 1.0)
        navigationController?.navigationBar.translucent = false
    
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
    }
}
