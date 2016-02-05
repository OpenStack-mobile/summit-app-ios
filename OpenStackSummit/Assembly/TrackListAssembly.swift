//
//  TrackListAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

class TrackListAssembly: TyphoonAssembly {
    var applicationAssembly: ApplicationAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    var dtoAssemblersAsembly: DTOAssemblersAssembly!
    var trackScheduleAssembly: TrackScheduleAssembly!
    
    dynamic func trackListWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(TrackListWireframe.self) {
            (definition) in
            
            definition.injectProperty("trackScheduleWireframe", with: self.trackScheduleAssembly.trackScheduleWireframe())
            definition.injectProperty("trackListViewController", with: self.trackListViewController())
        }
    }
    
    dynamic func trackListPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(TrackListPresenter.self) {
            (definition) in
            
            definition.injectProperty("viewController", with: self.trackListViewController())
            definition.injectProperty("interactor", with: self.trackListInteractor())
            definition.injectProperty("wireframe", with: self.trackListWireframe())
            definition.injectProperty("scheduleFilter", with: self.applicationAssembly.scheduleFilter())            
        }
    }
    
    dynamic func trackListInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(TrackListInteractor.self) {
            (definition) in
            
            definition.injectProperty("trackDataStore", with: self.dataStoreAssembly.trackDataStore())
            definition.injectProperty("namedDTOAssembler", with: self.dtoAssemblersAsembly.namedDTOAssembler())
        }
    }
        
    dynamic func trackListViewController() -> AnyObject {
        return TyphoonDefinition.withFactory(self.applicationAssembly.mainStoryboard(), selector: "instantiateViewControllerWithIdentifier:", parameters: {
            (factoryMethod) in
            
            factoryMethod.injectParameterWith("TrackListViewController")
            }, configuration: {
                (definition) in
                definition.injectProperty("presenter", with: self.trackListPresenter())
        })
    }
}
