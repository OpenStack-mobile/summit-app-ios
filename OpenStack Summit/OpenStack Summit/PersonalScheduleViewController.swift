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
import SwiftFoundation

final class PersonalScheduleViewController: ScheduleViewController, IndicatorInfoProvider {
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: - Methods
    
    override func scheduleAvailableDates(from startDate: NSDate, to endDate: NSDate) -> [NSDate] {
        
        guard let attendeeRole = Store.shared.authenticatedMember?.attendeeRole
            else { return [] }
        
        let events = attendeeRole.schedule
            .filter({ Date(foundation: $0.start) >= Date(foundation: startDate)
                && Date(foundation: $0.end) <= Date(foundation: endDate) })
            .sort({ Date(foundation: $0.0.start) < Date(foundation: $0.1.start) })
        
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
    
    override func scheduledEvents(filter: DateFilter) -> [ScheduleItem] {
        
        guard let attendeeRole = Store.shared.authenticatedMember?.attendeeRole
            else { return [] }
        
        let events = attendeeRole.schedule
            .filter({ Date(foundation: $0.start) >= Date(foundation: startDate)
                && Date(foundation: $0.end) <= Date(foundation: endDate) })
            .sort({ Date(foundation: $0.0.start) < Date(foundation: $0.1.start) })
        
        return ScheduleItem.from(managedObjects: events)
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Schedule")
    }
}
