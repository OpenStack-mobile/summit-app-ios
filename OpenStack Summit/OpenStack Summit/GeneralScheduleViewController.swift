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
        
        loadData()
        
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
        
        if Store.shared.realm.objects(RealmSummit).isEmpty && Reachability.connected == false {
            
            self.toggleNoConnectivityMessage(true)
            self.toggleEventList(false)
            return
        }
        
        if let realmSummit = Store.shared.realm.objects(RealmSummit).first {
            
            let summit = Summit(realmEntity: realmSummit)
            
            // set user activity for handoff
            let userActivity = NSUserActivity(activityType: AppActivity.screen.rawValue)
            userActivity.title = "Summit Schedule"
            userActivity.webpageURL = NSURL(string: AppConfiguration[.WebsiteURL] + "/" + summit.webIdentifier + "/summit-schedule/")
            userActivity.userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.events.rawValue]
            
            self.userActivity = userActivity
        }
        
        self.toggleNoConnectivityMessage(false)
        self.toggleEventList(true)
        
        super.loadData()
    }
    
    override func scheduleAvailableDates(from startDate: NSDate, to endDate: NSDate) -> [NSDate] {
        
        let eventTypes = self.scheduleFilter.selections[FilterSectionType.EventType]?.rawValue as? [Int]
        let tracks = self.scheduleFilter.selections[FilterSectionType.Track]?.rawValue as? [Int]
        let trackGroups = self.scheduleFilter.selections[FilterSectionType.TrackGroup]?.rawValue as? [Int]
        let tags = self.scheduleFilter.selections[FilterSectionType.Tag]?.rawValue as? [String]
        let levels = self.scheduleFilter.selections[FilterSectionType.Level]?.rawValue as? [String]
        let venues = self.scheduleFilter.selections[FilterSectionType.Venue]?.rawValue as? [Int]
        
        let events = RealmSummitEvent.filter(startDate, endDate: endDate, eventTypes: eventTypes, tracks: tracks, trackGroups: trackGroups, tags: tags, levels: levels, venues: venues)
        
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
        
        let eventTypes = self.scheduleFilter.selections[FilterSectionType.EventType]?.rawValue as? [Int]
        let tracks = self.scheduleFilter.selections[FilterSectionType.Track]?.rawValue as? [Int]
        let trackGroups = self.scheduleFilter.selections[FilterSectionType.TrackGroup]?.rawValue as? [Int]
        let tags = self.scheduleFilter.selections[FilterSectionType.Tag]?.rawValue as? [String]
        let levels = self.scheduleFilter.selections[FilterSectionType.Level]?.rawValue as? [String]
        let venues = self.scheduleFilter.selections[FilterSectionType.Venue]?.rawValue as? [Int]
        
        let events = RealmSummitEvent.filter(startDate, endDate: endDate, eventTypes: eventTypes, tracks: tracks, trackGroups: trackGroups, tags: tags, levels: levels, venues: venues)
        
        return ScheduleItem.from(realm: events)
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Schedule")
    }
}
