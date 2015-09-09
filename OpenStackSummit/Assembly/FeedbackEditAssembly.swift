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
    var feedbackDataStoreAssembly: FeedbackDataStoreAssembly!
    
    dynamic func feedbackEditWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(FeedbackEditWireframe.self) {
            (definition) in
        }
    }
    
    dynamic func feedbackEditPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(FeedbackEditPresenter.self) {
            (definition) in
            
            definition.injectProperty("interactor", with: self.feedbackEditInteractor())
            definition.injectProperty("viewController", with: self.feedbackEditViewController())
            definition.injectProperty("wireframe", with: self.feedbackEditWireframe())
            definition.injectProperty("feedbackDTOAssembler", with: self.feedbackDTOAssembler())
        }
    }
    
    dynamic func feedbackDTOAssembler() -> AnyObject {
        return TyphoonDefinition.withClass(FeedbackDTOAssembler.self)
    }
    
    dynamic func feedbackEditInteractor() -> AnyObject {
        
        return TyphoonDefinition.withClass(FeedbackEditInteractor.self) {
            (definition) in

            definition.injectProperty("feedbackDataStore", with: self.feedbackDataStoreAssembly.feedbackDataStore())
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