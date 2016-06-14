//
//  FeedbackEditAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/9/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

public class FeedbackEditAssembly: TyphoonAssembly {
    var applicationAssembly: ApplicationAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    var dtoAssemblersAssembly: DTOAssemblersAssembly!
    var securityManagerAssembly: SecurityManagerAssembly!

    dynamic func feedbackEditWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(FeedbackEditWireframe.self) {
            (definition) in
            
            definition.injectProperty("feedbackEditViewController", with: self.feedbackEditViewController())
        }
    }
    
    dynamic func feedbackEditPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(FeedbackEditPresenter.self) {
            (definition) in
            
            definition.injectProperty("interactor", with: self.feedbackEditInteractor())
            definition.injectProperty("viewController", with: self.feedbackEditViewController())
            definition.injectProperty("wireframe", with: self.feedbackEditWireframe())
        }
    }
    
    dynamic func feedbackEditInteractor() -> AnyObject {
        
        return TyphoonDefinition.withClass(FeedbackEditInteractor.self) {
            (definition) in

            definition.injectProperty("genericDataStore", with: self.dataStoreAssembly.genericDataStore())
            definition.injectProperty("summitAttendeeDataStore", with: self.dataStoreAssembly.summitAttendeeDataStore())
            definition.injectProperty("feedbackDTOAssembler", with: self.dtoAssemblersAssembly.feedbackDTOAssembler())
            definition.injectProperty("securityManager", with: self.securityManagerAssembly.securityManager())
            definition.injectProperty("reachability", with: self.applicationAssembly.reachability())
        }
    }
    
    dynamic func feedbackEditViewController() -> AnyObject {
        return TyphoonDefinition.withFactory(self.applicationAssembly.mainStoryboard(), selector: "instantiateViewControllerWithIdentifier:", parameters: {
            (factoryMethod) in
            
            factoryMethod.injectParameterWith("FeedbackEditViewController")
            }, configuration: {
                (definition) in
                definition.injectProperty("presenter", with: self.feedbackEditPresenter())
        })
    }
}