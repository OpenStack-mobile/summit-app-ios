//
//  EventDetailInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IEventDetailInteractor {
    func getEventDetail(eventId: Int) -> EventDetailDTO
    func addEventToMySchedule(eventId: Int, completionBlock : (EventDetailDTO?, NSError?) -> Void)
}

public class EventDetailInteractor: NSObject {
    var eventDataStore: IEventDataStore!
    var memberDataStore: IMemberDataStore!
    var session: ISession!
    var eventDetailDTOAssembler: IEventDetailDTOAssembler!
    let kCurrentMember = "currentMember"
    
    public func getEventDetail(eventId: Int) -> EventDetailDTO {
        let event = eventDataStore.getByIdFromLocal(eventId)
        let eventDetailDTO = eventDetailDTOAssembler.createDTO(event!)
        return eventDetailDTO
    }
    
    public func addEventToMySchedule(eventId: Int, completionBlock : (EventDetailDTO?, NSError?) -> Void) {
        let member = session.get(kCurrentMember) as! MemberDTO
        let event = eventDataStore.getByIdFromLocal(eventId)
        let eventDetailDTO = eventDetailDTOAssembler.createDTO(event!)
        memberDataStore.addEventToMemberShedule(member.id, event: event!) { member, error in
            if (error == nil) {
                self.session.set(self.kCurrentMember, value: member!)
                completionBlock(eventDetailDTO, nil)
            }
        }
    }
}
