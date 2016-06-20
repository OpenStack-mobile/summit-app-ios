//
//  RevealTabStripViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/17/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class RevealTabStripViewController: ButtonBarPagerTabStripViewController {
    
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
        
        if navigationController?.childViewControllers.count == 1 {
            menuButton = UIBarButtonItem()
            menuButton.target = revealViewController()
            menuButton.action = Selector("revealToggle:")
            menuButton.image = UIImage(named: "menu")
            navigationItem.leftBarButtonItem = menuButton
        }
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        edgesForExtendedLayout = UIRectEdge.Top
        
    }
}