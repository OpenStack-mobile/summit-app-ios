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
    dynamic func venueListWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(VenueListWireframe.self) {
            (definition) in
            
            definition.injectProperty("venueListViewController", with: self.venueListViewController())
        }
    }
    
    dynamic func venueListPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(VenueListPresenter.self) {
            (definition) in
            
            //definition.injectProperty("interactor", with: self.venueListInteractor())
            //definition.injectProperty("venueListDTOAssembler", with: self.venueListDTOAssembler())
            definition.injectProperty("viewController", with: self.venueListViewController())
            definition.injectProperty("venueListWireframe", with: self.venueListWireframe())
        }
    }
    
    /*dynamic func venueListDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(VenueListDTOAssembler.self)
    }*/
    
    dynamic func venueListInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(VenueListInteractor.self) {
            (definition) in
            
        }
    }
    
    /*dynamic func venueListDataStore() -> AnyObject {
        return TyphoonDefinition.withClass(MemberDataStore.self)
    }*/
    
    dynamic func venueListViewController() -> AnyObject {
        return TyphoonDefinition.withClass(VenueListViewController.self) {
            (definition) in
            
            definition.injectProperty("presenter", with: self.venueListPresenter())
        }
    }
}
