//
//  SpeakerPresentationsViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/21/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftSpinner
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
    
    override func scheduleAvailableDates(from startDate: NSDate, to endDate: NSDate) -> [NSDate] {
        
        let events = RealmSummitEvent.speakerPresentations(speaker, startDate: startDate, endDate: endDate)
        
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
        
        let realmEvents = RealmSummitEvent.speakerPresentations(speaker, startDate: startDate, endDate: endDate)
        
        return ScheduleItem.from(realm: realmEvents)
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Sessions")
    }
}