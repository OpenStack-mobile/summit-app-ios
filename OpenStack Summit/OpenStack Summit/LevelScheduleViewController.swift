//
//  LevelScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/9/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import CoreSummit

final class LevelScheduleViewController: ScheduleViewController {
    
    // MARK: - Properties
    
    var level: String!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(level != nil, "Level not set")
        
        self.title = level.uppercaseString
    }
    
    // MARK: - Methods
    
    override func scheduleAvailableDates(from startDate: NSDate, to endDate: NSDate) -> [NSDate] {
        
        let levels = [level!]
        let eventTypes = self.scheduleFilter.selections[FilterSectionType.EventType] as? [Int]
        let tracks = self.scheduleFilter.selections[FilterSectionType.Track] as? [Int]
        let trackGroups = self.scheduleFilter.selections[FilterSectionType.TrackGroup] as? [Int]
        let tags = self.scheduleFilter.selections[FilterSectionType.Tag] as? [String]
        
        let events = RealmSummitEvent.filter(startDate, endDate: endDate, eventTypes: eventTypes, tracks: tracks, trackGroups: trackGroups, tags: tags, levels: levels)
        
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
        
        let levels = [level!]
        let eventTypes = self.scheduleFilter.selections[FilterSectionType.EventType] as? [Int]
        let tracks = self.scheduleFilter.selections[FilterSectionType.Track] as? [Int]
        let trackGroups = self.scheduleFilter.selections[FilterSectionType.TrackGroup] as? [Int]
        let tags = self.scheduleFilter.selections[FilterSectionType.Tag] as? [String]
        
        let events = RealmSummitEvent.filter(startDate, endDate: endDate, eventTypes: eventTypes, tracks: tracks, trackGroups: trackGroups, tags: tags, levels: levels)
        
        return ScheduleItem.from(realm: events)
    }
}
