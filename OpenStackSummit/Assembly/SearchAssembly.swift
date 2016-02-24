//
//  SearchAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/23/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

class SearchAssembly: TyphoonAssembly {
    var applicationAssembly: ApplicationAssembly!
    var eventDetailAssembly: EventDetailAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    var securityManagerAssembly: SecurityManagerAssembly!
    var dtoAssemblersAssembly: DTOAssemblersAssembly!
    var trackScheduleAssembly: TrackScheduleAssembly!
    var memberProfileAssembly: MemberProfileAssembly!
    
    dynamic func searchWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(SearchWireframe.self) {
            (definition) in
            
            definition.injectProperty("navigationController", with: self.applicationAssembly.navigationController())
            definition.injectProperty("revealViewController", with: self.applicationAssembly.revealViewController())
            definition.injectProperty("searchViewController", with: self.searchViewController())
            definition.injectProperty("eventDetailWireframe", with: self.eventDetailAssembly.eventDetailWireframe())
            definition.injectProperty("memberProfileWireframe", with: self.memberProfileAssembly.memberProfileWireframe())
            definition.injectProperty("trackScheduleWireframe", with: self.trackScheduleAssembly.trackScheduleWireframe())
        }
    }
    
    dynamic func searchPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(SearchPresenter.self) {
            (definition) in
            
            definition.injectProperty("viewController", with: self.searchViewController())
            definition.injectProperty("interactor", with: self.searchInteractor())
            definition.injectProperty("wireframe", with: self.searchWireframe())
            definition.injectProperty("session", with: self.applicationAssembly.session())
        }
    }
    
    dynamic func searchInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(SearchInteractor.self) {
            (definition) in
            
            definition.injectProperty("eventDataStore", with: self.dataStoreAssembly.eventDataStore())
            definition.injectProperty("scheduleItemDTOAssembler", with: self.dtoAssemblersAssembly.scheduleItemDTOAssembler())
            definition.injectProperty("trackDataStore", with: self.dataStoreAssembly.trackDataStore())
            definition.injectProperty("trackDTOAssembler", with: self.dtoAssemblersAssembly.namedDTOAssembler())
            definition.injectProperty("presentationSpeakerDataStore", with: self.dataStoreAssembly.presentationSpeakerDataStore())
            definition.injectProperty("summitAttendeeRemoteDataStore", with: self.dataStoreAssembly.summitAttendeeRemoteDataStore())
            definition.injectProperty("summitAttendeeDataStore", with: self.dataStoreAssembly.summitAttendeeDataStore())
            definition.injectProperty("personDTOAssembler", with: self.dtoAssemblersAssembly.personListItemDTOAssembler())
            definition.injectProperty("securityManager", with: self.securityManagerAssembly.securityManager())
            definition.injectProperty("reachability", with: self.applicationAssembly.reachability())
        }
    }
    
    dynamic func searchViewController() -> AnyObject {
        return TyphoonDefinition.withFactory(self.applicationAssembly.mainStoryboard(), selector: "instantiateViewControllerWithIdentifier:", parameters: {
            (factoryMethod) in
            
            factoryMethod.injectParameterWith("SearchViewController")
            }, configuration: {
                (definition) in
                
                definition.injectProperty("presenter", with: self.searchPresenter())
        })
    }
}