//
//  SpeakersViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 12/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

/// Container view controller for `SpeakersListViewController`.
final class SpeakersViewController: RevealViewController {
    
    let speakersListViewController = R.storyboard.people.speakerListViewController()!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.topItem?.title = "SPEAKERS"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildViewController(speakersListViewController)
        speakersListViewController.view.frame = view.bounds
        view.addSubview(speakersListViewController.view)
        speakersListViewController.didMoveToParentViewController(self)
    }
    
}
