//
//  SummitDataStoreMock.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/1/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import OpenStackSummit

class SummitDataStoreMock: NSObject, ISummitDataStore {
    
    var summit: Summit?
    
    init(summit: Summit?) {
        self.summit = summit
    }
    
    func getActiveLocal() -> Summit? {
        return summit
    }
    
    func getActive(completionBlock : (Summit?, NSError?) -> Void) {
        
    }
    func getSummitTypesLocal() -> [SummitType] {
        return []
    }
}
