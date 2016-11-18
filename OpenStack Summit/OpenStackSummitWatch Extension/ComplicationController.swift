//
//  ComplicationController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 10/24/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import WatchKit
import ClockKit
import SwiftFoundation
import CoreSummit

final class ComplicationController: NSObject, CLKComplicationDataSource {
    
    override init() {
        super.init()
        
        print("Initialized \(self.dynamicType)")
        
        #if DEBUG
        WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Click) // haptic only for debugging
        #endif
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(complicationServerActiveComplicationsDidChange), name: CLKComplicationServerActiveComplicationsDidChangeNotification, object: self)
    }
    
    static func reloadComplications() {
        if let complications: [CLKComplication] = CLKComplicationServer.sharedInstance().activeComplications {
            if complications.count > 0 {
                for complication in complications {
                    CLKComplicationServer.sharedInstance().reloadTimelineForComplication(complication)
                    print("Reloading complication \(complication.description)...")
                }
                #if DEBUG
                WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Click) // haptic only for debugging
                #endif
            }
        }
    }
    
    // MARK: - CLKComplicationDataSource
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        
        if Store.shared.cache != nil {
            
            handler([.Backward, .Forward])
            
        } else {
            
            handler(.None)
        }
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        
        handler(.ShowOnLockScreen)
    }
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        
        let entry = self.entry(for: Date())
        
        let date: NSDate
        
        switch entry {
            
        case .none:
            
            // Update hourly by default
            date = NSDate(timeIntervalSinceNow: 60*60)
            
        case let .multiple(_, _, end, _):
            
            // when current timeframe ends
            date = end.toFoundation()
            
        case let .event(event):
            
            // when current event ends
            date = event.end.toFoundation()
        }
        
        print("Next complication update date: \(date)")
        
        handler(date)
    }
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        
        let template = self.template(for: complication, with: .none)
        handler(template)
    }
        
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimelineEntry?) -> Void) {
        
        let entry = self.entry(for: Date())
        
        print("Current timeline entry: \(entry)")
        
        let template = self.template(for: complication, with: entry)
        
        let complicationEntry = CLKComplicationTimelineEntry(date: entry.start?.toFoundation() ?? NSDate(), complicationTemplate: template)
        
        handler(complicationEntry)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate: NSDate, limit: Int, withHandler handler: ([CLKComplicationTimelineEntry]?) -> Void) {
        
        guard let summit = Store.shared.cache
            else { handler(nil); return }
        
        let date = Date(foundation: beforeDate)
        
        let dates = summit.dates(before: date, limit: limit)
        
        let entries = dates.map { ($0, self.entry(for: $0)) }
        
        print("Requesting \(limit) entries before \(beforeDate))")
        
        entries.forEach { print($0.0.toFoundation().description, $0.1) }
        
        let complicationEntries = entries.map { CLKComplicationTimelineEntry(date: $0.0.toFoundation(), complicationTemplate: self.template(for: complication, with: $0.1)) }
        
        handler(complicationEntries)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate: NSDate, limit: Int, withHandler handler: ([CLKComplicationTimelineEntry]?) -> Void) {
        
        guard let summit = Store.shared.cache
            else { handler(nil); return }
        
        let date = Date(foundation: afterDate)
        
        let dates = summit.dates(after: date, limit: limit)
        
        let entries = dates.map { ($0, self.entry(for: $0)) }
        
        print("Requesting \(limit) entries after \(afterDate))")
        
        entries.forEach { print($0.0.toFoundation().description, $0.1) }
        
        let complicationEntries = entries.map { CLKComplicationTimelineEntry(date: $0.0.toFoundation(), complicationTemplate: self.template(for: complication, with: $0.1)) }
        
        handler(complicationEntries)
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        
        let date = Store.shared.cache?.schedule.sort({ $0.0.start < $0.1.start }).first?.start.toFoundation()
        
        print("Timeline Start Date: \(date)")
        
        handler(date)
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        
        let date = Store.shared.cache?.schedule.sort({ $0.0.start > $0.1.start }).first?.end.toFoundation()
        
        print("Timeline End Date: \(date)")
        
        handler(date)
    }
    
    // MARK: - Private Methods
    
    private func template(for complication: CLKComplication, with entry: TimelineEntry) -> CLKComplicationTemplate {
        
        switch complication.family {
            
        case .UtilitarianLarge:
            
            let complicationTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            
            let textProvider = CLKSimpleTextProvider()
            
            switch entry {
                
            case .none: textProvider.text = "No event"
                
            case let .multiple(events, start, end, timeZone):
                
                struct Static {
                    static let dateFormatter: NSDateFormatter = {
                        let formatter = NSDateFormatter()
                        formatter.dateStyle = .NoStyle
                        formatter.timeStyle = .ShortStyle
                        return formatter
                    }()
                }
                
                Static.dateFormatter.timeZone = NSTimeZone(name: timeZone)
                
                let startDateText = Static.dateFormatter.stringFromDate(start.toFoundation())
                
                let endDateText = Static.dateFormatter.stringFromDate(end.toFoundation())
                
                textProvider.text = "\(startDateText) - \(endDateText) \(events) events"
                
            case let .event(event):
                
                textProvider.text = event.name
            }
            
            complicationTemplate.textProvider = textProvider
            
            return complicationTemplate
            
        case .ModularLarge:
            
            switch entry {
                
            case .none:
                
                let complicationTemplate = CLKComplicationTemplateModularLargeTallBody()
                
                complicationTemplate.headerTextProvider = CLKSimpleTextProvider(text: "OpenStack Summit")
                
                complicationTemplate.bodyTextProvider = CLKSimpleTextProvider(text: "No event")
                
                return complicationTemplate
                
            case let .multiple(count, start, end, timeZone):
                
                let complicationTemplate = CLKComplicationTemplateModularLargeTallBody()
                
                complicationTemplate.headerTextProvider = CLKTimeIntervalTextProvider(startDate: start.toFoundation(), endDate: end.toFoundation(), timeZone: NSTimeZone(name: timeZone))
                
                complicationTemplate.bodyTextProvider = CLKSimpleTextProvider(text: "\(count) events")
                
                return complicationTemplate
                
            case let .event(event):
                
                let complicationTemplate = CLKComplicationTemplateModularLargeStandardBody()
                
                complicationTemplate.headerTextProvider = CLKTimeIntervalTextProvider(startDate: event.start.toFoundation(), endDate: event.end.toFoundation(), timeZone: NSTimeZone(name: event.timeZone))
                
                complicationTemplate.body1TextProvider = CLKSimpleTextProvider(text: event.name)
                
                complicationTemplate.body2TextProvider = CLKSimpleTextProvider(text: event.location)
                
                return complicationTemplate
            }
            
        default: fatalError("Complication family \(complication.family.rawValue) not supported")
        }
    }
    
    private func entry(for date: Date) -> TimelineEntry {
        
        guard let summit = Store.shared.cache
            else { return .none }
        
        // make sure date is one of the timeline dates before the current date
        let timelineDates = summit.timelineDates
        let date = timelineDates.filter({ $0 <= date }).first ?? date
        
        // get sorted events
        var events = summit.schedule
            .filter({ $0.start >= date }) // only events that start after the specified date
            .sort({ $0.0.start < $0.1.start })
        
        guard events.isEmpty == false
            else { return .none }
        
        // timeframe smallest and closest to requested date
        let startDate = events.first!.start
        let endDate = events.sort({ $0.0.end < $0.1.end }).first!.end
        
        // get events that are within the timeframe
        events = summit.schedule.filter { $0.start <= startDate && $0.end >= endDate }
        assert(events.isEmpty == false, "Should never filter out all events, revise algorithm.")
        
        // multiple events
        if events.count > 1 {
            
            return .multiple(events.count, startDate, endDate, summit.timeZone)
            
        } else {
            
            return .event(EventDetail(event: events.first!, summit: summit))
        }
    }
    
    // MARK: - Notifications
    
    @objc private func complicationServerActiveComplicationsDidChange(notification: NSNotification) {
        
        ComplicationController.reloadComplications()
    }
}

