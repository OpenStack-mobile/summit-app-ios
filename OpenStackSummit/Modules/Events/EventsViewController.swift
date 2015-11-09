//
//  EventsViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import DKScrollingTabController

class EventsViewController: RevealViewController, DKScrollingTabControllerDelegate {
    
    let tabController = DKScrollingTabController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addChildViewController(tabController)
        tabController.didMoveToParentViewController(self)
        self.view.addSubview(tabController.view)
        tabController.view.frame = CGRectMake(0, 40, 320, 80)
        tabController.buttonPadding = 25
        tabController.selection = ["Schedule", "Tracks"]
        tabController.delegate = self
    }
    
    func ScrollingTabController(controller: DKScrollingTabController!, selection: UInt) {
        print("tapped \(selection) \n")
    }
    
}