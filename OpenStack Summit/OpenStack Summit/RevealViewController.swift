//
//  RevealViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 8/29/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc protocol RevealViewController: class { }

extension RevealViewController {
    
    var menuButton: UIBarButtonItem {
        
        guard let viewController = self as? UIViewController
            else { fatalError("Only UIViewController subclasses should conform to RevealViewController protocol") }
        
        if viewController.navigationItem.leftBarButtonItem == nil {
            
            addMenuButton()
        }
        
        return viewController.navigationItem.leftBarButtonItem!
    }
    
    func addMenuButton() {
        
        guard let viewController = self as? UIViewController
            else { fatalError("Only UIViewController subclasses should conform to RevealViewController protocol") }
        
        let menuButton = UIBarButtonItem()
        menuButton.target = viewController.revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        menuButton.image = #imageLiteral(resourceName: "menu")
        
        viewController.navigationItem.leftBarButtonItem = menuButton
    }
}
