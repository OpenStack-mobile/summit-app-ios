//
//  MemberDTO.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/17/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class MemberDTO: PersonDTO {
    public var speakerRole: PresentationSpeakerDTO?
    public var attendeeRole: SummitAttendeeDTO?
}
