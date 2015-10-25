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
        }
    }
    
    dynamic func searchInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(SearchInteractor.self) {
            (definition) in
            
            definition.injectProperty("eventDataStore", with: self.dataStoreAssembly.eventDataStore())
            definition.injectProperty("scheduleItemDTOAssembler", with: self.dtoAssemblersAssembly.scheduleItemDTOAssembler())
            definition.injectProperty("trackDataStore", with: self.dataStoreAssembly.trackDataStore())
            definition.injectProperty("trackDTOAssembler", with: self.dtoAssemblersAssembly.namedDTOAssembler())
            definition.injectProperty("presentationSpeakerRemoteDataStore", with: self.dataStoreAssembly.presentationSpeakerRemoteDataStore())
            definition.injectProperty("summitAttendeeRemoteDataStore", with: self.dataStoreAssembly.summitAttendeeRemoteDataStore())
            definition.injectProperty("personDTOAssembler", with: self.dtoAssemblersAssembly.personListItemDTOAssembler())
            
        }
    }
    
    dynamic func searchViewController() -> AnyObject {
        return TyphoonDefinition.withClass(SearchViewController.self) {
            (definition) in
            
            definition.injectProperty("presenter", with: self.searchPresenter())
        }
    }
}