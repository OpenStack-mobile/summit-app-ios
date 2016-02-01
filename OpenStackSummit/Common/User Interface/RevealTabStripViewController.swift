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

class RevealTabStripViewController: ButtonBarPagerTabStripViewController, SWRevealViewControllerDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        navigationController?.navigationBar.barTintColor = UIColor(red: 33/255, green: 64/255, blue: 101/255, alpha: 1.0)
        navigationController?.navigationBar.translucent = false
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        if (menuButton != nil) {
            menuButton.target = revealViewController()
            menuButton.action = Selector("revealToggle:")
        }
        
        revealViewController()?.delegate = self
        revealViewController()?.rearViewRevealWidth = 264
        revealViewController()?.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        
        settings.style.buttonBarItemFont = UIFont.systemFontOfSize(17)
        settings.style.buttonBarItemBackgroundColor = UIColor(hexaString: "#14273D")
        settings.style.buttonBarItemsShouldFillAvailiableWidth = false
        buttonBarView.selectedBar.alpha = 0
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = UIColor(white: 1, alpha: 0.6)
            newCell?.label.textColor = .whiteColor()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func revealController(revealController: SWRevealViewController, willMoveToPosition position:FrontViewPosition) {
        view.userInteractionEnabled = position == FrontViewPosition.Left
    }
    
}