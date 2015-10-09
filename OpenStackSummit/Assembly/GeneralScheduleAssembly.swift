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
    var summitDataStoreAssembly: SummitDataStoreAssembly!
    var memberDataStore: MemberDataStoreAssembly!
    var securityManagerAssembly: SecurityManagerAssembly!
    
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
            definition.injectProperty("interactor", with: self.generalScheduleInteractor())
            definition.injectProperty("generalScheduleWireframe", with: self.generalScheduleWireframe())
            definition.injectProperty("session", with: self.generalScheduleSession())

        }
    }
    
    dynamic func generalScheduleInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(GeneralScheduleInteractor.self) {
            (definition) in
            
            definition.injectProperty("summitDataStore", with: self.summitDataStoreAssembly.summitDataStore())
            definition.injectProperty("summitDTOAssembler", with: self.summitDTOAssembler())
            definition.injectProperty("eventDataStore", with: self.generalScheduleEventDataStore())
            definition.injectProperty("scheduleItemDTOAssembler", with: self.generalScheduleScheduleItemDTOAssembler())
            definition.injectProperty("memberDataStore", with: self.memberDataStore.memberDataStore())
            definition.injectProperty("securityManager", with: self.securityManagerAssembly.securityManager())
        }
    }
    
    dynamic func generalScheduleSession() -> AnyObject {
        
        return TyphoonDefinition.withClass(Session.self)
    }
    
    dynamic func generalScheduleScheduleItemDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(ScheduleItemDTOAssembler.self)
    }
    
    dynamic func generalScheduleEventDataStore() -> AnyObject {
        return TyphoonDefinition.withClass(EventDataStore.self)
    }
    
    dynamic func summitDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(SummitDTOAssembler.self)
    }
    
    dynamic func generalScheduleViewController() -> AnyObject {
        return TyphoonDefinition.withClass(GeneralScheduleViewController.self) {
            (definition) in
            
            definition.injectProperty("presenter", with: self.generalSchedulePresenter())
        }
    }    
}