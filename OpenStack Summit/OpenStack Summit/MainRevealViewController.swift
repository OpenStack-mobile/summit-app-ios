//
//  MainRevealViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 5/8/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit

final class MainRevealViewController: SWRevealViewController {
    
    let menuViewController: MenuViewController
    
    init() {
        
        self.menuViewController = R.storyboard.menu.menuViewController()!
        
        let frontViewController = UINavigationController(rootViewController: self.menuViewController.generalScheduleViewController)
        
        super.init(rearViewController: menuViewController, frontViewController: frontViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
