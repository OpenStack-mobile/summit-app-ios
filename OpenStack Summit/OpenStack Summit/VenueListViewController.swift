//
//  VenueListViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CoreSummit

final class VenueListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MessageEnabledViewController, IndicatorInfoProvider {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private(set) var internalVenueList = [VenueListItem]()
    private(set) var externalVenueList = [VenueListItem]()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(R.nib.tableViewHeaderViewDark(), forHeaderFooterViewReuseIdentifier: TableViewHeaderView.reuseIdentifier)
        
        reloadData()
    }
    
    // MARK: - Private Methods
    
    private func reloadData() {
        
        let summit = SummitManager.shared.summit.value
        
        let venues = try! VenueListItem.filter("summit.id" == summit, context: Store.shared.managedObjectContext)
        
        internalVenueList = venues.filter({ $0.isInternal == true })
        externalVenueList = venues.filter({ $0.isInternal == false })
        
        tableView.reloadData()
    }
    
    private func configure(cell cell: VenueListTableViewCell, at indexPath: NSIndexPath) {
        
        let venue = externalVenueList[indexPath.row]
        cell.name = venue.name
        cell.address = venue.address
    }
    
    private func configure(cell cell: InternalVenueListTableViewCell, at indexPath: NSIndexPath) {
        
        let venue = internalVenueList[indexPath.row]
        cell.name = venue.name
        cell.address = venue.address
        cell.backgroundImageURL = venue.backgroundImageURL ?? ""
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if section == VenueListSectionType.Internal.rawValue {
            count = internalVenueList.count
        }
        else if section == VenueListSectionType.External.rawValue {
            count = externalVenueList.count
        }
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == VenueListSectionType.Internal.rawValue {
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.internalVenuesTableViewCell)!
            configure(cell: cell, at: indexPath)
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        }
        else if indexPath.section == VenueListSectionType.External.rawValue {
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.externalVenuesTableViewCell)!
            configure(cell: cell, at: indexPath)
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        }

        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = 88
        if indexPath.section == VenueListSectionType.Internal.rawValue {
            height *= 2
        }
        return CGFloat(height)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let venue: VenueListItem
        
        guard let section = VenueListSectionType(rawValue: indexPath.section)
            else { fatalError("Invalid section \(indexPath.section)") }
        
        switch section {
        case .Internal: venue = internalVenueList[indexPath.row]
        case .External: venue = externalVenueList[indexPath.row]
        }
        
        showLocationDetail(venue.identifier)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height = 0.01
        if section == VenueListSectionType.External.rawValue && externalVenueList.count > 0 {
            height = 45
        }
        return CGFloat(height)
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(0.01)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == VenueListSectionType.External.rawValue {
            
            let headerView = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier(TableViewHeaderView.reuseIdentifier) as! TableViewHeaderView
            
            headerView.titleLabel.text = "EXTERNAL VENUES"
            
            return headerView
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Directory")
    }
}

// MARK: - Supporting Types

public enum VenueListSectionType: Int {
    
    case Internal, External
}
