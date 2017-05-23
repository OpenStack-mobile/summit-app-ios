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

final class LaunchScreenViewController: UIViewController, MessageEnabledViewController, SummitActivityHandlingViewController {
    
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
    
    private var willTransition = false  {
        
        didSet { configureView() }
    }
    
    private var state: State = .loadingSummits {
        
        didSet { configureView() }
    }
    
    private var summit: SummitsResponse.Summit?
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.summitsButton.isEnabled = AppEnvironment == .staging
        
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Store.shared.isLoggedIn {
            
            self.willTransition = true
            
        } else {
            
            self.loadSummits()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Store.shared.isLoggedIn {
            
            showRevealController()
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        
        return .lightContent
    }
    
    // MARK: - Actions
    
    @IBAction func login(_ sender: UIButton) {
        
        showRevealController(sender) { $0.menuViewController.login(sender) }
    }
    
    @IBAction func continueAsGuest(_ sender: UIButton) {
        
        showRevealController(sender)
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        let _ = view
        
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
            
            self.summitNameLabel.text = summit.name.uppercased()
            
            if let datesLabel = summit.datesLabel {
                
                self.summitDateLabel.text = datesLabel
            }
            else {
                
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(identifier: summit.timeZone.name)
                dateFormatter.dateFormat = "MMMM d-"
                let stringDateFrom = dateFormatter.string(from: summit.start)
                
                dateFormatter.dateFormat = "d, yyyy"
                let stringDateTo = dateFormatter.string(from: summit.end)
                
                self.summitDateLabel.text = stringDateFrom + stringDateTo
            }
        }
    }
    
    private func showRevealController(_ sender: AnyObject? = nil, completion: ((MainRevealViewController) -> ())? = nil) {
        
        self.willTransition = true
        
        let revealViewController = MainRevealViewController()
        
        self.show(revealViewController, sender: sender)
        
        self.willTransition = false;
        
        let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: delayTime) { completion?(revealViewController) }
    }
    
    private func loadSummits() {
        
        state = .loadingSummits
        
        print("Will load summits")
        
        Store.shared.summits { [weak self] (response) in
            
            OperationQueue.main.addOperation {
                
                guard let controller = self else { return }
                
                switch response {
                    
                case let .error(error):
                    
                    print("Error getting summits: \(error)")
                    
                    // try again
                    controller.loadSummits()
                    
                case let .value(page):
                    
                    guard let latestSummit = page.items.last
                        else { fatalError("No summits") }
                    
                    print("Loaded \(page.total) summits")
                    
                    controller.summit = latestSummit
                    
                    if SummitManager.shared.summit.value == 0 {
                        
                        SummitManager.shared.summit.value = latestSummit.identifier
                    }
                    
                    switch AppEnvironment {
                        
                    case .staging:
                        
                        break
                        
                    case .production:
                        
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
            
            OperationQueue.main.addOperation { [weak self] in
                
                guard let controller = self else { return }
                
                switch response {
                    
                case let .error(error):
                    
                    print("Error loading summit \(summitID): \(error)")
                    
                    // try again
                    controller.loadData()
                    
                case let .value(summit):
                    
                    assert(controller.isDataLoaded)
                    
                    print("Loaded \(summit.name) summit")
                    
                    controller.state = .dataLoaded
                }
            }
        }
    }
    
    // MARK: - SummitActivityHandlingViewController
    
    func view(data: AppActivitySummitDataType, identifier: Identifier) {
        
        showRevealController(self) { $0.view(data: data, identifier: identifier) }
    }
    
    func view(screen: AppActivityScreen) {
        
        showRevealController(self) { $0.view(screen: screen) }
    }
    
    func search(_ searchTerm: String) {
        
        showRevealController(self) { $0.search(searchTerm) }
    }
    
    // MARK: - Segue
    
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
