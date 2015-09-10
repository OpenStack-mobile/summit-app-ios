//
//  VenueRoomDetailAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

public class VenueRoomDetailAssembly: TyphoonAssembly {
    var applicationAssembly: ApplicationAssembly!
    
    dynamic func venueRoomDetailWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(VenueRoomDetailWireframe.self) {
            (definition) in
            
            definition.injectProperty("venueRoomDetailViewController", with: self.venueRoomDetailViewController())
        }
    }
    
    dynamic func venueRoomDetailPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(VenueRoomDetailPresenter.self) {
            (definition) in
            
            definition.injectProperty("interactor", with: self.venueRoomDetailInteractor())
            definition.injectProperty("viewController", with: self.venueRoomDetailViewController())
            definition.injectProperty("wireframe", with: self.venueRoomDetailWireframe())
        }
    }
    
    dynamic func venueRoomDetailDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(VenueRoomDetailDTOAssembler.self) {
            (definition) in
            definition.injectProperty("scheduleItemDTOAssembler", with: self.venueRoomsSheduleItemDTOAssembler())
        }
    }

    dynamic func venueRoomsSheduleItemDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(ScheduleItemDTOAssembler.self)
    }
    
    dynamic func venueRoomDetailInteractor() -> AnyObject {
        
        return TyphoonDefinition.withClass(VenueRoomDetailInteractor.self) {
            (definition) in
            definition.injectProperty("venueRoomDetailDTOAssembler", with: self.venueRoomDetailDTOAssembler())            
        }
    }
    
    dynamic func venueRoomDetailViewController() -> AnyObject {
        return TyphoonDefinition.withFactory(self.applicationAssembly.mainStoryboard(), selector: "instantiateViewControllerWithIdentifier:", parameters: {
            (factoryMethod) in
            
            factoryMethod.injectParameterWith("VenueRoomDetailViewController")
            }, configuration: {
                (definition) in
                definition.injectProperty("presenter", with: self.venueRoomDetailPresenter())
        })
    }
}