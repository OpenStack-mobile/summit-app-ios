//
//  RevealViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 8/29/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SWRevealViewController

class RevealViewController: UIViewController {
    
    final var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuButton = UIBarButtonItem()
        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        menuButton.image = UIImage(named: "menu")
        
        navigationItem.leftBarButtonItem = menuButton
    }
}
