//
//  MemberProfileViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XLPagerTabStrip
import KTCenterFlowLayout

@objc
public protocol IMemberProfileViewController {
    var presenter: IMemberProfilePresenter! { get set }
    var title: String? { get set }
}

class MemberProfileViewController: ButtonBarPagerTabStripViewController, IMemberProfileViewController {
    
    var presenter: IMemberProfilePresenter!
    var isFirstTime = true
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.viewLoad()
        if !isFirstTime {
            reloadPagerTabStripView()
        }
        isFirstTime = false
    }
    
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
        
        buttonBarView.collectionViewLayout = KTCenterFlowLayout()
    }
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return presenter.getChildViews()
    }
}