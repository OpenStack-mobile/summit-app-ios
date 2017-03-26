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

final class LaunchScreenViewController: UIViewController, MessageEnabledViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var summitActivityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet private(set) weak var summitView: UIView!
    
    @IBOutlet private(set) weak var summitDateLabel: UILabel!
    
    @IBOutlet private(set) weak var summitNameLabel: UILabel!
    
    @IBOutlet private(set) weak var dataLoadedActivityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet private(set) weak var loginButton: UIButton!
    
    @IBOutlet private(set) weak var guestButton: UIButton!
    
    @IBOutlet private(set) weak var summitsButton: UIButton!
    
    // MARK: - Properties
    
    private(set) var willTransition = false  {
        
        didSet { configureView() }
    }
    
    private var state: State = .loadingSummits {
        
        didSet { configureView() }
    }
    
    private var summit: SummitsResponse.Summit?
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.summitsButton.enabled = AppEnvironment == .Staging
        
        configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        switch state {
            
        case .loadingSummits:
            
            self.summitView.hidden = true
            self.summitActivityIndicatorView.hidden = false
            self.summitActivityIndicatorView.startAnimating()
            
            self.guestButton.hidden = self.isDataLoaded == false || self.willTransition
            self.loginButton.hidden = self.isDataLoaded == false || self.willTransition
            
            self.dataLoadedActivityIndicatorView.hidden = true
            self.dataLoadedActivityIndicatorView.stopAnimating()
            
        case .loadingData:
            
            assert(self.summit != nil, "Invalid State")
            
            self.summitView.hidden = false
            self.summitActivityIndicatorView.hidden = true
            self.summitActivityIndicatorView.stopAnimating()
            
            self.guestButton.hidden = true
            self.loginButton.hidden = true
            
            self.dataLoadedActivityIndicatorView.hidden = false
            self.dataLoadedActivityIndicatorView.startAnimating()
            
        case .dataLoaded:
            
            assert(self.isDataLoaded, "Invalid State")
            
            self.summitView.hidden = false
            self.summitActivityIndicatorView.hidden = true
            self.summitActivityIndicatorView.stopAnimating()
            
            self.guestButton.hidden = false
            self.loginButton.hidden = false
            
            self.dataLoadedActivityIndicatorView.hidden = true
            self.dataLoadedActivityIndicatorView.stopAnimating()
        }
        
        // show current summit info
        if let summit = self.summit {
            
            self.summitNameLabel.text = summit.name.uppercaseString
            
            if let datesLabel = summit.datesLabel {
                
                self.summitDateLabel.text = datesLabel
            }
            else {
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.timeZone = NSTimeZone(name: summit.timeZone.name)
                dateFormatter.dateFormat = "MMMM d-"
                let stringDateFrom = dateFormatter.stringFromDate(summit.start.toFoundation())
                
                dateFormatter.dateFormat = "d, yyyy"
                let stringDateTo = dateFormatter.stringFromDate(summit.end.toFoundation())
                
                self.summitDateLabel.text = stringDateFrom + stringDateTo
            }
        }
    }
    
    func showRevealController(sender: AnyObject? = nil, completion: (() -> ())? = nil) {
        
        self.willTransition = true
        
        // load summit
        if isDataLoaded == false {
            
            /*
            let summit = SummitManager.shared.summit.value
            
            self.showActivityIndicator()
            
            Store.shared.summit(summit) { [weak self] (response) in
                
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    
                    guard let controller = self else { return }
                    
                    controller.dismissActivityIndicator()
                    
                    switch response {
                        
                    case let .Error(error):
                        
                        controller.showErrorMessage(error)
                        
                    case .Value:
                        
                        controller.showRevealController(sender, completion: completion)
                    }
                }
            }
            
            return */
        }
        
        let revealViewController = AppDelegate.shared.revealViewController
        
        self.showViewController(revealViewController, sender: sender)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue()) { self.willTransition = false; completion?() }
    }
    
    private func loadSummits() {
        
        state = .loadingSummits
        
        print("Will load summits")
        
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
                    
                    print("Loaded \(page.total) summits")
                    
                    controller.summit = latestSummit
                    
                    if SummitManager.shared.summit.value == 0 {
                        
                        SummitManager.shared.summit.value = latestSummit.identifier
                    }
                    
                    controller.loadData()
                }
            }
        }
    }
    
    private func loadData() {
        
        guard isDataLoaded == false
            else { state = .dataLoaded; return }
        
        state = .loadingData
        
        let summitID = SummitManager.shared.summit.value
        
        print("Will load summit \(summitID)")
        
        Store.shared.summit(summitID) { (response) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                
                guard let controller = self else { return }
                
                switch response {
                    
                case let .Error(error):
                    
                    print("Error loading summit \(summitID): \(error)")
                    
                    // try again
                    controller.loadData()
                    
                case let .Value(summit):
                    
                    assert(controller.isDataLoaded)
                    
                    print("Loaded \(summit.name) summit")
                    
                    controller.state = .dataLoaded
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            
        case R.segue.launchScreenViewController.showSummits.identifier:
            
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let summitsViewController = navigationController.topViewController as! SummitsViewController
            
            summitsViewController.didFinish = { [weak self] in $0.dismissViewControllerAnimated(true) { self?.loadSummits() } }
            
        default: fatalError()
        }
    }
}

// MARK: - Supporting Types

private extension LaunchScreenViewController {
    
    enum State {
        
        case loadingSummits
        case loadingData
        case dataLoaded
    }
}
