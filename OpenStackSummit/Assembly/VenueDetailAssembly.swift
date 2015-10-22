//  VenueDetailAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

public class VenueDetailAssembly: TyphoonAssembly {
    var applicationAssembly: ApplicationAssembly!
    var venueRoomDetailAssembly: VenueRoomDetailAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    var dtosAssemblersAssembly: DTOAssemblersAssembly!
    
    dynamic func venueDetailWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(VenueDetailWireframe.self) {
            (definition) in
            
            definition.injectProperty("venueDetailViewController", with: self.venueDetailViewController())
            definition.injectProperty("venueRoomDetailWireframe", with: self.venueRoomDetailAssembly.venueRoomDetailWireframe())
        }
    }
    
    dynamic func venueDetailPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(VenueDetailPresenter.self) {
            (definition) in
            
            definition.injectProperty("interactor", with: self.venueDetailInteractor())
            definition.injectProperty("viewController", with: self.venueDetailViewController())
            definition.injectProperty("wireframe", with: self.venueDetailWireframe())
        }
    }
    
    dynamic func venueDetailInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(VenueDetailInteractor.self) {
            (definition) in
            
            definition.injectProperty("genericDataStore", with: self.dataStoreAssembly.genericDataStore())
            definition.injectProperty("venueDTOAssembler", with: self.dtosAssemblersAssembly.venueDTOAssembler())
        }
    }
    
    dynamic func venueDetailViewController() -> AnyObject {
        return TyphoonDefinition.withClass(VenueDetailViewController.self) {
            (definition) in
            
            definition.injectProperty("presenter", with: self.venueDetailPresenter())
        }
    }
}
