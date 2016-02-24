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
    
    var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        settings.style.buttonBarItemFont = UIFont.systemFontOfSize(17)
        settings.style.buttonBarItemBackgroundColor = UIColor(hexaString: "#14273D")
        settings.style.buttonBarItemsShouldFillAvailiableWidth = false
        settings.style.buttonBarBackgroundColor = UIColor(hexaString: "#14273D")
        settings.style.selectedBarBackgroundColor = UIColor(hexaString: "#14273D")
        settings.style.buttonBarHeight = 88
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = UIColor(white: 1, alpha: 0.6)
            newCell?.label.textColor = .whiteColor()
        }
        
        super.viewDidLoad()
        
        menuButton = UIBarButtonItem()
        menuButton.target = revealViewController()
        menuButton.action = Selector("revealToggle:")
        menuButton.image = UIImage(named: "menu")
        
        navigationItem.leftBarButtonItem = menuButton
        
        revealViewController()?.delegate = self
        revealViewController()?.rearViewRevealWidth = 264
        revealViewController()?.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }
    
    func revealController(revealController: SWRevealViewController, willMoveToPosition position:FrontViewPosition) {
        view.userInteractionEnabled = position == FrontViewPosition.Left
    }
    
}