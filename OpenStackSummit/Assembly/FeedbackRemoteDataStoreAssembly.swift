//
//  FeedbackRemoteDataStoreAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/9/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

public class FeedbackRemoteDataStoreAssembly: TyphoonAssembly {
    
    public dynamic func feedbackRemoteDataStore() -> AnyObject {
        
        return TyphoonDefinition.withClass(FeedbackRemoteDataStore.self) {
            (definition) in
        }
    }
}