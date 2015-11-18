//
//  VenueListAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

public class VenueListAssembly: TyphoonAssembly {
    var applicationAssembly: ApplicationAssembly!
    var venueDetailAssembly: VenueDetailAssembly!
    var dtoAssemblersAssembly: DTOAssemblersAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    
    dynamic func venueListWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(VenueListWireframe.self) {
            (definition) in
            
            definition.injectProperty("venueListViewController", with: self.venueListViewController())
            definition.injectProperty("venueDetailWireframe", with: self.venueDetailAssembly.venueDetailWireframe())
        }
    }
    
    dynamic func venueListPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(VenueListPresenter.self) {
            (definition) in
            
            definition.injectProperty("interactor", with: self.venueListInteractor())
            definition.injectProperty("viewController", with: self.venueListViewController())
            definition.injectProperty("wireframe", with: self.venueListWireframe())
        }
    }
    
    dynamic func venueListInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(VenueListInteractor.self) {
            (definition) in
            definition.injectProperty("genericDataStore", with: self.dataStoreAssembly.genericDataStore())
            definition.injectProperty("venueListItemDTOAssembler", with: self.dtoAssemblersAssembly.venueListItemDTOAssembler())
        }
    }
        
    dynamic func venueListViewController() -> AnyObject {
        return TyphoonDefinition.withFactory(self.applicationAssembly.mainStoryboard(), selector: "instantiateViewControllerWithIdentifier:", parameters: {
            (factoryMethod) in
            
            factoryMethod.injectParameterWith("VenueListViewController")
            }, configuration: {
                (definition) in
                definition.injectProperty("presenter", with: self.venueListPresenter())
        })
    }
}
