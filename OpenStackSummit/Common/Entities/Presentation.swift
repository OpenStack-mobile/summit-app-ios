//
//  Presentation.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Foundation
import RealmSwift

public class Presentation: RealmEntity {

    public dynamic var level = ""
    public dynamic var track: Track?
    public dynamic var moderator: PresentationSpeaker?
    public let speakers = List<PresentationSpeaker>()
    
    
    public var event: SummitEvent { return SummitEvent()
        //return self.linkingObjects(SummitEvent.self, forProperty: "presentation").first!
    }
}
