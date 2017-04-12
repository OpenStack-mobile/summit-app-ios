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
    
    @IBOutlet fileprivate(set) weak var summitActivityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet fileprivate(set) weak var summitView: UIView!
    
    @IBOutlet fileprivate(set) weak var summitDateLabel: UILabel!
    
    @IBOutlet fileprivate(set) weak var summitNameLabel: UILabel!
    
    @IBOutlet fileprivate(set) weak var dataLoadedActivityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet fileprivate(set) weak var loginButton: UIButton!
    
    @IBOutlet fileprivate(set) weak var guestButton: UIButton!
    
    @IBOutlet fileprivate(set) weak var summitsButton: UIButton!
    
    // MARK: - Properties
    
    fileprivate(set) var willTransition = false  {
        
        didSet { configureView() }
    }
    
    fileprivate var state: State = .loadingSummits {
        
        didSet { configureView() }
    }
    
    fileprivate var summit: SummitsResponse.Summit?
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.summitsButton.enabled = AppEnvironment == .Staging
        
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Store.shared.isLoggedIn {
            
            self.willTransition = true
            
            let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: delayTime) { [weak self] in
                
                self?.showRevealController()
            }
            
        } else {
            
            self.loadSummits()
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        
        return .lightContent
    }
    
    // MARK: - Actions
    
    @IBAction func login(_ sender: UIButton) {
        
        showRevealController(sender) {
            
            AppDelegate.shared.menuViewController.login(sender)
        }
    }
    
    @IBAction func continueAsGuest(_ sender: UIButton) {
        
        showRevealController(sender)
    }
    
    // MARK: - Private Methods
    
    fileprivate func configureView() {
        
        switch state {
            
        case .loadingSummits:
            
            self.summitView.isHidden = true
            self.summitActivityIndicatorView.isHidden = false
            self.summitActivityIndicatorView.startAnimating()
            
            self.guestButton.isHidden = self.isDataLoaded == false || self.willTransition
            self.loginButton.isHidden = self.isDataLoaded == false || self.willTransition
            
            self.dataLoadedActivityIndicatorView.isHidden = true
            self.dataLoadedActivityIndicatorView.stopAnimating()
            
        case .loadingData:
            
            assert(self.summit != nil, "Invalid State")
            
            self.summitView.isHidden = false
            self.summitActivityIndicatorView.isHidden = true
            self.summitActivityIndicatorView.stopAnimating()
            
            self.guestButton.isHidden = true
            self.loginButton.isHidden = true
            
            self.dataLoadedActivityIndicatorView.isHidden = false
            self.dataLoadedActivityIndicatorView.startAnimating()
            
        case .dataLoaded:
            
            assert(self.isDataLoaded, "Invalid State")
            
            self.summitView.isHidden = false
            self.summitActivityIndicatorView.isHidden = true
            self.summitActivityIndicatorView.stopAnimating()
            
            self.guestButton.isHidden = false
            self.loginButton.isHidden = false
            
            self.dataLoadedActivityIndicatorView.isHidden = true
            self.dataLoadedActivityIndicatorView.stopAnimating()
        }
        
        // show current summit info
        if let summit = self.summit {
            
            self.summitNameLabel.text = summit.name.uppercaseString
            
            if let datesLabel = summit.datesLabel {
                
                self.summitDateLabel.text = datesLabel
            }
            else {
                
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(name: summit.timeZone.name)
                dateFormatter.dateFormat = "MMMM d-"
                let stringDateFrom = dateFormatter.stringFromDate(summit.start.toFoundation())
                
                dateFormatter.dateFormat = "d, yyyy"
                let stringDateTo = dateFormatter.stringFromDate(summit.end.toFoundation())
                
                self.summitDateLabel.text = stringDateFrom + stringDateTo
            }
        }
    }
    
    func showRevealController(_ sender: AnyObject? = nil, completion: (() -> ())? = nil) {
        
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
        
        self.show(revealViewController, sender: sender)
        
        let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: delayTime) { self.willTransition = false; completion?() }
    }
    
    fileprivate func loadSummits() {
        
        state = .loadingSummits
        
        print("Will load summits")
        
        Store.shared.summits { [weak self] (response) in
            
            OperationQueue.mainQueue().addOperationWithBlock {
                
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
                    
                    switch AppEnvironment {
                        
                    case .Staging:
                        
                        break
                        
                    case .Production:
                        
                        SummitManager.shared.summit.value = latestSummit.identifier
                    }
                    
                    controller.loadData()
                }
            }
        }
    }
    
    fileprivate func loadData() {
        
        guard isDataLoaded == false
            else { state = .dataLoaded; return }
        
        state = .loadingData
        
        let summitID = SummitManager.shared.summit.value
        
        print("Will load summit \(summitID)")
        
        Store.shared.summit(summitID) { (response) in
            
            OperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
            
        case R.segue.launchScreenViewController.showSummits.identifier:
            
            let navigationController = segue.destination as! UINavigationController
            
            let summitsViewController = navigationController.topViewController as! SummitsViewController
            
            summitsViewController.didFinish = { [weak self] in $0.dismiss(animated: true) { self?.loadSummits() } }
            
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
