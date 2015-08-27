//
//  GeneralScheduleAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

class GeneralScheduleAssembly: TyphoonAssembly {
    var eventDetailAssembly: EventDetailAssembly!
    
    dynamic func generalScheduleWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(GeneralScheduleWireframe.self) {
            (definition) in
            
            definition.injectProperty("generalScheduleViewController", with: self.generalScheduleViewController())
            definition.injectProperty("eventDetailWireframe", with: self.eventDetailAssembly.eventDetailWireframe())
        }
    }
    
    dynamic func generalSchedulePresenter() -> AnyObject {
        return TyphoonDefinition.withClass(GeneralSchedulePresenter.self) {
            (definition) in
            
            definition.injectProperty("viewController", with: self.generalScheduleViewController())
            definition.injectProperty("interactor", with: self.generailScheduleInteractor())
            definition.injectProperty("generalScheduleWireframe", with: self.generalScheduleWireframe())
            
        }
    }
    
    dynamic func generailScheduleInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(GeneralScheduleInteractor.self) {
            (definition) in
            
            definition.injectProperty("delegate", with: self.generalSchedulePresenter())
            definition.injectProperty("summitDataStore", with: self.summitDataStore())
        }
    }
    
    dynamic func summitDataStore() -> AnyObject {
        return TyphoonDefinition.withClass(SummitDataStore.self)
    }
    
    dynamic func generalScheduleViewController() -> AnyObject {
        return TyphoonDefinition.withClass(GeneralScheduleViewController.self) {
            (definition) in
            
            definition.injectProperty("presenter", with: self.generalSchedulePresenter())
        }
    }    
}