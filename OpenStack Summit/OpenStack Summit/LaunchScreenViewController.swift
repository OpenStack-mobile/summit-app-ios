//
//  LaunchScreenViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/1/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreSummit

final class LaunchScreenViewController: UIViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var guestButton: UIButton!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginButton.hidden = Store.shared.isLoggedIn
        self.guestButton.hidden = Store.shared.isLoggedIn
        
        if Store.shared.isLoggedIn {
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            
            dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                
                self?.showRevealController()
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func login(sender: UIButton) {
        
        showRevealController(sender)
        
        AppDelegate.shared.menuViewController.login(sender)
    }
    
    @IBAction func continueAsGuest(sender: UIButton) {
        
        showRevealController(sender)
    }
    
    // MARK: - Private Methods
    
    @inline(__always)
    private func showRevealController(sender: AnyObject? = nil) {
        
        let revealViewController = AppDelegate.shared.revealViewController
        
        self.showViewController(revealViewController, sender: sender)
    }
}
