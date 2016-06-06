//
//  SpeakerPresentationsAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/19/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

class SpeakerPresentationsAssembly: TyphoonAssembly {
    var applicationAssembly: ApplicationAssembly!
    var eventDetailAssembly: EventDetailAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    var securityManagerAssembly: SecurityManagerAssembly!
    var dtoAssemblersAssembly: DTOAssemblersAssembly!
    var dataUpdateAssembly: DataUpdateAssembly!
    
    dynamic func speakerPresentationsWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(SpeakerPresentationsWireframe.self) {
            (definition) in
            
            definition.injectProperty("speakerPresentationsViewController", with: self.speakerPresentationsViewController())
            definition.injectProperty("eventDetailWireframe", with: self.eventDetailAssembly.eventDetailWireframe())
        }
    }
    
    dynamic func speakerPresentationsInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(SpeakerPresentationsInteractor.self) {
            (definition) in
            definition.injectProperty("summitDataStore", with: self.dataStoreAssembly.summitDataStore())
            definition.injectProperty("CoreSummit.SummitAssembler", with: self.dtoAssemblersAssembly.CoreSummit.SummitAssembler())
            definition.injectProperty("eventDataStore", with: self.dataStoreAssembly.eventDataStore())
            definition.injectProperty("ScheduleItemAssembler", with: self.dtoAssemblersAssembly.ScheduleItemAssembler())
            definition.injectProperty("summitAttendeeDataStore", with: self.dataStoreAssembly.summitAttendeeDataStore())
            definition.injectProperty("securityManager", with: self.securityManagerAssembly.securityManager())
            definition.injectProperty("dataUpdatePoller", with: self.dataUpdateAssembly.dataUpdatePoller())
            definition.injectProperty("pushNotificationsManager", with: self.applicationAssembly.pushNotificationsManager())
            definition.injectProperty("reachability", with: self.applicationAssembly.reachability())
        }
    }
    
    dynamic func speakerPresentationsPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(SpeakerPresentationsPresenter.self) {
            (definition) in
            
            definition.injectProperty("viewController", with: self.speakerPresentationsViewController())
            definition.injectProperty("interactor", with: self.speakerPresentationsInteractor())
            definition.injectProperty("wireframe", with: self.speakerPresentationsWireframe())
            definition.injectProperty("session", with: self.applicationAssembly.session())
            definition.injectProperty("scheduleFilter", with: self.applicationAssembly.scheduleFilter())
        }
    }
    
    dynamic func speakerPresentationsViewController() -> AnyObject {
        return TyphoonDefinition.withFactory(self.applicationAssembly.mainStoryboard(), selector: "instantiateViewControllerWithIdentifier:", parameters: {
            (factoryMethod) in
            
            factoryMethod.injectParameterWith("SpeakerPresentationsViewController")
            }, configuration: {
                (definition) in
                
                definition.injectProperty("presenter", with: self.speakerPresentationsPresenter())
                definition.scope = TyphoonScope.Singleton
        })
    }
}
