//
//  AboutViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/07/17.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreSummit
import MessageUI

final class AboutViewController: UITableViewController, RevealViewController, EmailComposerViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet var wirelessNetworksHeaderView: UIView!
    
    @IBOutlet var wirelessNetworksFooterView: UIView!
    
    // MARK: - Properties
    
    private var summitCache: Summit?
    
    private var sections = [Section]()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMenuButton()
        
        // setup table view
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // set user activity for handoff
        let userActivity = NSUserActivity(activityType: AppActivity.screen.rawValue)
        userActivity.title = "About the Summit"
        userActivity.webpageURL = NSURL(string: AppEnvironment.configuration.webpageURL)
        userActivity.userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.about.rawValue]
        userActivity.requiredUserInfoKeys = [AppActivityUserInfo.screen.rawValue]
        self.userActivity = userActivity
        
        // setup UI
        configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        userActivity?.becomeCurrent()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        userActivity?.resignCurrent()
    }
    
    override func updateUserActivityState(userActivity: NSUserActivity) {
        
        let userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.about.rawValue]
        
        userActivity.addUserInfoEntriesFromDictionary(userInfo as [NSObject : AnyObject])
        
        super.updateUserActivityState(userActivity)
    }
    
    // MARK: - Actions
    
    @IBAction func showLink(sender: UIButton) {
        
        let link = Link(rawValue: sender.tag)!
        
        switch link {
            
        case .openStackWebsite:
            
            let url = NSURL(string: "https://openstack.org")!
            
            open(url: url)
            
        case .codeOfConduct:
            
            let url = NSURL(string: "https://www.openstack.org/summit/barcelona-2016/code-of-conduct")!
            
            open(url: url)
            
        case .appSupport:
            
            let email = "summitapp@openstack.org"
            
            sendEmail(to: email)
            
        case .generalInquiries:
            
            let email = "summitapp@openstack.org"
            
            sendEmail(to: email)
        }
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        // setup sections
        
        sections = []
        
        if let summitManagedObject = self.currentSummit {
            
            let summit = Summit(managedObject: summitManagedObject)
            
            summitCache = summit
            
            sections.append(.name)
            
            // fetch wireless networks
            
            #if DEBUG
            let summitActive = true // always show for debug builds
            #else
            let summitActive = NSDate().mt_isBetweenDate(summitManagedObject.start, andDate: summitManagedObject.end)
            #endif
            
            if summitActive {
                
                let sort = [NSSortDescriptor(key: "name", ascending: true)]
                
                let wirelessNetworks = try! WirelessNetwork.filter(("summit.id" == summit.identifier).toFoundation(), sort: sort, context: Store.shared.managedObjectContext)
                
                if wirelessNetworks.isEmpty == false {
                    
                    sections.append(.wirelessNetworks(wirelessNetworks))
                }
            }
            
            // setup handoff
            
            userActivity?.webpageURL = NSURL(string: summit.webpageURL)!
            
        } else {
            
            summitCache = nil
            
            userActivity?.webpageURL = NSURL(string: AppEnvironment.configuration.webpageURL)!
        }
        
        var aboutCells = [AboutCell]()
        
        aboutCells += [.links, .description]
        
        sections.append(.about(aboutCells))
        
        // reload table view
        
        self.tableView.reloadData()
    }
    
    @inline(__always)
    private func configure(cell cell: WirelessNetworkCell, with network: WirelessNetwork) {
        
        cell.nameLabel.text = network.name
        
        cell.passwordLabel.text = network.password
    }
    
    @inline(__always)
    private func configure(cell cell: AboutNameCell) {
        
        guard let summit = self.summitCache
            else { fatalError("No summit cache") }
        
        cell.nameLabel.text = summit.name
        
        if let datesLabel = self.summitCache!.datesLabel {
            
            cell.dateLabel.text = datesLabel
        }
        else {
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeZone = NSTimeZone(name: summit.timeZone)
            dateFormatter.dateFormat = "MMMM dd-"
            let stringDateFrom = dateFormatter.stringFromDate(summit.start.toFoundation())
            
            dateFormatter.dateFormat = "dd, yyyy"
            let stringDateTo = dateFormatter.stringFromDate(summit.end.toFoundation())
            
            cell.dateLabel.text = "\(stringDateFrom)\(stringDateTo)"
        }
        
        cell.buildVersionLabel.text = "Version \(AppVersion)"
        cell.buildNumberLabel.text = "Build \(AppBuild)"
    }
    
    @inline(__always)
    private func open(url url: NSURL) {
        
        if UIApplication.sharedApplication().canOpenURL(url) {
            
            UIApplication.sharedApplication().openURL(url)
            
        } else {
            
            showErrorAlert("Could open URL.")
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection index: Int) -> Int {
        
        let section = sections[index]
        
        switch section {
            
        case .name: return 1
            
        case let .wirelessNetworks(networks): return networks.count
            
        case let .about(cells): return cells.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let section = sections[indexPath.section]
        
        switch section {
        
        case .name:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.aboutNameCell, forIndexPath: indexPath)!
            
            configure(cell: cell)
            
            return cell
            
        case let .wirelessNetworks(networks):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.wirelessNetworkCell, forIndexPath: indexPath)!
            
            let network = networks[indexPath.row]
            
            configure(cell: cell, with: network)
            
            return cell
            
        case let .about(aboutCells):
            
            let data = aboutCells[indexPath.row]
            
            switch data {
            
            case .links:
                
                return tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.aboutLinksCell, forIndexPath: indexPath)!
                
            case .description:
                
                return tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.aboutDescriptionCell, forIndexPath: indexPath)!
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForHeaderInSection index: Int) -> CGFloat {
        
        let section = sections[index]
        
        switch section {
        case .wirelessNetworks: return 90
        case .name, .about: return 0
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection index: Int) -> UIView? {
        
        let section = sections[index]
        
        switch section {
        case .wirelessNetworks: return wirelessNetworksHeaderView
        case .name, .about: return nil
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection index: Int) -> CGFloat {
        
        let section = sections[index]
        
        switch section {
        case .wirelessNetworks: return 30
        case .name, .about: return 0
        }
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection index: Int) -> UIView? {
        
        let section = sections[index]
        
        switch section {
        case .wirelessNetworks: return wirelessNetworksFooterView
        case .name, .about: return nil
        }
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        dismissViewControllerAnimated(true) {
            
            if let error = error {
                
                self.showErrorAlert(error.localizedDescription)
            }
        }
    }
}

// MARK: - Supporting Types

private extension AboutViewController {
    
    enum Section {
        
        case name
        case wirelessNetworks([WirelessNetwork])
        case about([AboutCell])
    }
    
    enum AboutCell {
        
        case links
        case description
    }
    
    enum Link: Int {
        
        case openStackWebsite
        case codeOfConduct
        case appSupport
        case generalInquiries
    }
}

final class WirelessNetworkCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: CopyableLabel!
    
    @IBOutlet weak var passwordLabel: CopyableLabel!
}

final class AboutNameCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: CopyableLabel!
    
    @IBOutlet weak var dateLabel: CopyableLabel!
    
    @IBOutlet weak var buildVersionLabel: CopyableLabel!
    
    @IBOutlet weak var buildNumberLabel: CopyableLabel!
}
