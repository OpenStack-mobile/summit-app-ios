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
    var applicationAssembly: ApplicationAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    var dtoAssemblersAssembly: DTOAssemblersAssembly!
    var memberProfileAssembly: MemberProfileAssembly!
    
    dynamic func peopleWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(PeopleWireframe.self) {
            (definition) in
            definition.injectProperty("memberProfileWireframe", with: self.memberProfileAssembly.memberProfileWireframe())
            definition.injectProperty("attendeesListViewController", with: self.attendeesListViewController())
            definition.injectProperty("speakersListViewController", with: self.speakerListViewController())
       }
    }
    
    dynamic func peoplePresenter() -> AnyObject {
        return TyphoonDefinition.withClass(PeoplePresenter.self) {
            (definition) in
            
            definition.injectProperty("attendeesListViewController", with: self.attendeesListViewController())
            definition.injectProperty("speakersListViewController", with: self.speakerListViewController())
            definition.injectProperty("interactor", with: self.peopleInteractor())
            definition.injectProperty("wireframe", with: self.peopleWireframe())
            
        }
    }
    
    dynamic func peopleInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(PeopleInteractor.self) {
            (definition) in
            
            definition.injectProperty("presentationSpeakerDataStore", with: self.dataStoreAssembly.presentationSpeakerDataStore())
            definition.injectProperty("summitAttendeeRemoteDataStore", with: self.dataStoreAssembly.summitAttendeeRemoteDataStore())
            definition.injectProperty("personDTOAssembler", with: self.dtoAssemblersAssembly.personListItemDTOAssembler())
        }
    }
    
    dynamic func peopleViewController() -> AnyObject {
        return TyphoonDefinition.withClass(PeopleViewController.self) {
            (definition) in
            
            definition.injectProperty("attendeesListViewController", with: self.attendeesListViewController())
            definition.injectProperty("speakersListViewController", with: self.speakerListViewController())
        }
    }
    
    dynamic func speakersViewController() -> AnyObject {
        return TyphoonDefinition.withClass(SpeakersViewController.self) {
            (definition) in
            
            definition.injectProperty("speakersListViewController", with: self.speakerListViewController())
        }
    }
    
    dynamic func attendeesListViewController() -> AnyObject {
        return TyphoonDefinition.withFactory(self.applicationAssembly.mainStoryboard(), selector: "instantiateViewControllerWithIdentifier:", parameters: {
            (factoryMethod) in
            
            factoryMethod.injectParameterWith("AttendeesListViewController")
            }, configuration: {
                (definition) in
                definition.injectProperty("presenter", with: self.peoplePresenter())
                definition.scope = TyphoonScope.WeakSingleton
        })
    }
    
    dynamic func speakerListViewController() -> AnyObject {
        return TyphoonDefinition.withFactory(self.applicationAssembly.mainStoryboard(), selector: "instantiateViewControllerWithIdentifier:", parameters: {
            (factoryMethod) in
            
            factoryMethod.injectParameterWith("SpeakerListViewController")
            }, configuration: {
                (definition) in
                definition.injectProperty("presenter", with: self.peoplePresenter())
                definition.scope = TyphoonScope.WeakSingleton
        })
    }
}
