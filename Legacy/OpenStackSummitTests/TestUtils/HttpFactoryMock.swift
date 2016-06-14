//
//  HttpFactoryMock.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/26/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import OpenStackSummit
import AeroGearHttp

public class HttpFactoryMock: HttpFactory {
    
    var httpServiceAccount: Http?
    var httpOIDC: Http?
    
    public init(httpServiceAccount: Http?, httpOIDC: Http?) {
        self.httpServiceAccount = httpServiceAccount
        self.httpOIDC = httpOIDC
    }
    
    public override func create(type: HttpType) -> Http {
        return type == HttpType.ServiceAccount ? httpServiceAccount! : httpOIDC!
    }
}
