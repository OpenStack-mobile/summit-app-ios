//
//  RevealViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 8/29/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

class RevealViewController: BaseViewController {
    
    var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuButton = UIBarButtonItem()
        menuButton.target = revealViewController()
        menuButton.action = Selector("revealToggle:")
        menuButton.image = UIImage(named: "menu")
        
        navigationItem.leftBarButtonItem = menuButton
    }
}
