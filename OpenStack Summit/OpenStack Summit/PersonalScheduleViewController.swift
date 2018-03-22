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
import Foundation

final class PersonalScheduleViewController: ScheduleViewController, IndicatorInfoProvider {
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: - Methods
    
    override func scheduleActiveDates(from startDate: Date, to endDate: Date) -> [Date] {
        
        guard let member = Store.shared.authenticatedMember
            else { return [] }
        
        let events = member.schedule
            .sorted(by: { $0.start < $1.start })
            .filter({ $0.start >= startDate && $0.end <= endDate })
        
        var activeDates: [Date] = []
        
        for event in events {
            
            // no need to do timeZone adjustments
            // NSDate.mt_setTimeZone(timeZone) set on base class alters mt_startOfCurrentDay() calculation
            
            let date = (event.start as NSDate).mt_startOfCurrentDay()!
            
            if !activeDates.contains(date) {
                
                activeDates.append(date)
            }
        }
        
        return activeDates
    }
    
    override func scheduledEvents(_ filter: DateFilter) -> [ScheduleItem] {
        
        guard let member = Store.shared.authenticatedMember,
            case .interval(let interval) = filter
            else { return [] }
        
        let events = member.schedule
            .sorted(by: { $0.start < $1.start })
            .filter({ $0.start >= interval.start
                && $0.end <= interval.end })
        
        return ScheduleItem.from(managedObjects: events)
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Schedule")
    }
}
