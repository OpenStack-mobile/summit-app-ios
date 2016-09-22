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
        
        let scheduleFilter = FilterManager.shared.filter.value
        
        let levels = [level!]
        let eventTypes = scheduleFilter.selections[FilterSectionType.EventType]?.rawValue as? [Int]
        let tracks = scheduleFilter.selections[FilterSectionType.Track]?.rawValue as? [Int]
        let trackGroups = scheduleFilter.selections[FilterSectionType.TrackGroup]?.rawValue as? [Int]
        let tags = scheduleFilter.selections[FilterSectionType.Tag]?.rawValue as? [String]
        let venues = scheduleFilter.selections[FilterSectionType.Venue]?.rawValue as? [Int]
        
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
        
        let scheduleFilter = FilterManager.shared.filter.value
        
        let levels = [level!]
        let eventTypes = scheduleFilter.selections[FilterSectionType.EventType]?.rawValue as? [Int]
        let tracks = scheduleFilter.selections[FilterSectionType.Track]?.rawValue as? [Int]
        let trackGroups = scheduleFilter.selections[FilterSectionType.TrackGroup]?.rawValue as? [Int]
        let tags = scheduleFilter.selections[FilterSectionType.Tag]?.rawValue as? [String]
        let venues = scheduleFilter.selections[FilterSectionType.Venue]?.rawValue as? [Int]
        
        let events = RealmSummitEvent.filter(startDate, endDate: endDate, eventTypes: eventTypes, tracks: tracks, trackGroups: trackGroups, tags: tags, levels: levels, venues: venues)
        
        return ScheduleItem.from(realm: events)
    }
}
