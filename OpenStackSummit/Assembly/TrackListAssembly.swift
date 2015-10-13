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
    var dataStoreAssembly: DataStoreAssembly!
    var dtoAssemblersAsembly: DTOAssemblersAssembly!
    
    dynamic func trackListWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(TrackListWireframe.self) {
            (definition) in
        }
    }
    
    dynamic func trackListPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(TrackListPresenter.self) {
            (definition) in
            
            definition.injectProperty("viewController", with: self.trackListViewController())
            definition.injectProperty("interactor", with: self.trackListInteractor())
            definition.injectProperty("wireframe", with: self.trackListWireframe())
            
        }
    }
    
    dynamic func trackListInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(TrackListInteractor.self) {
            (definition) in
            
            definition.injectProperty("genericDataStore", with: self.dataStoreAssembly.genericDataStore())
            definition.injectProperty("namedDTOAssembler", with: self.dtoAssemblersAsembly.namedDTOAssembler())
        }
    }
    
    dynamic func trackListViewController() -> AnyObject {
        return TyphoonDefinition.withClass(TrackListViewController.self) {
            (definition) in
            
            definition.injectProperty("presenter", with: self.trackListPresenter())
        }
    }
}
