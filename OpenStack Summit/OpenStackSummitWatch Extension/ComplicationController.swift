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
        
        switch entry {
            
        case .none, .multiple:
            
            // Update hourly by default
            handler(NSDate(timeIntervalSinceNow: 60*60))
            
        case let .event(event):
            
            // when current event ends
            handler(event.end.toFoundation())
        }
    }
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        
        let template = self.template(for: complication, with: .none)
        handler(template)
    }
        
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimelineEntry?) -> Void) {
        
        let entry = self.entry(for: Date())
        
        let template = self.template(for: complication, with: entry)
        
        let complicationEntry = CLKComplicationTimelineEntry(date: entry.start?.toFoundation() ?? NSDate(), complicationTemplate: template)
        
        handler(complicationEntry)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: ([CLKComplicationTimelineEntry]?) -> Void) {
        
        guard Store.shared.cache != nil
            else { handler(nil); return }
        
        var dates = [NSDate]()
        
        for index in 1 ... limit {
            
            let entryDate = date.mt_dateMinutesBefore(index)
            
            dates.append(entryDate)
        }
        
        let entries = dates.map { CLKComplicationTimelineEntry(date: $0, complicationTemplate: self.template(for: complication, with: self.entry(for: Date(foundation: $0)))) }
        
        handler(entries)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: ([CLKComplicationTimelineEntry]?) -> Void) {
        
        guard Store.shared.cache != nil
            else { handler(nil); return }
        
        var dates = [NSDate]()
        
        // get next `n` minutes
        for index in 1 ... limit {
            
            let entryDate = date.mt_dateMinutesAfter(index)
            
            dates.append(entryDate)
        }
        
        let entries = dates.map { CLKComplicationTimelineEntry(date: $0, complicationTemplate: self.template(for: complication, with: self.entry(for: Date(foundation: $0)))) }
        
        handler(entries)
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        
        let date = Store.shared.cache?.schedule.sort({ $0.0.start < $0.1.start }).first?.start
        
        handler(date?.toFoundation() ?? NSDate())
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        
        let date = Store.shared.cache?.schedule.sort({ $0.0.start > $0.1.start }).first?.start
        
        handler(date?.toFoundation() ?? NSDate())
    }
    
    // MARK: - Private Methods
    
    private func template(for complication: CLKComplication, with entry: TimelineEntry) -> CLKComplicationTemplate {
        
        switch complication.family {
            
        case .UtilitarianLarge:
            
            let complicationTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            
            let textProvider = CLKSimpleTextProvider()
            
            switch entry {
                
            case .none: textProvider.text = "No event"
                
            case let .multiple(events, start, timeZone):
                
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
                
                textProvider.text = "\(events) events starting at " + startDateText
                
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
                
            case let .multiple(count, start, timeZone):
                
                let complicationTemplate = CLKComplicationTemplateModularLargeTallBody()
                
                complicationTemplate.headerTextProvider = CLKTimeTextProvider(date: start.toFoundation(), timeZone: NSTimeZone(name: timeZone))
                
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
        
        // get sorted events
        // had to break into multiple expressions for compiler
        var events = summit.schedule.sort({ $0.0.start < $0.1.start && $0.0.end < $0.1.end })
            .sort({ $0.0.name.caseInsensitiveCompare($0.1.name) == .OrderedAscending })
            
        // only events that start after the specified date
        .filter({ $0.start >= date })
        
        // get first event
        guard let firstEvent = events.first
            else { return .none }
        
        // get overlapping events (only events that start within the timeframe of the first event)
        events = events.filter { $0.start <= firstEvent.end }
        assert(events.isEmpty == false, "Should never filter out all events, revise algorithm.")
        
        // multiple events
        if events.count > 1 {
            
            return .multiple(events.count, firstEvent.start, summit.timeZone)
            
        } else {
            
            return .event(EventDetail(event: firstEvent, summit: summit))
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
        case multiple(Int, Date, String)
        
        /// A single event
        case event(EventDetail)
        
        var start: Date? {
            
            switch self {
            case .none: return nil
            case let .multiple(_, start, _): return start
            case let .event(event): return event.start
            }
        }
    }
    
    struct EventDetail: Unique {
        
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
