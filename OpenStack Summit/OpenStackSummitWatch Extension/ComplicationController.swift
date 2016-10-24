//
//  ComplicationController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 10/24/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import ClockKit
import SwiftFoundation
import CoreSummit

final class ComplicationController: NSObject, CLKComplicationDataSource {
    
    override init() {
        super.init()
        
        print("Initialized \(self.dynamicType)")
    }
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        
        handler([.Backward, .Forward])
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        
        handler(.ShowOnLockScreen)
    }
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        
        // when current event ends
        
        // Update hourly
        handler(NSDate(timeIntervalSinceNow: 60*60))
    }
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        handler(nil)
    }
    
    
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimelineEntry?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: ([CLKComplicationTimelineEntry]?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: ([CLKComplicationTimelineEntry]?) -> Void) {
        handler([])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(NSDate())
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(NSDate())
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
            
            let complicationTemplate = CLKComplicationTemplateModularLargeStandardBody()
            
            complicationTemplate.headerTextProvider = CLKSimpleTextProvider
            
            
            
            return complicationTemplate
            
        default: fatalError("Complication family \(complication.family.rawValue) not supported")
        }
    }
}

extension ComplicationController {
    
    struct EventDetail: Unique {
        
        let identifier: Identifier
        let name: String
        let start: Date
        let end: Date
        let location: String
        
        init(event: Event, summit: Summit) {
            
            self.identifier = event.identifier
            self.name = event.name
            self.start = event.start
            self.end = event.end
            self.location = OpenStackSummitWatch_Extension.EventDetail.getLocation(event, summit: summit)
        }
    }
}
