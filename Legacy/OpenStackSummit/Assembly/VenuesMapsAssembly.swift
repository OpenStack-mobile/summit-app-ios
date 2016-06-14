//
//  VenuesMapsAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/21/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Typhoon

public class VenuesMapsAssembly: TyphoonAssembly {
    var venueDetailAssembly: VenueDetailAssembly!
    var dtoAssemblersAssembly: DTOAssemblersAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    var venueListAssembly: VenueListAssembly!
    
    dynamic func venueMapWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(VenueListWireframe.self) {
            (definition) in
            
            definition.injectProperty("venueListViewController", with: self.venuesMapViewController())
            definition.injectProperty("venueDetailWireframe", with: self.venueDetailAssembly.venueDetailWireframe())
        }
    }
    
    dynamic func venuesMapPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(VenuesMapPresenter.self) {
            (definition) in
            
            definition.injectProperty("interactor", with: self.venuesMapInteractor())
            definition.injectProperty("wireframe", with: self.venueMapWireframe())
            definition.injectProperty("viewController", with: self.venuesMapViewController())
        }
    }
    
    dynamic func venuesMapInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(VenuesMapInteractor.self) {
            (definition) in
            definition.injectProperty("genericDataStore", with: self.dataStoreAssembly.genericDataStore())
            definition.injectProperty("venueListItemDTOAssembler", with: self.dtoAssemblersAssembly.venueListItemDTOAssembler())
        }
    }
        
    dynamic func venuesMapViewController() -> AnyObject {
        return TyphoonDefinition.withClass(VenuesMapViewController.self) {
            (definition) in
            
            definition.injectProperty("presenter", with: self.venuesMapPresenter())
        }
    }
}
