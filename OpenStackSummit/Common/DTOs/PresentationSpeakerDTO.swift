//
//  SpeakerDTO.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/1/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class PresentationSpeakerDTO: PersonListItemDTO {
    public var bio = ""
    public var presentations: [ScheduleItemDTO]?
}
