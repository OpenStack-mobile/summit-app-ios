//
//  ReachabilityMock.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import OpenStackSummit

class ReachabilityMock: NSObject, IReachability {
    var isConnected = true
    
    init(isConnected: Bool) {
        self.isConnected = isConnected
    }
    
    func isConnectedToNetwork() -> Bool {
        return isConnected
    }
}
