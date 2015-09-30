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
    var eventDetailDTOAssembler: IEventDetailDTOAssembler!
    var securityManager: SecurityManager!
    
    public func getEventDetail(eventId: Int) -> EventDetailDTO {
        let event = eventDataStore.getByIdFromLocal(eventId)
        let eventDetailDTO = eventDetailDTOAssembler.createDTO(event!)
        return eventDetailDTO
    }
    
    public func addEventToMySchedule(eventId: Int, completionBlock : (EventDetailDTO?, NSError?) -> Void) {
        guard let member = securityManager.getCurrentMember() else {
            let error: NSError? = NSError(domain: "There is no logged user", code: 1, userInfo: nil)
            completionBlock(nil, error)
            return
        }
        let event = eventDataStore.getByIdFromLocal(eventId)
        let eventDetailDTO = eventDetailDTOAssembler.createDTO(event!)
        memberDataStore.addEventToMemberShedule(member, event: event!) { member, error in
            if (error != nil) {
                completionBlock(nil, error)
            }
            completionBlock(eventDetailDTO, error)
        }
    }
}
