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
import Predicate

final class VenueListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MessageEnabledViewController, IndicatorInfoProvider {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private(set) var internalVenueList = [VenueListItem]()
    private(set) var externalVenueList = [VenueListItem]()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(R.nib.tableViewHeaderViewDark(), forHeaderFooterViewReuseIdentifier: TableViewHeaderView.reuseIdentifier)
        
        reloadData()
    }
    
    // MARK: - Private Methods
    
    private func reloadData() {
        
        let summit = SummitManager.shared.summit.value
        
        let venues = try! VenueListItem.filter(#keyPath(VenueManagedObject.summit.id) == summit, context: Store.shared.managedObjectContext)
        
        internalVenueList = venues.filter({ $0.isInternal == true })
        externalVenueList = venues.filter({ $0.isInternal == false })
        
        tableView.reloadData()
    }
    
    private func configure(cell: VenueListTableViewCell, at indexPath: IndexPath) {
        
        let venue = externalVenueList[indexPath.row]
        cell.name = venue.name
        cell.address = venue.address
    }
    
    private func configure(cell: InternalVenueListTableViewCell, at indexPath: IndexPath) {
        
        let venue = internalVenueList[indexPath.row]
        cell.name = venue.name
        cell.address = venue.address
        cell.backgroundImage = venue.backgroundImage
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if section == VenueListSectionType.internal.rawValue {
            count = internalVenueList.count
        }
        else if section == VenueListSectionType.external.rawValue {
            count = externalVenueList.count
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == VenueListSectionType.internal.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.internalVenuesTableViewCell)!
            configure(cell: cell, at: indexPath)
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        }
        else if indexPath.section == VenueListSectionType.external.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.externalVenuesTableViewCell)!
            configure(cell: cell, at: indexPath)
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        }

        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = 88
        if indexPath.section == VenueListSectionType.internal.rawValue {
            height *= 2
        }
        return CGFloat(height)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let venue: VenueListItem
        
        guard let section = VenueListSectionType(rawValue: indexPath.section)
            else { fatalError("Invalid section \(indexPath.section)") }
        
        switch section {
        case .internal: venue = internalVenueList[indexPath.row]
        case .external: venue = externalVenueList[indexPath.row]
        }
        
        show(location: venue.identifier)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height = 0.01
        if section == VenueListSectionType.external.rawValue && externalVenueList.count > 0 {
            height = 45
        }
        return CGFloat(height)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(0.01)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == VenueListSectionType.external.rawValue {
            
            let headerView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: TableViewHeaderView.reuseIdentifier) as! TableViewHeaderView
            
            headerView.titleLabel.text = "EXTERNAL VENUES"
            
            return headerView
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Directory")
    }
}

// MARK: - Supporting Types

public enum VenueListSectionType: Int {
    
    case `internal`, external
}
