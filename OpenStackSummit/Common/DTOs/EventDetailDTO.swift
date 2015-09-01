//
//  SummitEventDTO.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/1/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class EventDetailDTO: NSObject {
    public var title = ""
    public var eventDescription = ""
    public var date = ""
    public var location = ""
    public var finished = false
    public var category = ""
    public var credentials = ""
    public var tags = ""
    public var speakers = [SpeakerDTO]()
}