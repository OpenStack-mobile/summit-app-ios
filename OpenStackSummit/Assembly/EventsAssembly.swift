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
    var generalScheduleFilterAssembly: GeneralScheduleFilterAssembly!
    var trackListAssembly: TrackListAssembly!
    var levelListAssembly: LevelListAssembly!
    
    dynamic func eventsWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(EventsWireframe.self) {
            (definition) in
            
            definition.injectProperty("eventsViewController", with: self.eventsViewController())
            definition.injectProperty("generalScheduleFilterWireframe", with: self.generalScheduleFilterAssembly.generalScheduleFilterWireframe())
        }
    }
    
    dynamic func eventsPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(EventsPresenter.self) {
            (definition) in
            
            definition.injectProperty("wireframe", with: self.eventsWireframe())
        }
    }
    
    dynamic func eventsViewController() -> AnyObject {
        return TyphoonDefinition.withClass(EventsViewController.self) {
            (definition) in
            
            definition.injectProperty("generalScheduleViewController", with: self.generalScheduleAssembly.generalScheduleViewController())
            definition.injectProperty("trackListViewController", with: self.trackListAssembly.trackListViewController())
            definition.injectProperty("levelListViewController", with: self.levelListAssembly.levelListViewController())
            definition.injectProperty("presenter", with: self.eventsPresenter())
        }
    }
}