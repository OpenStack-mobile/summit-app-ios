//
//  TrackScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftFoundation
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
        
        let scheduleFilter = FilterManager.shared.filter.value
        let summit = SummitManager.shared.summit.value
        
        let tracks = [self.track.identifier]
        let trackGroups = scheduleFilter.selections[FilterSectionType.TrackGroup]?.rawValue as? [Int]
        let tags = scheduleFilter.selections[FilterSectionType.Tag]?.rawValue as? [String]
        let levels = scheduleFilter.selections[FilterSectionType.Level]?.rawValue as? [String]
        let venues = scheduleFilter.selections[FilterSectionType.Venue]?.rawValue as? [Int]
        
        let date = DateFilter.interval(start: Date(foundation: startDate), end: Date(foundation: endDate))
        
        let events = try! EventManagedObject.filter(date, tracks: tracks, trackGroups: trackGroups, tags: tags, levels: levels, venues: venues, summit: summit, context: Store.shared.managedObjectContext)
        
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
        
        let scheduleFilter = FilterManager.shared.filter.value
        let summit = SummitManager.shared.summit.value
        
        let tracks = [self.track.identifier]
        let trackGroups = scheduleFilter.selections[FilterSectionType.TrackGroup]?.rawValue as? [Int]
        let tags = scheduleFilter.selections[FilterSectionType.Tag]?.rawValue as? [String]
        let levels = scheduleFilter.selections[FilterSectionType.Level]?.rawValue as? [String]
        let venues = scheduleFilter.selections[FilterSectionType.Venue]?.rawValue as? [Int]
        
        let events = try! EventManagedObject.filter(filter, tracks: tracks, trackGroups: trackGroups, tags: tags, levels: levels, venues: venues, summit: summit, context: Store.shared.managedObjectContext)
        
        return ScheduleItem.from(managedObjects: events)
    }
}
