//
//  RevealButtonBarTabStripViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/12/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SWRevealViewController

class RevealButtonBarTabStripViewController: XLButtonBarPagerTabStripViewController, SWRevealViewControllerDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        navigationController?.navigationBar.topItem?.title = ""
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = UIColor(red: 33/255, green: 64/255, blue: 101/255, alpha: 1.0)
        navigationController?.navigationBar.translucent = false
        
        super.viewDidLoad()
        
        if (menuButton != nil) {
            menuButton.target = self.revealViewController()
            menuButton.action = Selector("revealToggle:")
        }
        
        self.revealViewController().delegate = self
        self.revealViewController().view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func revealController(revealController: SWRevealViewController, willMoveToPosition position:FrontViewPosition) {
        self.view.userInteractionEnabled = position == FrontViewPosition.Left
    }
    
}