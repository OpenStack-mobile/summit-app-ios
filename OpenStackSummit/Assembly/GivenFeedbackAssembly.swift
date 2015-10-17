//
//  feedbackGivenListAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

public class FeedbackGivenListAssembly: TyphoonAssembly {
    var applicationAssembly: ApplicationAssembly!
    var dtoAssemblersAssembly: DTOAssemblersAssembly!
    var securityManagerAssembly: SecurityManagerAssembly!
    
    dynamic func feedbackGivenListPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(FeedbackGivenListPresenter.self) {
            (definition) in
            
            definition.injectProperty("interactor", with: self.feedbackGivenListInteractor())
            definition.injectProperty("viewController", with: self.feedbackGivenListViewController())
        }
    }
    
    dynamic func feedbackGivenListInteractor() -> AnyObject {
        
        return TyphoonDefinition.withClass(FeedbackGivenListInteractor.self) {
            (definition) in
            definition.injectProperty("feedbackDTOAssembler", with: self.dtoAssemblersAssembly.feedbackDTOAssembler())
            definition.injectProperty("securityManager", with: self.securityManagerAssembly.securityManager())
        }
    }
    
    dynamic func feedbackGivenListViewController() -> AnyObject {
        return TyphoonDefinition.withClass(FeedbackGivenListViewController.self) {
            (definition) in
            
            definition.injectProperty("presenter", with: self.feedbackGivenListPresenter())
        }
    }

}
