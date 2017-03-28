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
    
    final var menuButton: UIBarButtonItem?
    
    var forwardChildBarButtonItems: Bool { return false }
    
    override func viewDidLoad() {
        
        settings.style.buttonBarItemFont = UIFont.systemFontOfSize(17)
        settings.style.buttonBarItemBackgroundColor = UIColor(hexString: "#14273D")
        settings.style.buttonBarItemsShouldFillAvailiableWidth = false
        settings.style.buttonBarBackgroundColor = UIColor(hexString: "#14273D")
        settings.style.selectedBarBackgroundColor = UIColor(hexString: "#14273D")!
        settings.style.buttonBarHeight = settings.style.buttonBarHeight ?? 88
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) in
            
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = UIColor(white: 1, alpha: 0.6)
            newCell?.label.textColor = .whiteColor()
        }
        
        super.viewDidLoad()
        
        if navigationController?.childViewControllers.count == 1 {
            
            let menuButton = UIBarButtonItem()
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            menuButton.image = R.image.menu()!
            
            navigationItem.leftBarButtonItem = menuButton
            self.menuButton = menuButton
        }
        
        setBlankBackBarButtonItem()
        
        edgesForExtendedLayout = UIRectEdge.Top
        
        view.backgroundColor = UIColor(hexString: "#E5E5E5")
        
        reloadBarButtonItems()
    }
    
    // MARK: - Private Methods
    
    private func reloadBarButtonItems() {
        
        guard forwardChildBarButtonItems else { return }
        
        guard self.childViewControllers.isEmpty == false else { return }
        
        let topChild = self.viewControllers[self.currentIndex]
        
        self.navigationItem.rightBarButtonItems = topChild.navigationItem.rightBarButtonItems
        
        self.toolbarItems = topChild.toolbarItems
    }
    
    override func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        
        super.pagerTabStripViewController(pagerTabStripViewController, updateIndicatorFromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, indexWasChanged: indexWasChanged)
        
        reloadBarButtonItems()
    }
}
