//
//  PeopleAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

class PeopleAssembly: TyphoonAssembly {
    var remoteDataStoresAssembly: RemoteDataStoresAssembly!
    
    dynamic func peopleWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(PeopleWireframe.self) {
            (definition) in
            
            //definition.injectProperty("peopleViewController", with: self.peopleViewController())
            //definition.injectProperty("eventDetailWireframe", with: self.eventDetailAssembly.eventDetailWireframe())
        }
    }
    
    dynamic func peoplePresenter() -> AnyObject {
        return TyphoonDefinition.withClass(PeoplePresenter.self) {
            (definition) in
            
            definition.injectProperty("viewController", with: self.peopleViewController())
            definition.injectProperty("interactor", with: self.peopleInteractor())
            definition.injectProperty("wireframe", with: self.peopleWireframe())
            
        }
    }
    
    dynamic func peopleInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(PeopleInteractor.self) {
            (definition) in
            
            definition.injectProperty("presentationSpeakerRemoteDataStore", with: self.remoteDataStoresAssembly.presentationSpeakerRemoteDataStore())
            definition.injectProperty("summitAttendeeRemoteDataStore", with: self.remoteDataStoresAssembly.summitAttendeeRemoteDataStore())
            definition.injectProperty("personDTOAssembler", with: self.personListItemDTOAssembler())
        }
    }
        
    dynamic func personListItemDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(PersonListItemDTOAssembler.self)
    }
    
    dynamic func peopleEventDataStore() -> AnyObject {
        return TyphoonDefinition.withClass(EventDataStore.self)
    }
        
    dynamic func peopleViewController() -> AnyObject {
        return TyphoonDefinition.withClass(PeopleViewController.self) {
            (definition) in
            
            definition.injectProperty("presenter", with: self.peoplePresenter())
        }
    }    
}
