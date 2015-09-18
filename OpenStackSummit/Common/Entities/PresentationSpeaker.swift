//
//  PresentationSpeaker.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Foundation
import RealmSwift

public class PresentationSpeaker: Person {

    public dynamic var isPresentationOwner = false
    public dynamic var memberId = 0
    
    public var presentations: [Presentation] {
        return linkingObjects(Presentation.self, forProperty: "speakers")
    }
    
}
