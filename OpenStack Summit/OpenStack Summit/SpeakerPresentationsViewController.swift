//
//  SpeakerPresentationsViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/21/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CoreSummit

final class SpeakerPresentationsViewController: ScheduleViewController, IndicatorInfoProvider {
    
    // MARK: - Properties
    
    // Required for view loading
    var speaker: Identifier!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(speaker != nil, "Speaker identifier not set")
    }
    
    // MARK: - Methods
    
    override func scheduleAvailableDates(from startDate: Date, to endDate: Date) -> [Date] {
        
        let summit = SummitManager.shared.summit.value
        
        let events = try! EventManagedObject.presentations(for: speaker, start: startDate, end: endDate, summit: summit, context: Store.shared.managedObjectContext)
        
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
        
        guard case .interval(let interval) = filter
            else { return [] }
        
        let summit = SummitManager.shared.summit.value
        
        let managedObjects = try! EventManagedObject.presentations(for: speaker, start: interval.start, end: interval.end, summit: summit, context: Store.shared.managedObjectContext)
        
        return ScheduleItem.from(managedObjects: managedObjects)
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Sessions")
    }
}
