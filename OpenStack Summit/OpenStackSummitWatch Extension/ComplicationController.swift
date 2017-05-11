//
//  ComplicationController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 10/24/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import WatchKit
import ClockKit
import Foundation
import CoreSummit

final class ComplicationController: NSObject, CLKComplicationDataSource {
    
    override init() {
        super.init()
        
        print("Initialized \(type(of: self))")
        
        #if DEBUG
        WKInterfaceDevice.current().play(.click) // haptic only for debugging
        #endif
        
        NotificationCenter.default.addObserver(self, selector: #selector(complicationServerActiveComplicationsDidChange), name: NSNotification.Name.CLKComplicationServerActiveComplicationsDidChange, object: self)
    }
    
    static func reloadComplications() {
        if let complications: [CLKComplication] = CLKComplicationServer.sharedInstance().activeComplications {
            if complications.count > 0 {
                for complication in complications {
                    CLKComplicationServer.sharedInstance().reloadTimeline(for: complication)
                    print("Reloading complication \(complication.description)...")
                }
                #if DEBUG
                WKInterfaceDevice.current().play(.click) // haptic only for debugging
                #endif
            }
        }
    }
    
    // MARK: - CLKComplicationDataSource
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        
        if Store.shared.cache != nil {
            
            handler([.backward, .forward])
            
        } else {
            
            handler(CLKComplicationTimeTravelDirections())
        }
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        
        handler(.showOnLockScreen)
    }
    
    func getNextRequestedUpdateDate(handler: @escaping (Date?) -> Void) {
        
        let entry = self.entry(for: Date())
        
        let date: Date
        
        switch entry {
            
        case .none:
            
            // Update hourly by default
            date = Date(timeIntervalSinceNow: 60*60)
            
        case let .multiple(_, _, end, _):
            
            // when current timeframe ends
            date = end
            
        case let .event(event):
            
            // when current event ends
            date = event.end
        }
        
        print("Next complication update date: \(date)")
        
        handler(date)
    }
    
