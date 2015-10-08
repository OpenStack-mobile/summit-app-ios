//
//  MemberDataStoreAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/20/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

public class MemberDataStoreAssembly: TyphoonAssembly {
    
    var remoteDataStoresAssembly: RemoteDataStoresAssembly!
    
    public dynamic func memberDataStore() -> AnyObject {
        
        return TyphoonDefinition.withClass(MemberDataStore.self) {
            (definition) in
            definition.injectProperty("memberRemoteStorage", with: self.remoteDataStoresAssembly.memberRemoteDataStore())
        }
    }    
}
