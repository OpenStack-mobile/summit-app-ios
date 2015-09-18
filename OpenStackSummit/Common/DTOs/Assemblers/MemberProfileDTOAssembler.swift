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

public class MemberProfileDTOAssembler: NSObject {
    var scheduleItemDTOAssembler: IScheduleItemDTOAssembler!

    public override init() {
        super.init()
    }
    
    public init(scheduleItemDTOAssembler: IScheduleItemDTOAssembler) {
        self.scheduleItemDTOAssembler = scheduleItemDTOAssembler
    }
    
    public func createDTO(member: Member, full: Bool) -> MemberProfileDTO {
        let memberProfileDTO = MemberProfileDTO()
        /*memberProfileDTO.name = member.firstName + " " + member.lastName
        memberProfileDTO.title = member.jobTitle
        memberProfileDTO.pictureUrl = member.pictureUrl
        memberProfileDTO.bio = member.bio
        if (full) {
            memberProfileDTO.email = member.email
            memberProfileDTO.location = member.location
            memberProfileDTO.twitter = member.twitter
            memberProfileDTO.irc = member.IRC
            
            var scheduleItemDTO: ScheduleItemDTO
            for event in member.scheduledEvents {
                scheduleItemDTO = scheduleItemDTOAssembler.createDTO(event)
                memberProfileDTO.scheduledEvents.append(scheduleItemDTO)
            }
        }
        
        var scheduleItemDTO: ScheduleItemDTO
        for presentation in member.presentations {
            scheduleItemDTO = scheduleItemDTOAssembler.createDTO(presentation.event)
            memberProfileDTO.presentations.append(scheduleItemDTO)
        }*/
        
        return memberProfileDTO
    }
}
