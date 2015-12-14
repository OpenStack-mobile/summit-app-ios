//
//  EventDetailAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

class EventDetailAssembly: TyphoonAssembly {
    var dataStoreAssembly: DataStoreAssembly!
    var applicationAssembly: ApplicationAssembly!
    var feedbackEditWireframe: FeedbackEditAssembly!
    var dtoAssemblersAssembly: DTOAssemblersAssembly!
    var memberProfileAssembly: MemberProfileAssembly!
    var venueRoomDetailAssembly: VenueRoomDetailAssembly!
    var venueDetailAssembly: VenueDetailAssembly!
    var securityManagerAssembly: SecurityManagerAssembly!

    dynamic func eventDetailWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(EventDetailWireframe.self) {
            (definition) in
            
            definition.injectProperty("eventDetailViewController", with: self.eventDetailViewController())
            definition.injectProperty("feedbackEditWireframe", with: self.feedbackEditWireframe.feedbackEditWireframe())
            definition.injectProperty("memberProfileWireframe", with: self.memberProfileAssembly.memberProfileWireframe())
            definition.injectProperty("venueRoomDetailWireframe", with: self.venueRoomDetailAssembly.venueRoomDetailWireframe())
            definition.injectProperty("venueDetailWireframe", with: self.venueDetailAssembly.venueDetailWireframe())   
        }
    }
    
    dynamic func eventDetailPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(EventDetailPresenter.self) {
            (definition) in
            
            definition.injectProperty("viewController", with: self.eventDetailViewController())
            definition.injectProperty("interactor", with: self.eventDetailInteractor())
            definition.injectProperty("wireframe", with: self.eventDetailWireframe())
        }
    }
        
    dynamic func eventDetailInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(EventDetailInteractor.self) {
            (definition) in
            
            definition.injectProperty("eventDataStore", with: self.dataStoreAssembly.eventDataStore())
            definition.injectProperty("eventDetailDTOAssembler", with: self.dtoAssemblersAssembly.eventDetailDTOAssembler())
            definition.injectProperty("summitAttendeeDataStore", with: self.dataStoreAssembly.summitAttendeeDataStore())
            definition.injectProperty("feedbackDTOAssembler", with: self.dtoAssemblersAssembly.feedbackDTOAssembler())
            definition.injectProperty("securityManager", with: self.securityManagerAssembly.securityManager())
            definition.injectProperty("reachability", with: self.applicationAssembly.reachability())
        }
    }
    
    dynamic func eventDetailViewController() -> AnyObject {
        return TyphoonDefinition.withFactory(self.applicationAssembly.mainStoryboard(), selector: "instantiateViewControllerWithIdentifier:", parameters: {
            (factoryMethod) in
            
            factoryMethod.injectParameterWith("EventDetailViewController")
            }, configuration: {
                (definition) in
                definition.injectProperty("presenter", with: self.eventDetailPresenter())
                definition.scope = TyphoonScope.WeakSingleton
        })
    }
}


