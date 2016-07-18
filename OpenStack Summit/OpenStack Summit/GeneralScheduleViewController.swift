//
//  GeneralScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/3/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//


import UIKit
import XLPagerTabStrip
import SwiftSpinner
import CoreSummit

final class GeneralScheduleViewController: ScheduleViewController, ScheduleFilterViewController, IndicatorInfoProvider {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var noConnectivityView: UIView!
    
    @IBOutlet weak var retryButton: UIButton!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    // MARK: - Actions
    
    @IBAction func retryButtonPressed(sender: UIButton) {
        
        loadData()
    }
    
    // MARK: - Methods
    
    override func toggleEventList(show: Bool) {
        
        scheduleView.hidden = !show
    }
    
    override func toggleNoConnectivityMessage(show: Bool) {
        
        noConnectivityView.hidden = !show
    }
    
    internal override func loadData() {
        
        if !scheduleFilter.hasToRefreshSchedule {
            return
        }
        
        scheduleFilter.hasToRefreshSchedule = false
        
        if Store.shared.realm.objects(RealmSummit).isEmpty && Reachability.connected == false {
            
            self.toggleNoConnectivityMessage(true)
            self.toggleEventList(false)
            return
        }
        
        self.toggleNoConnectivityMessage(false)
        self.toggleEventList(true)
        
        self.checkForClearDataEvents()
        
        super.loadData()
    }
    
    override func scheduleAvailableDates(from startDate: NSDate, to endDate: NSDate) -> [NSDate] {
        
        let eventTypes = self.scheduleFilter.selections[FilterSectionType.EventType] as? [Int]
        let summitTypes = self.scheduleFilter.selections[FilterSectionType.SummitType] as? [Int]
        let tracks = self.scheduleFilter.selections[FilterSectionType.Track] as? [Int]
        let trackGroups = self.scheduleFilter.selections[FilterSectionType.TrackGroup] as? [Int]
        let tags = self.scheduleFilter.selections[FilterSectionType.Tag] as? [String]
        let levels = self.scheduleFilter.selections[FilterSectionType.Level] as? [String]
        
        let events = RealmSummitEvent.filter(startDate, endDate: endDate, eventTypes: eventTypes, summitTypes: summitTypes, tracks: tracks, trackGroups: trackGroups, tags: tags, levels: levels)
        
        var activeDates: [NSDate] = []
        for event in events {
            let timeZone = NSTimeZone(name: event.summit.timeZone)!
            let startDate = event.start.mt_dateSecondsAfter(timeZone.secondsFromGMT).mt_startOfCurrentDay()
            if !activeDates.contains(startDate) {
                activeDates.append(startDate)
            }
            
        }
        return activeDates
    }
    
    override func scheduledEvents(from startDate: NSDate, to endDate: NSDate) -> [ScheduleItem] {
        
        let eventTypes = self.scheduleFilter.selections[FilterSectionType.EventType] as? [Int]
        let summitTypes = self.scheduleFilter.selections[FilterSectionType.SummitType] as? [Int]
        let tracks = self.scheduleFilter.selections[FilterSectionType.Track] as? [Int]
        let trackGroups = self.scheduleFilter.selections[FilterSectionType.TrackGroup] as? [Int]
        let tags = self.scheduleFilter.selections[FilterSectionType.Tag] as? [String]
        let levels = self.scheduleFilter.selections[FilterSectionType.Level] as? [String]
        
        let events = RealmSummitEvent.filter(startDate, endDate: endDate, eventTypes: eventTypes, summitTypes: summitTypes, tracks: tracks, trackGroups: trackGroups, tags: tags, levels: levels)
        
        return ScheduleItem.from(realm: events)
    }
    
    // MARK: - Private Methods
    
    @inline(__always)
    private func checkForClearDataEvents() {
        
        //dataUpdatePoller.clearDataIfTruncateEventExist()
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Schedule")
    }
}
