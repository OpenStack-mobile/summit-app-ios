//
//  MemberProfileViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XLPagerTabStrip

@objc
public protocol IMemberProfileViewController {
    var presenter: IMemberProfilePresenter! { get set }
    var title: String? { get set }
}

class MemberProfileViewController: TabStripViewController, IMemberProfileViewController {
    
    var presenter: IMemberProfilePresenter!
    var isFirstTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    
    override func viewWillAppear(animated: Bool) {
        presenter.viewLoad()
        navigationController?.navigationBar.topItem?.title = title
        if !isFirstTime {
            reloadPagerTabStripView()
        }
        isFirstTime = false
    }
    
    override func childViewControllersForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController) -> [AnyObject] {
        return presenter.getChildViews()
    }
}