//
//  ScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/3/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//


import UIKit
import XLPagerTabStrip
import SWRevealViewController

class GeneralScheduleViewController: ScheduleViewController, SWRevealViewControllerDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    var presenter: IGeneralSchedulePresenter! {
        get {
            return internalPresenter as! IGeneralSchedulePresenter
        }
        set {
            internalPresenter = newValue
        }
    }
    
    @IBAction func showFilters(sender: UIBarButtonItem) {
        presenter.showFilters()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (menuButton != nil) {
            menuButton.target = self.revealViewController()
            menuButton.action = Selector("revealToggle:")
        }
        
        if (filterButton != nil) {
            filterButton.target = self
            filterButton.action = Selector("showFilters:")
        }
        
        /*self.revealViewController().delegate = self
        self.revealViewController().view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())*/
        
        self.presenter.viewLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func revealController(revealController: SWRevealViewController, willMoveToPosition position:FrontViewPosition) {
        self.view.userInteractionEnabled = position == FrontViewPosition.Left
    }
    
    func titleForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController) -> String {
        return "General Schedule"
    }
}
