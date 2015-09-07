//
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
            definition.injectProperty("venueDetailWireframe", with: self.venueDetailWireframe())
        }
    }
    
    dynamic func venueDetailInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(VenueDetailInteractor.self) {
            (definition) in
            
        }
    }
        
    dynamic func venueDetailViewController() -> AnyObject {
        return TyphoonDefinition.withFactory(self.applicationAssembly.mainStoryboard(), selector: "instantiateViewControllerWithIdentifier:", parameters: {
            (factoryMethod) in
            
            factoryMethod.injectParameterWith("VenueDetailViewController")
        }, configuration: {
                (definition) in
                definition.injectProperty("presenter", with: self.venueDetailPresenter())
        })
    }
}
