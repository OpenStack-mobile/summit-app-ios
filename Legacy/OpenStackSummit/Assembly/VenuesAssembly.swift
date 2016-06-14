//
//  VenuesAssembly.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/18/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//


import UIKit
import Typhoon

class VenuesAssembly: TyphoonAssembly {
    var applicationAssembly: ApplicationAssembly!
    var venuesMapsAssembly: VenuesMapsAssembly!
    var venueListAssembly: VenueListAssembly!
    
    dynamic func venuesWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(VenuesWireframe.self) {
            (definition) in
            
            definition.injectProperty("navigationController", with: self.applicationAssembly.navigationController())
            definition.injectProperty("revealViewController", with: self.applicationAssembly.revealViewController())
            definition.injectProperty("venuesViewController", with: self.venuesViewController())
        }
    }
    
    dynamic func venuesPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(VenuesPresenter.self) {
            (definition) in
            
            definition.injectProperty("venuesMapViewController", with: self.venuesMapsAssembly.venuesMapViewController())
            definition.injectProperty("venueListViewController", with: self.venueListAssembly.venueListViewController())
        }
    }
    
    dynamic func venuesViewController() -> AnyObject {
        return TyphoonDefinition.withClass(VenuesViewController.self) {
            (definition) in
            
            definition.injectProperty("presenter", with: self.venuesPresenter())
        }
    }
}