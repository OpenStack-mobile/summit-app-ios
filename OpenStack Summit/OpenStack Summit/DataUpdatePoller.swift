//
//  DataUpdatePoller.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/12/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreSummit

extension DataUpdatePoller {
    
    static var shared: DataUpdatePoller {
        
        struct Static {
            
            static let poller: DataUpdatePoller = {
               
                let poller = DataUpdatePoller(storage: UserDefaultsDataUpdatePollerStorage(), store: Store.shared)
                
                SummitManager.shared.summit.observe { poller.summit = $0 }
                
                return poller
            }()
        }
        
        return Static.poller
    }
}