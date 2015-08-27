//
//  Track.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import RealmSwift

public class Track: BaseEntity {
    public dynamic var name = ""
    public let events = List<SummitEvent>()
}
