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

    public dynamic var summitEvent : SummitEvent!
    public let speakers = List<PresentationSpeaker>()
    public dynamic var category: PresentationCategory!
    public let tags = List<Tag>()
}