    func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        
        let template = self.template(for: complication, with: .none)
        handler(template)
    }
        
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        
        let entry = self.entry(for: Date())
        
        print("Current timeline entry: \(entry)")
        
        let template = self.template(for: complication, with: entry)
        
        let complicationEntry = CLKComplicationTimelineEntry(date: entry.start ?? Date(), complicationTemplate: template)
        
        handler(complicationEntry)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before beforeDate: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        
        guard let summit = Store.shared.cache
            else { handler(nil); return }
        
        let date = beforeDate
        
        let dates = summit.dates(before: date, limit: limit)
        
        let entries = dates.map { ($0, self.entry(for: $0)) }
        
        print("Requesting \(limit) entries before \(beforeDate))")
        
        entries.forEach { print($0.0.description, $0.1) }
        
        let complicationEntries = entries.map { CLKComplicationTimelineEntry(date: $0.0, complicationTemplate: self.template(for: complication, with: $0.1)) }
        
        handler(complicationEntries)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after afterDate: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        
        guard let summit = Store.shared.cache
            else { handler(nil); return }
        
        let date = afterDate
        
        let dates = summit.dates(after: date, limit: limit)
        
        let entries = dates.map { ($0, self.entry(for: $0)) }
        
        print("Requesting \(limit) entries after \(afterDate))")
        
        entries.forEach { print($0.0.description, $0.1) }
        
        let complicationEntries = entries.map { CLKComplicationTimelineEntry(date: $0.0, complicationTemplate: self.template(for: complication, with: $0.1)) }
        
        handler(complicationEntries)
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        
        let date = Store.shared.cache?.schedule.sorted(by: { $0.0.start < $0.1.start }).first?.start
        
        print("Timeline Start Date: \(date?.description ?? "none")")
        
        handler(date)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        
        let date = Store.shared.cache?.schedule.sorted(by: { $0.0.start > $0.1.start }).first?.end
        
        print("Timeline End Date: \(date?.description ?? "none")")
        
        handler(date)
    }
    
    // MARK: - Private Methods
    
    private func template(for complication: CLKComplication, with entry: TimelineEntry) -> CLKComplicationTemplate {
        
        switch complication.family {
            
        case .utilitarianLarge:
            
            let complicationTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            
            let textProvider = CLKSimpleTextProvider()
            
            switch entry {
                
            case .none: textProvider.text = "No event"
                
            case let .multiple(events, start, end, timeZone):
                
                struct Static {
                    static let dateFormatter: DateFormatter = {
                        let formatter = DateFormatter()
                        formatter.dateStyle = .none
                        formatter.timeStyle = .short
                        return formatter
                    }()
                }
                
                Static.dateFormatter.timeZone = TimeZone(identifier: timeZone)
                
                let startDateText = Static.dateFormatter.string(from: start)
                
                let endDateText = Static.dateFormatter.string(from: end)
                
                textProvider.text = "\(startDateText) - \(endDateText) \(events) events"
                
            case let .event(event):
                
                textProvider.text = event.name
            }
            
            complicationTemplate.textProvider = textProvider
            
            return complicationTemplate
            
        case .modularLarge:
            
            switch entry {
                
            case .none:
                
                let complicationTemplate = CLKComplicationTemplateModularLargeTallBody()
                
                complicationTemplate.headerTextProvider = CLKSimpleTextProvider(text: "OpenStack Summit")
                
                complicationTemplate.bodyTextProvider = CLKSimpleTextProvider(text: "No event")
                
                return complicationTemplate
                
            case let .multiple(count, start, end, timeZone):
                
                let complicationTemplate = CLKComplicationTemplateModularLargeTallBody()
                
                complicationTemplate.headerTextProvider = CLKTimeIntervalTextProvider(start: start, end: end, timeZone: TimeZone(identifier: timeZone))
                
                complicationTemplate.bodyTextProvider = CLKSimpleTextProvider(text: "\(count) events")
                
                return complicationTemplate
                
            case let .event(event):
                
                let complicationTemplate = CLKComplicationTemplateModularLargeStandardBody()
                
                complicationTemplate.headerTextProvider = CLKTimeIntervalTextProvider(start: event.start, end: event.end, timeZone: TimeZone(identifier: event.timeZone))
                
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
            .sorted(by: { $0.0.start < $0.1.start })
        
        guard events.isEmpty == false
            else { return .none }
        
        // timeframe smallest and closest to requested date
        let startDate = events.first!.start
        let endDate = events.sorted(by: { $0.0.end < $0.1.end }).first!.end
        
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
    
    @objc private func complicationServerActiveComplicationsDidChange(_ notification: Foundation.Notification) {
        
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
        
        return schedule.reduce([Date](), {
            
            var newDates = $0.0
            
            if $0.0.contains($0.1.start) {
                
                newDates.append($0.1.start)
            }
            
            if $0.0.contains($0.1.end) {
                
                newDates.append($0.1.end)
            }
            
            return newDates
        })
        .sorted()
    }
    
    func dates(after date: Date, limit: Int = Int.max) -> [Date] {
        
        var dates = self.schedule.reduce([Date](), { $0.0 + [$0.1.start, $0.1.end] })
            .filter({ $0 > date })
        
        dates = dates.reduce([Date](), { $0.0.contains($0.1) ? $0.0 : $0.0 + [$0.1] }) // remove duplicates
            .prefix(limit)
            .sorted(by: { $0.0 > $0.1 })
        
        return dates
    }
    
    func dates(before date: Date, limit: Int = Int.max) -> [Date] {
        
        var dates = self.schedule.reduce([Date](), { $0.0 + [$0.1.start, $0.1.end] })
            .filter({ $0 < date })
        
        dates = dates.reduce([Date](), { $0.0.contains($0.1) ? $0.0 : $0.0 + [$0.1] }) // remove duplicates
            .prefix(limit)
            .sorted(by: { $0.0 < $0.1 })
        
        return dates
    }
}