extension ComplicationController {
    
    enum TimelineEntry {
        
        /// No Event
        case none
        
        /// Multiple Events, with the date of the earliest one and time zone.
        case multiple(Int, Date, Date, String)
        
        /// A single event
        case event(EventDetail)
        
        var start: Date? {
            
            switch self {
            case .none: return nil
            case let .multiple(_, start, _, _): return start
            case let .event(event): return event.start
            }
        }
    }
    
    struct EventDetail {
        
        let identifier: Identifier
        let name: String
        let start: Date
        let end: Date
        let location: String
        let timeZone: String
        
        init(event: Event, summit: Summit) {
            
            self.identifier = event.identifier
            self.name = event.name
            self.start = event.start
            self.end = event.end
            self.location = OpenStackSummitWatch_Extension.EventDetail.getLocation(event, summit: summit)
            self.timeZone = summit.timeZone
        }
    }
}

// MARK: - Model Extensions

extension Summit {
    
    var timelineDates: [Date] {
        
        return schedule.reduce([Date](), combine: {
            
            var newDates = $0.0
            
            if $0.0.contains($0.1.start) {
                
                newDates.append($0.1.start)
            }
            
            if $0.0.contains($0.1.end) {
                
                newDates.append($0.1.end)
            }
            
            return newDates
        })
        .sort()
    }
    
    func dates(after date: Date, limit: Int = Int.max) -> [Date] {
        
        var dates = self.schedule.reduce([Date](), combine: { $0.0 + [$0.1.start, $0.1.end] })
            .filter({ $0 > date })
        
        dates = dates.reduce([Date](), combine: { $0.0.contains($0.1) ? $0.0 : $0.0 + [$0.1] }) // remove duplicates
            .prefix(limit)
            .sort({ $0.0 > $0.1 })
        
        return dates
    }
    
    func dates(before date: Date, limit: Int = Int.max) -> [Date] {
        
        var dates = self.schedule.reduce([Date](), combine: { $0.0 + [$0.1.start, $0.1.end] })
            .filter({ $0 < date })
        
        dates = dates.reduce([Date](), combine: { $0.0.contains($0.1) ? $0.0 : $0.0 + [$0.1] }) // remove duplicates
            .prefix(limit)
            .sort({ $0.0 < $0.1 })
        
        return dates
    }
}
