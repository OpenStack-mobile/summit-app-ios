//
//  RevealTabStripViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/17/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SWRevealViewController

class RevealTabStripViewController: TabStripViewController, SWRevealViewControllerDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.title = ""
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        navigationController?.navigationBar.barTintColor = UIColor(red: 33/255, green: 64/255, blue: 101/255, alpha: 1.0)
        navigationController?.navigationBar.translucent = false
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        if (menuButton != nil) {
            menuButton.target = revealViewController()
            menuButton.action = Selector("revealToggle:")
        }
        
        revealViewController().delegate = self
        revealViewController().rearViewRevealWidth = 264
        revealViewController().view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        
        buttonBarView.selectedBar.alpha = 0
        
        changeCurrentIndexBlock = {
            (oldCell: XLButtonBarViewCell!, newCell: XLButtonBarViewCell!, animated: Bool) -> Void in
            
            if newCell == nil && oldCell != nil {
                oldCell.label.textColor = UIColor(white: 1, alpha: 0.6)
            }
            
            if animated {
                oldCell.label.textColor = UIColor(white: 1, alpha: 0.6)
                newCell.label.textColor = UIColor.whiteColor()
            }
        }
        
        reloadPagerTabStripView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func revealController(revealController: SWRevealViewController, willMoveToPosition position:FrontViewPosition) {
        view.userInteractionEnabled = position == FrontViewPosition.Left
    }
}