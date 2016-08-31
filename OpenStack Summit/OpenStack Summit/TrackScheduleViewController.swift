//
//  TrackScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import CoreSummit

final class TrackScheduleViewController: ScheduleViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var trackLabel: UILabel!
    
    // MARK: - Properties
    
    var track: Track!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(track != nil, "No track set")
        
        navigationItem.title = "TRACK"
        self.scheduleView.tableView.contentInset = UIEdgeInsetsMake(0, 0, 88, 0);
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        trackLabel.text = track.name
    }
    
    // MARK: - Methods
    
    override func scheduleAvailableDates(from startDate: NSDate, to endDate: NSDate) -> [NSDate] {
        
        let tracks = [self.track.identifier]
        let eventTypes = self.scheduleFilter.selections[FilterSectionType.EventType]?.rawValue as? [Int]
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
        
        let tracks = [self.track.identifier]
        let eventTypes = self.scheduleFilter.selections[FilterSectionType.EventType]?.rawValue as? [Int]
        let trackGroups = self.scheduleFilter.selections[FilterSectionType.TrackGroup]?.rawValue as? [Int]
        let tags = self.scheduleFilter.selections[FilterSectionType.Tag]?.rawValue as? [String]
        let levels = self.scheduleFilter.selections[FilterSectionType.Level]?.rawValue as? [String]
        let venues = self.scheduleFilter.selections[FilterSectionType.Venue]?.rawValue as? [Int]
        
        let realmEvents = RealmSummitEvent.filter(startDate, endDate: endDate, eventTypes: eventTypes, tracks: tracks, trackGroups: trackGroups, tags: tags, levels: levels, venues: venues)
        
        return ScheduleItem.from(realm: realmEvents)
    }
}
