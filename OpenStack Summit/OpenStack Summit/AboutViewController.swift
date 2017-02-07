//
//  AboutViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 4/6/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreSummit

final class AboutViewController: UITableViewController, RevealViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet var wirelessNetworksHeaderView: UIView!
    
    // MARK: - Properties
    
    private var sections = [Section]() = [.wirelessNetworks, .about]
    
    private var aboutCells = [AboutCell]() = [.name, .links, .description]
    
    private var wirelessNetworksFetchedResultsController: NSFetchedResultsController!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMenuButton()
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        
        configureView()
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        // wireless networks section
        
        let summitID = NSNumber(longLong: Int64(SummitManager.shared.summit.value))
        
        let predicate = NSPredicate(format: "summit.id == %@", summitID)
        
        let sort = [NSSortDescriptor(key: "name", ascending: true)]
        
        self.fetchedResultsController = NSFetchedResultsController.init(WirelessNetwork.self,
                                                                        delegate: self,
                                                                        predicate: predicate,
                                                                        sortDescriptors: sort,
                                                                        context: Store.shared.managedObjectContext)
        
        try! self.fetchedResultsController.performFetch()
        
        // setup sections
        
        sections = []
        
        if
        
        
        
        self.tableView.reloadData()
    }
    
    private subscript (wirelessNetwork row: Int) -> WirelessNetwork {
        
        let managedObject = self.fetchedResultsController.fetchedObjects![row] as! WirelessNetwork.ManagedObject
        
        return WirelessNetwork(managedObject: managedObject)
    }
    
    @inline(__always)
    private func configure(cell cell: WirelessNetworkCell, at row: Int) {
        
        let network = self[wirelessNetwork: row]
        
        cell.nameLabel.text = network.name
        
        cell.passwordLabel.text = network.password
    }
    
    @inline(__always)
    private func configure(cell cell: AboutNameCell) {
        
        cell.nameLabel.text =
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let section = sections[indexPath.section]
        
        switch section {
            
        case .wirelessNetworks:
            
            return wirelessNetworksFetchedResultsController?.fetchedObjects?.count ?? 0
            
        case .about:
            
            return aboutCells.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let section = sections[indexPath.section]
        
        switch section {
            
        case .wirelessNetworks:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.wirelessNetworkCell, atIndexPath: indexPath)!
            
            configure(cell: cell, at: indexPath)
            
            return cell
            
        case .about:
            
            let data = aboutCells[indexPath.row]
            
            switch data {
                
            case .name:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.aboutNameCell, atIndexPath: indexPath)!
                
                cell
                
            case .links:
                
                
                
            case .description:
                
                
            }
        }
    }
}

// MARK: - Supporting Types

private extension AboutViewController {
    
    enum Section {
        
        case wirelessNetworks
        case about
    }
    
    enum AboutCell {
        
        case name
        case links
        case description
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

// MARK: - Legacy

final class OldAboutViewController: UIViewController, RevealViewController {

    // MARK: - IB Outlets
    
    @IBOutlet weak var summitTextLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var buildNumberLabel: UILabel!
    @IBOutlet weak var nameAndDateLabel: UILabel!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMenuButton()
        
        nameAndDateLabel.text = buildNameDate()
        versionLabel.text = "Version \(AppVersion)"
        buildNumberLabel.text = "Build Number \(AppBuild)"
        
        navigationItem.title = "ABOUT"
        summitTextLabel.sizeToFit()
        
        // set user activity for handoff
        let userActivity = NSUserActivity(activityType: AppActivity.screen.rawValue)
        userActivity.title = "About the Summit"
        userActivity.webpageURL = NSURL(string: AppEnvironment.configuration.webpageURL)
        userActivity.userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.about.rawValue]
        
        self.userActivity = userActivity
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        userActivity?.becomeCurrent()
        
        let webpageURL: NSURL
        
        if let summit = try! Store.shared.managedObjectContext.managedObjects(SummitManagedObject.self).first {
            
            webpageURL = NSURL(string: summit.webpageURL)!
            
        } else {
            
            webpageURL = NSURL(string: AppEnvironment.configuration.webpageURL)!
        }
        
        userActivity?.webpageURL = webpageURL
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if #available(iOS 9.0, *) {
            userActivity?.resignCurrent()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func websiteTouch(sender: AnyObject) {
        let url = NSURL(string: "https://openstack.org")!
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func codeOfConductTouch(sender: AnyObject) {
        let url = NSURL(string: "https://www.openstack.org/summit/barcelona-2016/code-of-conduct")!
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    // MARK: - Private Methods
    
    private func buildNameDate() -> String {
        
        guard let summit = self.currentSummit
            else { return "" }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: summit.timeZone)
        dateFormatter.dateFormat = "MMMM dd-"
        let stringDateFrom = dateFormatter.stringFromDate(summit.start)
        
        dateFormatter.dateFormat = "dd, yyyy"
        let stringDateTo = dateFormatter.stringFromDate(summit.end)
        
        return "\(summit.name) - \(stringDateFrom)\(stringDateTo)"
    }
}
