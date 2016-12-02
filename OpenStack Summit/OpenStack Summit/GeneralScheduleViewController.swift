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

final class GeneralScheduleViewController: ScheduleViewController, IndicatorInfoProvider {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var noConnectivityView: UIView!
    
    @IBOutlet weak var retryButton: UIButton!
    
    // MARK: - Loading
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        userActivity?.becomeCurrent()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if #available(iOS 9.0, *) {
            userActivity?.resignCurrent()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func retryButtonPressed(sender: UIButton) {
        
        loadData()
    }
    
    // MARK: - Methods
    
    override func toggleEventList(show: Bool) {
        
        scheduleView!.hidden = !show
    }
    
    override func toggleNoConnectivityMessage(show: Bool) {
        
        noConnectivityView!.hidden = !show
    }
    
    internal override func loadData() {
        
        if try! Store.shared.managedObjectContext.managedObjects(Summit).isEmpty
            && Reachability.connected == false {
            
            self.toggleNoConnectivityMessage(true)
            self.toggleEventList(false)
            return
        }
        
        if let summit = self.currentSummit {
            
            // set user activity for handoff
            let userActivity = NSUserActivity(activityType: AppActivity.screen.rawValue)
            userActivity.title = "Summit Schedule"
            userActivity.webpageURL = NSURL(string: summit.webpageURL + "/summit-schedule")
            userActivity.userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.events.rawValue]
            
            self.userActivity = userActivity
        }
        
        self.toggleNoConnectivityMessage(false)
        self.toggleEventList(true)
        
        super.loadData()
    }
    
    override func scheduleAvailableDates(from startDate: NSDate, to endDate: NSDate) -> [NSDate] {
        
        let scheduleFilter = FilterManager.shared.filter.value
        let summit = SummitManager.shared.summit.value
        
        let tracks = scheduleFilter.selections[FilterSectionType.Track]?.rawValue as? [Int]
        let trackGroups = scheduleFilter.selections[FilterSectionType.TrackGroup]?.rawValue as? [Int]
        let tags = scheduleFilter.selections[FilterSectionType.Tag]?.rawValue as? [String]
        let levels = scheduleFilter.selections[FilterSectionType.Level]?.rawValue as? [String]
        let venues = scheduleFilter.selections[FilterSectionType.Venue]?.rawValue as? [Int]
        
        let events = try! EventManagedObject.filter(startDate, endDate: endDate, tracks: tracks, trackGroups: trackGroups, tags: tags, levels: levels, venues: venues, summit: summit, context: Store.shared.managedObjectContext)
        
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
        
        let scheduleFilter = FilterManager.shared.filter.value
        let summit = SummitManager.shared.summit.value
        
        let tracks = scheduleFilter.selections[FilterSectionType.Track]?.rawValue as? [Int]
        let trackGroups = scheduleFilter.selections[FilterSectionType.TrackGroup]?.rawValue as? [Int]
        let tags = scheduleFilter.selections[FilterSectionType.Tag]?.rawValue as? [String]
        let levels = scheduleFilter.selections[FilterSectionType.Level]?.rawValue as? [String]
        let venues = scheduleFilter.selections[FilterSectionType.Venue]?.rawValue as? [Int]
        
        let events = try! EventManagedObject.filter(startDate, endDate: endDate, tracks: tracks, trackGroups: trackGroups, tags: tags, levels: levels, venues: venues, summit: summit, context: Store.shared.managedObjectContext)
        
        return ScheduleItem.from(managedObjects: events)
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Schedule")
    }
}
