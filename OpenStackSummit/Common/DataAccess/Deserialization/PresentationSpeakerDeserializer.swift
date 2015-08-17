//
//  PresentationSpeakerDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/17/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class PresentationSpeakerDeserializer: DeserializerProtocol {
    
    public func deserialize(json: JSON) -> BaseEntity {
        let presentationSpeaker = PresentationSpeaker()
    
        return presentationSpeaker
    }
}
