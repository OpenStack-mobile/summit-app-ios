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
    func getEventDetail(eventId: Int) -> SummitEvent
}

public class EventDetailInteractor: NSObject {
    var eventDataStore: IEventDataStore!
    var memberDataStore: IMemberDataStore!
    var session: ISession!
    let kCurrentMember = "currentMember"
    
    func getEventDetail(eventId: Int) -> SummitEvent {
        let event = eventDataStore.get(eventId)
        return event!
    }
    
    func addEventToMyScheduleAsync(eventId: Int, completionBlock : (SummitEvent?, NSError?) -> Void) {
        let currentMember = session.get(kCurrentMember) as! Member
        let event = eventDataStore.get(eventId)
        memberDataStore.addEventToMemberShedule(currentMember.id, event: event!) { (member, error) in
            if (error != nil) {
                self.session.set(self.kCurrentMember, value: member!)
            }
        }
    }
}
