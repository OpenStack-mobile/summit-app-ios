//
//  EventDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/17/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class EventDeserializer: DeserializerProtocol {

    public func deserialize(json: JSON) -> BaseEntity {
        let summitEvent = SummitEvent()
        
        return SummitEvent()
    }
}
