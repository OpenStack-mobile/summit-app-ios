//
//  RemoteDataStoresAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

class RemoteDataStoresAssembly: TyphoonAssembly {
    
    var dataStoreAssembly : DataStoreAssembly!
    var httpFactoryAssembly: HttpFactoryAssembly!
    
    dynamic func presentationSpeakerRemoteDataStore() -> AnyObject {
        
        return TyphoonDefinition.withClass(PresentationSpeakerRemoteDataStore.self) {
            (definition) in
            definition.injectProperty("deserializerFactory", with: self.dataStoreAssembly.deserializerFactory())
            definition.injectProperty("httpFactory", with: self.httpFactoryAssembly.httpFactory())
        }
    }
    
    dynamic func summitAttendeeRemoteDataStore() -> AnyObject {
        
        return TyphoonDefinition.withClass(SummitAttendeeRemoteDataStore.self) {
            (definition) in
            definition.injectProperty("deserializerFactory", with: self.dataStoreAssembly.deserializerFactory())
            definition.injectProperty("httpFactory", with: self.httpFactoryAssembly.httpFactory())
        }
    }
    
    dynamic func memberRemoteDataStore() -> AnyObject {
        
        return TyphoonDefinition.withClass(MemberRemoteDataStore.self) {
            (definition) in
            definition.injectProperty("deserializerFactory", with: self.dataStoreAssembly.deserializerFactory())
            definition.injectProperty("httpFactory", with: self.httpFactoryAssembly.httpFactory())
        }
    }
    
    dynamic func feedbackRemoteDataStore() -> AnyObject {
        
        return TyphoonDefinition.withClass(FeedbackRemoteDataStore.self) {
            (definition) in
        }
    }
}
