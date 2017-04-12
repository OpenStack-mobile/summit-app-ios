//
//  FavoriteEventsViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/12/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CoreSummit
import SwiftFoundation

final class FavoriteEventsViewController: ScheduleViewController, IndicatorInfoProvider {
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: - Methods
    
    override func scheduleAvailableDates(from startDate: Foundation.Date, to endDate: Foundation.Date) -> [Foundation.Date] {
        
        guard let member = Store.shared.authenticatedMember
            else { return [] }
        
        let events = member.favoriteEvents
            .filter({ SwiftFoundation.Date(foundation: $0.start) >= SwiftFoundation.Date(foundation: startDate)
                && SwiftFoundation.Date(foundation: $0.end) <= SwiftFoundation.Date(foundation: endDate) })
            .sort({ SwiftFoundation.Date(foundation: $0.0.start) < SwiftFoundation.Date(foundation: $0.1.start) })
        
        var activeDates: [Foundation.Date] = []
        for event in events {
            let timeZone = NSTimeZone(name: event.summit.timeZone)!
            let startDate = event.start.mt_dateSecondsAfter(timeZone.secondsFromGMT).mt_startOfCurrentDay()
            if !activeDates.contains(startDate) {
                activeDates.append(startDate)
            }
            
        }
        return activeDates
    }
    
    override func scheduledEvents(_ filter: DateFilter) -> [ScheduleItem] {
        
        guard let member = Store.shared.authenticatedMember
            else { return [] }
        
        let events = member.favoriteEvents
            .filter({ SwiftFoundation.Date(foundation: $0.start) >= SwiftFoundation.Date(foundation: startDate)
                && SwiftFoundation.Date(foundation: $0.end) <= SwiftFoundation.Date(foundation: endDate) })
            .sort({ SwiftFoundation.Date(foundation: $0.0.start) < SwiftFoundation.Date(foundation: $0.1.start) })
        
        return ScheduleItem.from(managedObjects: events)
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(_ pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Watch List")
    }
}
