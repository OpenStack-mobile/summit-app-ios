//
//  MemberProfileDTOAssembler.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMemberProfileDTOAssembler {
    func createDTO(member: Member, full: Bool) -> MemberProfileDTO
}

public class MemberProfileDTOAssembler: NSObject, IMemberProfileDTOAssembler {
    var ScheduleItemAssembler: IScheduleItemAssembler!

    public override init() {
        super.init()
    }
    
    public init(ScheduleItemAssembler: IScheduleItemAssembler) {
        self.ScheduleItemAssembler = ScheduleItemAssembler
    }
    
    public func createDTO(member: Member, full: Bool) -> MemberProfileDTO {
        let memberProfileDTO = MemberProfileDTO()
        memberProfileDTO.name = member.firstName + " " + member.lastName
        memberProfileDTO.title = member.title
        memberProfileDTO.pictureUrl = member.pictureUrl
        memberProfileDTO.bio = member.bio
        if (full) {
            memberProfileDTO.email = member.email
            memberProfileDTO.twitter = member.twitter
            memberProfileDTO.irc = member.irc
            
            var ScheduleItem: ScheduleItem
            if let attendeeRole = member.attendeeRole {
                for event in attendeeRole.scheduledEvents {
                    ScheduleItem = ScheduleItemAssembler.createDTO(event)
                    memberProfileDTO.scheduledEvents.append(ScheduleItem)
                }
            }
        }
        
        var ScheduleItem: ScheduleItem
        if let speakerRole = member.speakerRole {
            for presentation in speakerRole.presentations {
                ScheduleItem = ScheduleItemAssembler.createDTO(presentation.event)
                memberProfileDTO.presentations.append(ScheduleItem)
            }
        }
        
        return memberProfileDTO
    }
}
