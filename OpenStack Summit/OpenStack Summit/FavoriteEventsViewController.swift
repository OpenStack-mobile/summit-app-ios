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
import Foundation

final class FavoriteEventsViewController: ScheduleViewController, IndicatorInfoProvider {
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: - Methods
    
    override func scheduleAvailableDates(from startDate: Date, to endDate: Date) -> [Date] {
        
        guard let member = Store.shared.authenticatedMember
            else { return [] }
        
        let events = member.favoriteEvents
            .filter({ $0.start >= startDate && $0.end <= endDate })
            .sorted(by: { $0.0.start < $0.1.start })
        
        var activeDates: [Date] = []
        for event in events {
            let timeZone = TimeZone(identifier: event.summit.timeZone)!
            let startDate = ((event.start as NSDate).mt_dateSeconds(after: timeZone.secondsFromGMT()) as NSDate).mt_startOfCurrentDay()!
            if !activeDates.contains(startDate) {
                activeDates.append(startDate)
            }
            
        }
        return activeDates
    }
    
    override func scheduledEvents(_ filter: DateFilter) -> [ScheduleItem] {
        
        guard let member = Store.shared.authenticatedMember,
            case .interval(let interval) = filter
            else { return [] }
        
        let events = member.favoriteEvents
            .filter({ $0.start >= interval.start && $0.end <= interval.end })
            .sorted(by: { $0.0.start < $0.1.start })
        
        return ScheduleItem.from(managedObjects: events)
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Watch List")
    }
}
