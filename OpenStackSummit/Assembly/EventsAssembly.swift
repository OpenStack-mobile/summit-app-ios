//
//  EventsAssembly.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//
//

import UIKit
import Typhoon

class EventsAssembly: TyphoonAssembly {
    var generalScheduleAssembly: GeneralScheduleAssembly!
    var trackListAssembly: TrackListAssembly!

    dynamic func eventsViewController() -> AnyObject {
        return TyphoonDefinition.withClass(EventsViewController.self) {
            (definition) in
            
            definition.injectProperty("generalScheduleViewController", with: self.generalScheduleAssembly.generalScheduleViewController())
        }
    }
    
    dynamic func eventsTrackListViewController() -> AnyObject {
        return TyphoonDefinition.withClass(TrackListViewController.self) {
            (definition) in
            
            definition.injectProperty("trackListViewController", with: self.trackListAssembly.trackListViewController())
        }
    }
}