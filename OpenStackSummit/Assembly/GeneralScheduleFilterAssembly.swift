//
//  GeneralScheduleFilterAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

public class GeneralScheduleFilterAssembly: TyphoonAssembly {
    dynamic func generalScheduleFilterWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(GeneralScheduleFilterWireframe.self) {
            (definition) in
            
        }
    }
    
    dynamic func generalScheduleFilterPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(GeneralScheduleFilterPresenter.self) {
            (definition) in
            
            definition.injectProperty("interactor", with: self.generailScheduleFilterInteractor())
            definition.injectProperty("generalScheduleFilterWireframe", with: self.generalScheduleFilterWireframe())
            
        }
    }
    
    dynamic func generailScheduleFilterInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(GeneralScheduleFilterInteractor.self) {
            (definition) in
            
            definition.injectProperty("delegate", with: self.generalScheduleFilterPresenter())
            definition.injectProperty("summitTypeDataStore", with: self.summitTypeDataStore())
            definition.injectProperty("eventTypeDataStore", with: self.eventTypeDataStore())
            definition.injectProperty("trackDataStore", with: self.trackDataStore())
        }
    }
    
    dynamic func summitTypeDataStore() -> AnyObject {
        return TyphoonDefinition.withClass(SummitTypeDataStore.self)
    }
    
    dynamic func eventTypeDataStore() -> AnyObject {
        return TyphoonDefinition.withClass(EventTypeDataStore.self)
    }

    dynamic func trackDataStore() -> AnyObject {
        return TyphoonDefinition.withClass(TrackDataStore.self)
    }
    
    dynamic func generalScheduleFilterViewController() -> AnyObject {
        return TyphoonDefinition.withClass(GeneralScheduleFilterViewController.self) {
            (definition) in
            
            definition.injectProperty("presenter", with: self.generalScheduleFilterPresenter())
        }
    }

}
