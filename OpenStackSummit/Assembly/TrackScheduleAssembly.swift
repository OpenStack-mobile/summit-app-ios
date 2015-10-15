//
//  TrackScheduleAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

class TrackScheduleAssembly: TyphoonAssembly {
    var applicationAssembly: ApplicationAssembly!
    
    dynamic func trackScheduleWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(TrackScheduleWireframe.self) {
            (definition) in
            
            definition.injectProperty("trackScheduleViewController", with: self.trackScheduleViewController())
        }
    }
    
    dynamic func trackScheduleInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(TrackScheduleInteractor.self) {
            (definition) in
            
        }
    }
    
    dynamic func trackScheduleViewController() -> AnyObject {
        return TyphoonDefinition.withFactory(self.applicationAssembly.mainStoryboard(), selector: "instantiateViewControllerWithIdentifier:", parameters: {
            (factoryMethod) in
            
            factoryMethod.injectParameterWith("TrackScheduleViewController")
            }, configuration: {
                (definition) in
                definition.injectProperty("presenter", with: self.trackSchedulePresenter())
        })
    }
    
    var eventDetailAssembly: EventDetailAssembly!
    var summitDataStoreAssembly: SummitDataStoreAssembly!
    var memberDataStore: MemberDataStoreAssembly!
    var securityManagerAssembly: SecurityManagerAssembly!
    
    dynamic func tgeneralScheduleWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(GeneralScheduleWireframe.self) {
            (definition) in
            
            definition.injectProperty("generalScheduleViewController", with: self.trackScheduleViewController())
            definition.injectProperty("eventDetailWireframe", with: self.eventDetailAssembly.eventDetailWireframe())
        }
    }
    
    dynamic func trackSchedulePresenter() -> AnyObject {
        return TyphoonDefinition.withClass(TrackSchedulePresenter.self) {
            (definition) in
            
            definition.injectProperty("viewController", with: self.trackScheduleViewController())
            definition.injectProperty("interactor", with: self.tgeneralScheduleInteractor())
            definition.injectProperty("generalScheduleWireframe", with: self.tgeneralScheduleWireframe())
            definition.injectProperty("session", with: self.tgeneralScheduleSession())
            
        }
    }
    
    dynamic func tgeneralScheduleInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(GeneralScheduleInteractor.self) {
            (definition) in
            
            definition.injectProperty("summitDataStore", with: self.summitDataStoreAssembly.summitDataStore())
            definition.injectProperty("summitDTOAssembler", with: self.tsummitDTOAssembler())
            definition.injectProperty("eventDataStore", with: self.tgeneralScheduleEventDataStore())
            definition.injectProperty("scheduleItemDTOAssembler", with: self.tgeneralScheduleScheduleItemDTOAssembler())
            definition.injectProperty("memberDataStore", with: self.memberDataStore.memberDataStore())
            definition.injectProperty("securityManager", with: self.securityManagerAssembly.securityManager())
        }
    }
    
    dynamic func tgeneralScheduleSession() -> AnyObject {
        
        return TyphoonDefinition.withClass(Session.self)
    }
    
    dynamic func tgeneralScheduleScheduleItemDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(ScheduleItemDTOAssembler.self)
    }
    
    dynamic func tgeneralScheduleEventDataStore() -> AnyObject {
        return TyphoonDefinition.withClass(EventDataStore.self)
    }
    
    dynamic func tsummitDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(SummitDTOAssembler.self)
    }
}
