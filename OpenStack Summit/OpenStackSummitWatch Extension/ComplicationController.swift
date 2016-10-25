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
        
        // when current event ends
        if let event = self.event(for: Date()) {
            
            handler(event.end.toFoundation())
            
        } else {
            
            // Update hourly by default
            handler(NSDate(timeIntervalSinceNow: 60*60))
        }
    }
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        
        let template = self.template(for: complication, with: nil)
        handler(template)
    }
        
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimelineEntry?) -> Void) {
        
        let event = self.event(for: Date())
        
        let template = self.template(for: complication, with: event)
        
        let entry = CLKComplicationTimelineEntry(date: event?.start.toFoundation() ?? NSDate(), complicationTemplate: template)
        
        handler(entry)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: ([CLKComplicationTimelineEntry]?) -> Void) {
        
        guard let summit = Store.shared.cache
            else { handler(nil); return }
        
        let beforeDate = Date(foundation: date)
        
        let events = summit.schedule.filter({ $0.start <= beforeDate }).sort({ $0.0.start < $0.1.start }).prefix(limit)
        
        let eventDetails = events.map { EventDetail(event: $0, summit: summit) }
        
        let entries = eventDetails.map { CLKComplicationTimelineEntry(date: $0.start.toFoundation(), complicationTemplate: self.template(for: complication, with: $0)) }
        
        handler(entries)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: ([CLKComplicationTimelineEntry]?) -> Void) {
        
        guard let summit = Store.shared.cache
            else { handler(nil); return }
        
        let afterDate = Date(foundation: date)
        
        let events = summit.schedule.filter({ $0.start >= afterDate }).sort({ $0.0.start < $0.1.start }).prefix(limit)
        
        let eventDetails = events.map { EventDetail(event: $0, summit: summit) }
        
        let entries = eventDetails.map { CLKComplicationTimelineEntry(date: $0.start.toFoundation(), complicationTemplate: self.template(for: complication, with: $0)) }
        
        handler(entries)
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        
        let date = Store.shared.cache?.schedule.sort({ $0.0.start < $0.1.start }).first?.start
        
        handler(date?.toFoundation())
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        
        let date = Store.shared.cache?.schedule.sort({ $0.0.start < $0.1.start }).first?.end
        
        handler(date?.toFoundation())
    }
    
    // MARK: - Private Methods
    
    private func template(for complication: CLKComplication, with event: EventDetail?) -> CLKComplicationTemplate {
        
        switch complication.family {
            
        case .UtilitarianLarge:
            
            let complicationTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            
            let textProvider = CLKSimpleTextProvider()
            
            textProvider.text = event?.name ?? "No current event"
            
            complicationTemplate.textProvider = textProvider
            
            return complicationTemplate
            
        case .ModularLarge:
            
            if let event = event {
                
                let complicationTemplate = CLKComplicationTemplateModularLargeStandardBody()
                
                complicationTemplate.headerTextProvider = CLKTimeIntervalTextProvider(startDate: event.start.toFoundation(), endDate: event.end.toFoundation(), timeZone: NSTimeZone(name: event.timeZone))
                
                complicationTemplate.body1TextProvider = CLKSimpleTextProvider(text: event.name)
                
                complicationTemplate.body2TextProvider = CLKSimpleTextProvider(text: event.location)
                
                return complicationTemplate
                
            } else {
                
                let complicationTemplate = CLKComplicationTemplateModularLargeTallBody()
                
                complicationTemplate.headerTextProvider = CLKSimpleTextProvider(text: "OpenStack Summit")
                
                complicationTemplate.bodyTextProvider = CLKSimpleTextProvider(text: "No current event")
                
                return complicationTemplate
            }
            
        default: fatalError("Complication family \(complication.family.rawValue) not supported")
        }
    }
    
    private func event(for date: Date) -> EventDetail? {
        
        guard let summit = Store.shared.cache,
            let event = summit.schedule.filter({ $0.start >= date }).sort({ $0.0.start < $0.1.start }).first
            else { return nil }
        
        return EventDetail(event: event, summit: summit)
    }
    
    // MARK: - Notifications
    
    @objc private func complicationServerActiveComplicationsDidChange(notification: NSNotification) {
        
        ComplicationController.reloadComplications()
    }
}

extension ComplicationController {
    
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
