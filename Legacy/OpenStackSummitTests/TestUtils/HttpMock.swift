//
//  HttpMock.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/26/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import OpenStackSummit
import AeroGearHttp

public class HttpMock: Http {
    
    var responseObject: AnyObject?
    var error: NSError?

    
    public init(responseObject: AnyObject?, error: NSError?) {
        self.responseObject = responseObject
        self.error = error
    }
    
    public override func GET(url: String, parameters: [String : AnyObject]?, credential: NSURLCredential?, completionHandler: CompletionBlock) {
        completionHandler(responseObject, error)
    }
}
