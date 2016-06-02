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
    
    public var presentations: [Presentation] { return []
        //return linkingObjects(Presentation.self, forProperty: "speakers")
    }
    
}
