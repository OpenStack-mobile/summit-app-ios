//
//  Summit.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Foundation
import RealmSwift

public class Summit: BaseEntity {
    public dynamic var name = ""
    public let types = List<SummitType>()
    public let venues = List<Venue>()
    public let events = List<SummitEvent>()
}
