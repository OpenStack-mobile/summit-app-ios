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
    
    @IBOutlet private(set) weak var summitDaysLeftLabel: UILabel!
    
    @IBOutlet private(set) weak var summitDaysStackView: UIStackView!
    
    @IBOutlet private(set) weak var summitDaysStackViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private(set) weak var summitDaysStackViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet private(set) weak var dataLoadedActivityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet private(set) weak var loginButton: UIButton!
    
    @IBOutlet private(set) weak var guestButton: UIButton!
    
    @IBOutlet private(set) weak var summitsButton: UIButton!
    
    // MARK: - Properties
    
    private var digitLabels = [UILabel]()
    
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
        
        self.loadSummits()
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
            
            self.guestButton.isHidden = true
            self.loginButton.isHidden = true
            
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
            
        case .transitioning:
            
            assert(Store.shared.isLoggedIn, "Invalid State")
            
            self.summitView.isHidden = false
            self.summitActivityIndicatorView.isHidden = true
            self.summitActivityIndicatorView.stopAnimating()
            
            self.guestButton.isHidden = true
            self.loginButton.isHidden = true
            
            self.dataLoadedActivityIndicatorView.isHidden = false
            self.dataLoadedActivityIndicatorView.startAnimating()
        }
        
        if let summit = self.summit {
            
            let latestSummit = Summit(from: summit)
            
            configureSummitView(summit: latestSummit)
        }
        else if let currentSummit = currentSummit {
            
            let current = Summit(from: currentSummit)
            
            configureSummitView(summit: current)
        }
    }
    
    private func configureSummitView(summit: Summit) {
        
        var digitWidth, digitHeight, stackViewWidth, stackViewHeight: CGFloat
        
        var stackViewAxix: UILayoutConstraintAxis = .horizontal
        var stackViewDistribution: UIStackViewDistribution = .fillEqually
        
        for label in digitLabels {
            
            summitDaysStackView.removeArrangedSubview(label)
            label.removeFromSuperview()
        }
        
        digitLabels.removeAll()
        
        // show current summit info
        self.summitDateLabel.text = summit.summitDates
        
        switch summit.phase {
            
        case let .comingSoon(daysLeft: daysLeft):
            
            digitWidth = 30
            digitHeight = 36
            
            let stringDaysLeft = String(daysLeft)
            
            for digit in stringDaysLeft {
                
                let label = styledLabel()
                label.text = "\(digit)"
                label.font = UIFont(name: "OpenSans", size: 18.0)
                label.addBorders(edges: [.all], color: .white, thickness: 0.5)
                
                summitDaysStackView.addArrangedSubview(label)
                digitLabels.append(label)
            }
            
            stackViewWidth = CGFloat(stringDaysLeft.count) * digitWidth
            stackViewHeight = digitHeight
            
            summitDaysLeftLabel.text = "Day\(daysLeft == 1 ? "" : "s") Left".uppercased()
            
        case let .during(day: day):
            
            digitWidth = 63
            digitHeight = 83
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.minimumLineHeight = 20
            
            let attributes = [ NSAttributedStringKey.font: UIFont(name: "OpenSans", size: 11.0)!,
                               NSAttributedStringKey.paragraphStyle: paragraphStyle ]
            
            let attributedString = NSAttributedString(string: "day".uppercased(), attributes: attributes)
            
            let label = styledLabel()
            label.attributedText = attributedString
            label.addBorders(edges: [.left, .top, .right], color: .white, thickness: 0.5)
            
            summitDaysStackView.addArrangedSubview(label)
            digitLabels.append(label)
            
            let paragraphStyleDigit = NSMutableParagraphStyle()
            paragraphStyleDigit.alignment = .center
            paragraphStyleDigit.lineHeightMultiple = 0.9
            
            let attributesDigit = [ NSAttributedStringKey.font: UIFont(name: "OpenSans-Light", size: 60.0)!,
                                    NSAttributedStringKey.paragraphStyle: paragraphStyleDigit ]
            
            let attributedStringDigit = NSAttributedString(string: "\(day)", attributes: attributesDigit)
            
            let labelDigit = styledLabel()
            labelDigit.attributedText = attributedStringDigit
            labelDigit.addBorders(edges: [.left, .bottom, .right], color: .white, thickness: 0.5)
            
            summitDaysStackView.addArrangedSubview(labelDigit)
            digitLabels.append(labelDigit)
            
            stackViewWidth = digitWidth
            stackViewHeight = digitHeight
            
            stackViewAxix = .vertical
            stackViewDistribution = .fill
            
            summitDaysLeftLabel.text = ""
            
        case .finished:
            
            stackViewWidth = 0
            stackViewHeight = 0
            
            summitDaysLeftLabel.text = ""
        }
        
        summitDaysStackViewWidthConstraint.constant = stackViewWidth
        summitDaysStackViewHeightConstraint.constant = stackViewHeight
        
        summitDaysStackView.axis = stackViewAxix
        summitDaysStackView.distribution = stackViewDistribution
        summitDaysStackView.setNeedsUpdateConstraints()
    }
    
    private func styledLabel() -> UILabel {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        
        return label
    }
    
    private func showRevealController(_ sender: AnyObject? = nil, delay: Double = 0, completion: ((MainRevealViewController) -> ())? = nil) {
        
        self.willTransition = true
        
        let revealViewController = MainRevealViewController()
        
        self.willTransition = false
        
        DispatchQueue.main.asyncAfter(deadline: dispatchTime(from: delay)) {
            
            self.show(revealViewController, sender: sender)
        }
        
        DispatchQueue.main.asyncAfter(deadline: dispatchTime(from: delay + 2)) {
            
            completion?(revealViewController)
        }
    }
    
    private func dispatchTime(from delay: Double) -> DispatchTime {
        
        return DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
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

                    if controller.isDataLoaded {
                        
                        // load stored summit
                        controller.loadData()
                    }
                    else {
                        
                        // try again
                        controller.loadSummits()
                    }
                    
                case let .value(page):
                    
                    guard let latestSummit = page.items.last
                        else { fatalError("No summits") }
                    
                    print("Loaded \(page.total) summits")
                    
                    controller.summit = latestSummit
                    
                    #if DEBUG
                        
                        if SummitManager.shared.summit.value == 0 {
                            
                            SummitManager.shared.summit.value = latestSummit.identifier
                        }
                    #else
                        
                        SummitManager.shared.summit.value = latestSummit.identifier
                    #endif
                    
                    controller.loadData()
                }
            }
        }
    }
    
    private func loadData() {
        
        guard isDataLoaded == false
            else {
                
                if Store.shared.isLoggedIn {
                    
                    showRevealController(self, delay: 2)
                    
                    state = .transitioning
                }
                else {
                    
                    state = .dataLoaded
                }
                
                return
        }
        
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
                    
                    controller.loadData()
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
        case transitioning
    }
    
    struct Summit {
        
        // MARK: - Properties
        
        var name: String
        var timeZone: Foundation.TimeZone?
        var datesLabel: String?
        var start, end: Date
        var defaultStart: Date
        
        var summitDates: String {
            
            if let datesLabel = self.datesLabel {
                
                return datesLabel.uppercased()
            }
            else {
                
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = self.timeZone
                dateFormatter.dateFormat = "MMMM d-"
                let stringDateFrom = dateFormatter.string(from: self.start)
                
                dateFormatter.dateFormat = "d, yyyy"
                let stringDateTo = dateFormatter.string(from: self.end)
                
                return stringDateFrom + stringDateTo
            }
        }
        
        var phase: SummitPhase {
            
            NSDate.mt_setTimeZone(self.timeZone)
            
            let today = NSDate()
            
            let defaultStart = self.defaultStart as NSDate
            let end = self.end as NSDate
            
            let summitStart = defaultStart.mt_startOfCurrentDay()
            let summitEnd = end.mt_startOfNextDay()
            
            if today.mt_is(before: summitStart) {
                
                let daysLeft = today.mt_days(until: summitStart) + 1
                
                return .comingSoon(daysLeft: daysLeft)
            }
            else if today.mt_isBetweenDate(summitStart, andDate: summitEnd) {
                
                let day = today.mt_days(since: summitStart) + 1
                
                return .during(day: day)
            }
            else {
                
                return .finished
            }
        }
        
        // MARK: - Initialization
        
        public init(from summit: SummitsResponse.Summit) {
            
            self.name = summit.name
            self.timeZone = TimeZone(identifier: summit.timeZone.name)
            self.datesLabel = summit.datesLabel
            self.start = summit.start
            self.end = summit.end
            self.defaultStart = summit.defaultStart ?? summit.start
        }
        
        public init(from summit: SummitManagedObject) {
            
            self.name = summit.name
            self.timeZone = TimeZone(identifier: summit.timeZone)
            self.datesLabel = summit.datesLabel
            self.start = summit.start
            self.end = summit.end
            self.defaultStart = summit.defaultStart ?? summit.start
        }
        
        // MARK: - Supporting Types
        
        enum SummitPhase {
            
            case comingSoon(daysLeft: Int)
            case during(day: Int)
            case finished
        }
    }
}
