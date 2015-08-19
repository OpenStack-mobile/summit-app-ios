//
//  MemberDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/18/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class MemberDeserializer: NSObject, DeserializerProtocol {
    public func deserialize(json: JSON) -> BaseEntity {
        let member = Member()
        
        return member
    }
}
