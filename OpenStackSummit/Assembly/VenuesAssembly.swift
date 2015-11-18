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
    var venuesMapsAssembly: VenuesMapsAssembly!
    var venueListAssembly: VenueListAssembly!
    
    dynamic func venuesViewController() -> AnyObject {
        return TyphoonDefinition.withClass(VenuesViewController.self) {
            (definition) in
            
            definition.injectProperty("venuesMapViewController", with: self.venuesMapsAssembly.venuesMapViewController())
            definition.injectProperty("venueListViewController", with: self.venueListAssembly.venueListViewController())
        }
    }
}