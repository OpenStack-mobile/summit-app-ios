//
//  TrackScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Foundation
import CoreSummit

final class TrackScheduleViewController: ScheduleViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var trackLabel: UILabel!
    
    // MARK: - Properties
    
    var track: Track!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(track != nil, "No track set")
        
        navigationItem.title = "TRACK"
        self.scheduleView.tableView.contentInset = UIEdgeInsetsMake(0, 0, 88, 0);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        trackLabel.text = track.name
    }
    
    // MARK: - Methods
    
    override func scheduleAvailableDates(from startDate: Date, to endDate: Date) -> [Date] {
        
        let scheduleFilter = FilterManager.shared.filter.value
        let summit = SummitManager.shared.summit.value
        
        let tracks = [self.track.identifier]
        var trackGroups = [Identifier]()
        var venues = [Identifier]()
        var levels = [Level]()
        
        for filter in scheduleFilter.activeFilters {
            
            switch filter {
            case let .trackGroup(identifier): trackGroups.append(identifier)
            case let .venue(identifier): venues.append(identifier)
            case let .level(level): levels.append(level)
            case .activeTalks: break
            }
        }
        
        let date = DateFilter.interval(start: startDate, end: endDate)
        
        let events = try! EventManagedObject.filter(date, tracks: tracks, trackGroups: trackGroups, levels: levels, venues: venues, summit: summit, context: Store.shared.managedObjectContext)
        
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
        
        let scheduleFilter = FilterManager.shared.filter.value
        let summit = SummitManager.shared.summit.value
        
        let tracks = [self.track.identifier]
        var trackGroups = [Identifier]()
        var venues = [Identifier]()
        var levels = [Level]()
        
        for filter in scheduleFilter.activeFilters {
            
            switch filter {
            case let .trackGroup(identifier): trackGroups.append(identifier)
            case let .venue(identifier): venues.append(identifier)
            case let .level(level): levels.append(level)
            case .activeTalks: break
            }
        }
        
        let events = try! EventManagedObject.filter(filter, tracks: tracks, trackGroups: trackGroups, levels: levels, venues: venues, summit: summit, context: Store.shared.managedObjectContext)
        
        return ScheduleItem.from(managedObjects: events)
    }
}
