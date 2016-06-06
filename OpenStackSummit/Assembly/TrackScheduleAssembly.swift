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
    var eventDetailAssembly: EventDetailAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    var securityManagerAssembly: SecurityManagerAssembly!
    var dtoAssemblersAssembly: DTOAssemblersAssembly!
    var dataUpdateAssembly: DataUpdateAssembly!

    dynamic func trackScheduleWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(TrackScheduleWireframe.self) {
            (definition) in
            
            definition.injectProperty("trackScheduleViewController", with: self.trackScheduleViewController())
            definition.injectProperty("eventDetailWireframe", with: self.eventDetailAssembly.eventDetailWireframe())
        }
    }
    
    dynamic func trackScheduleInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(TrackScheduleInteractor.self) {
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
    
    dynamic func trackSchedulePresenter() -> AnyObject {
        return TyphoonDefinition.withClass(TrackSchedulePresenter.self) {
            (definition) in
            
            definition.injectProperty("viewController", with: self.trackScheduleViewController())
            definition.injectProperty("interactor", with: self.trackScheduleInteractor())
            definition.injectProperty("wireframe", with: self.trackScheduleWireframe())
            definition.injectProperty("session", with: self.applicationAssembly.session())
            definition.injectProperty("scheduleFilter", with: self.applicationAssembly.scheduleFilter())
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
}
