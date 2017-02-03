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

final class LaunchScreenViewController: UIViewController, MessageEnabledViewController, ShowActivityIndicatorProtocol {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var guestButton: UIButton!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var summitView: UIView!
    
    @IBOutlet weak var summitDateLabel: UILabel!
    
    @IBOutlet weak var summitNameLabel: UILabel!
    
    // MARK: - Properties
    
    private(set) var willTransition = false
    
    private var summit: SummitsResponse.Summit?
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureView()
        
        if Store.shared.isLoggedIn {
            
            self.willTransition = true
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            
            dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                
                self?.showRevealController()
            }
            
        } else {
            
            self.loadSummits()
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: - Actions
    
    @IBAction func login(sender: UIButton) {
        
        showRevealController(sender) {
            
            AppDelegate.shared.menuViewController.login(sender)
        }
    }
    
    @IBAction func continueAsGuest(sender: UIButton) {
        
        showRevealController(sender)
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        self.guestButton.hidden = Store.shared.isLoggedIn
        self.loginButton.hidden = Store.shared.isLoggedIn
        self.loginButton.enabled = SummitManager.shared.summit.value > 0
        
        self.summitView.hidden = self.summit == nil
        self.activityIndicatorView.hidden = self.summit != nil
        
        if let summit = self.summit {
            
            self.activityIndicatorView.stopAnimating()
            
            self.summitNameLabel.text = summit.name
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeZone = NSTimeZone(name: summit.timeZone.name)
            dateFormatter.dateFormat = "MMMM dd-"
            let stringDateFrom = dateFormatter.stringFromDate(summit.start.toFoundation())
            
            dateFormatter.dateFormat = "dd, yyyy"
            let stringDateTo = dateFormatter.stringFromDate(summit.end.toFoundation())
            
            self.summitDateLabel.text = stringDateFrom + stringDateTo
            
        } else {
            
            self.activityIndicatorView.startAnimating()
        }
    }
    
    func showRevealController(sender: AnyObject? = nil, completion: (() -> ())? = nil) {
        
        self.willTransition = true
        
        // load summit
        if isDataLoaded == false {
            
            let summit = SummitManager.shared.summit.value
            
            self.showActivityIndicator()
            
            Store.shared.summit(summit) { [weak self] (response) in
                
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    
                    guard let controller = self else { return }
                    
                    controller.hideActivityIndicator()
                    
                    switch response {
                        
                    case let .Error(error):
                        
                        controller.showErrorMessage(error)
                        
                    case .Value:
                        
                        controller.showRevealController(sender, completion: completion)
                    }
                }
            }
            
            return
        }
        
        let revealViewController = AppDelegate.shared.revealViewController
        
        self.showViewController(revealViewController, sender: sender)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue()) { self.willTransition = false; completion?() }
    }
    
    private func loadSummits() {
        
        Store.shared.summits { [weak self] (response) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                
                guard let controller = self else { return }
                
                switch response {
                    
                case let .Error(error):
                    
                    print("Error getting summits: \(error)")
                    
                    // try again
                    controller.loadSummits()
                    
                case let .Value(page):
                    
                    guard let latestSummit = page.items.last
                        else { fatalError("No summits") }
                    
                    controller.summit = latestSummit
                    
                    if SummitManager.shared.summit.value == 0 {
                        
                        SummitManager.shared.summit.value = latestSummit.identifier
                    }
                    
                    controller.configureView()
                }
            }
        }
    }
}
