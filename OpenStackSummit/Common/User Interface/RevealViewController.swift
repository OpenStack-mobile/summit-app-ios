//
//  RevealViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 8/29/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SWRevealViewController

class RevealViewController: BaseViewController, SWRevealViewControllerDelegate {
    
    var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuButton = UIBarButtonItem()
        menuButton.target = revealViewController()
        menuButton.action = Selector("revealToggle:")
        menuButton.image = UIImage(named: "menu")
        
        navigationItem.leftBarButtonItem = menuButton
        
        revealViewController().delegate = self
        revealViewController().rearViewRevealWidth = 264
        revealViewController().view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        revealViewController().delegate = self
    }
    
    func revealController(revealController: SWRevealViewController, willMoveToPosition position:FrontViewPosition) {
        view.userInteractionEnabled = position == FrontViewPosition.Left
    }

}
