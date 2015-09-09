//
//  FeedbackDataStoreAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/9/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

public class FeedbackDataStoreAssembly: TyphoonAssembly {
    
    var feedbackRemoteDataStoreAssembly: FeedbackRemoteDataStoreAssembly!
    
    public dynamic func feedbackDataStore() -> AnyObject {
        
        return TyphoonDefinition.withClass(FeedbackDataStore.self) {
            (definition) in
            definition.injectProperty("feedbackRemoteDataStore", with: self.feedbackRemoteDataStoreAssembly.feedbackRemoteDataStore())
        }
    }
}
