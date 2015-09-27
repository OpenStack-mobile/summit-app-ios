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
    
    var http: Http
    
    public init(http: Http) {
        self.http = http
    }
    
    public override func create(type: HttpType) -> Http {
        return http
    }
}
