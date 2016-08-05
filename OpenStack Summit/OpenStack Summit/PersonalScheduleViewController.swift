//
//  PersonalScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CoreSummit

final class PersonalScheduleViewController: ScheduleViewController, IndicatorInfoProvider {
    
    // MARK: - Methods
    
    override func scheduleAvailableDates(from startDate: NSDate, to endDate: NSDate) -> [NSDate] {
        
        guard let attendeeRole = Store.shared.authenticatedMember?.attendeeRole
            else { return [] }
        
        let events = attendeeRole.scheduledEvents.filter("start >= %@ and end <= %@", startDate, endDate).sorted("start")
        
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
        
        guard let attendeeRole = Store.shared.authenticatedMember?.attendeeRole
            else { return [] }
        
        let realmEvents = attendeeRole.scheduledEvents.filter("start >= %@ and end <= %@", startDate, endDate).sorted("start")
        
        return ScheduleItem.from(realm: realmEvents)
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Schedule")
    }
}
