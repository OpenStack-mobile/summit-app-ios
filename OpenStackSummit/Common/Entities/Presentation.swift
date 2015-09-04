//
//  Presentation.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Foundation
import RealmSwift

public class Presentation: BaseEntity {
    
    public let speakers = List<Member>()
    public dynamic var category: PresentationCategory!
    public let tags = List<Tag>()
    public var event: SummitEvent {
        return linkingObjects(SummitEvent.self, forProperty: "presentation").first!
    }
}
