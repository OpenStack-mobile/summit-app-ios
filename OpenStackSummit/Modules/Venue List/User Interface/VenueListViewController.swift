//
//  VenueListViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip

public enum VenueListSectionType: Int {
    case Internal, External
}

@objc
public protocol IVenueListViewController: IMessageEnabledViewController {
    func reloadList()
}

class VenueListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, IVenueListViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var tableView: UITableView!
    
    let tableViewHeaderCellIdentifier = "tableViewHeaderCell"
    let internalVenuesTableViewCellIdentifier = "internalVenuesTableViewCell"
    let externalVenuesTableViewCellIdentifier = "externalVenuesTableViewCell"
    
    var presenter : IVenueListPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: tableViewHeaderCellIdentifier)
        
        presenter.viewLoad()
    }
    
    func reloadList() {
        tableView.rowHeight = 120
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height = 0.01
        if section == VenueListSectionType.External.rawValue && presenter.getExternalVenuesCount() > 0 {
            height = 45
        }
        return CGFloat(height)
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(0.01)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == VenueListSectionType.External.rawValue {
            let cell = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier(tableViewHeaderCellIdentifier)
            let header = cell as! TableViewHeaderView
            header.titleLabel.text = "EXTERNAL VENUES"
            return cell
        }
        return nil
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if section == VenueListSectionType.Internal.rawValue {
            count = presenter.getInternalVenuesCount()
        }
        else if section == VenueListSectionType.External.rawValue {
            count = presenter.getExternalVenuesCount()
        }
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == VenueListSectionType.Internal.rawValue {
            let cell = tableView.dequeueReusableCellWithIdentifier(internalVenuesTableViewCellIdentifier, forIndexPath: indexPath) as! VenueListTableViewCell
            presenter.buildInternalVenueCell(cell, index: indexPath.row)
            return cell
        }
        else if indexPath.section == VenueListSectionType.External.rawValue {
            let cell = tableView.dequeueReusableCellWithIdentifier(externalVenuesTableViewCellIdentifier, forIndexPath: indexPath) as! VenueListTableViewCell
            presenter.buildExternalVenueCell(cell, index: indexPath.row)
            return cell
        }

        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        if indexPath.section == VenueListSectionType.Internal.rawValue {
            presenter.showInternalVenueDetail(indexPath.row)
        }
        else if indexPath.section == VenueListSectionType.External.rawValue {
            presenter.showExternalVenueDetail(indexPath.row)
        }
    }
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Directory")
    }
}
