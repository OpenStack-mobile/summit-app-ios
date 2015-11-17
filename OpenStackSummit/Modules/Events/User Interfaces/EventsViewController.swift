//
//  EventsViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XLPagerTabStrip

class EventsViewController: RevealTabStripViewController {
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    var generalScheduleViewController: GeneralScheduleViewController!
    var trackListViewController: TrackListViewController!

    var internalPresenter: IEventsPresenter!
    
    var presenter: IEventsPresenter! {
        get {
            return internalPresenter as IEventsPresenter
        }
        set {
            internalPresenter = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (filterButton != nil) {
            filterButton.target = self
            filterButton.action = Selector("showFilters:")
        }
        
        buttonBarView.selectedBar.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0)
        buttonBarView.registerNib(UINib(nibName: "ButtonCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        
        self.changeCurrentIndexBlock = {
            (oldCell: XLButtonBarViewCell!, newCell: XLButtonBarViewCell!, animated: Bool) -> Void in
            
            if (newCell == nil && oldCell != nil) {
                oldCell.label.textColor = UIColor(white: 1, alpha: 0.6)
            }

            if animated {
                oldCell.label.textColor = UIColor(white: 1, alpha: 0.6)
                newCell.label.textColor = UIColor.whiteColor()
            }
        }
    }

    func showFilters(sender: UIBarButtonItem) {
        presenter.showFilters()
    }
    
    override func childViewControllersForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController) -> [AnyObject] {
        return [generalScheduleViewController, trackListViewController]
    }
    
}