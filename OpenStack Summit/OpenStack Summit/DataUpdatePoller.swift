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
                
                poller.summit = SummitManager.shared.summit.value
                
                // we never deinit, so no need to remove observer
                let _ = SummitManager.shared.summit.observe { poller.summit = $0.0 }
                
                return poller
            }()
        }
        
        return Static.poller
    }
}
