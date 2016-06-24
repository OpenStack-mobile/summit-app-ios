//
//  RevealViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 8/29/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SWRevealViewController

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
        
        let revealViewController: SWRevealViewController = {
           
            var parent: UIViewController? = viewController
            
            while parent != nil {
                
                parent = parent?.parentViewController
                
                if let revealVC = parent as? SWRevealViewController {
                    
                    return revealVC
                }
            }
            
            fatalError("Not a child view controller of SWRevealViewController")
        }()
        
        let menuButton = UIBarButtonItem()
        menuButton.target = revealViewController
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        menuButton.image = UIImage(named: "menu")
        
        viewController.navigationItem.leftBarButtonItem = menuButton
    }
}