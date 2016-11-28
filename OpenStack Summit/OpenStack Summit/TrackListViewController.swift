//
//  TrackListViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CoreSummit

final class TrackListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, IndicatorInfoProvider {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Private Properties
    
    private var tracks = [Track]()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // solves custom navigation issues
        tableView.delegate = self
        tableView.dataSource = self
        
        reloadData()
    }
    
    // MARK: - Private Methods
    
    private func reloadData() {
        
        let scheduleFilter = FilterManager.shared.filter.value
        
        let trackGroupSelections = scheduleFilter.selections[FilterSectionType.TrackGroup]?.rawValue as! [Int]
        
        tracks = try! Track.`for`(groups: trackGroupSelections, context: Store.shared.managedObjectContext)
        
        tableView.reloadData()
    }
    
    private func configure(cell cell: TrackTableViewCell, at indexPath: NSIndexPath) {
        
        let track = tracks[indexPath.row]
        
        cell.nameLabel.text = track.name
        
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsZero
    }
    
    // MARK: - UITableViewDataSource
        
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tracks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.trackTableViewCell, forIndexPath: indexPath)!
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let track = tracks[indexPath.row]
        
        let trackScheduleVC = R.storyboard.schedule.trackScheduleViewController()!
        
        trackScheduleVC.track = track
                
        self.showViewController(trackScheduleVC, sender: self)
    }
    
    // MARK: - IndicatorInfoProvider

    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Tracks")
    }
}
