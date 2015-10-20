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
    func getFeedbackForEvent(eventId: Int, page: Int, objectsPerPage: Int, completionBlock : ([FeedbackDTO]?, NSError?) -> Void)
}

public class EventDetailInteractor: NSObject {
    var eventDataStore: IEventDataStore!
    var memberDataStore: IMemberDataStore!
    var eventDetailDTOAssembler: IEventDetailDTOAssembler!
    var securityManager: SecurityManager!
    var feedbackDTOAssembler: IFeedbackDTOAssembler!
    
    public func getEventDetail(eventId: Int) -> EventDetailDTO {
        let event = eventDataStore.getByIdLocal(eventId)
        let eventDetailDTO = eventDetailDTOAssembler.createDTO(event!)
        return eventDetailDTO
    }
    
    public func addEventToMySchedule(eventId: Int, completionBlock : (EventDetailDTO?, NSError?) -> Void) {
        guard let member = securityManager.getCurrentMember() else {
            let error: NSError? = NSError(domain: "There is no logged user", code: 1, userInfo: nil)
            completionBlock(nil, error)
            return
        }
        let event = eventDataStore.getByIdLocal(eventId)
        let eventDetailDTO = eventDetailDTOAssembler.createDTO(event!)
        memberDataStore.addEventToMemberShedule(member, event: event!) { member, error in
            if (error != nil) {
                completionBlock(nil, error)
            }
            completionBlock(eventDetailDTO, error)
        }
    }
    
    public func getFeedbackForEvent(eventId: Int, page: Int, objectsPerPage: Int, completionBlock : ([FeedbackDTO]?, NSError?) -> Void) {
        eventDataStore.getFeedback(eventId, page: page, objectsPerPage: objectsPerPage) { (feedbackList, error) in
            if (error != nil) {
                completionBlock(nil, error)
            }

            var feedbackDTO: FeedbackDTO
            var dtos: [FeedbackDTO] = []
            for feedback in feedbackList! {
                feedbackDTO = self.feedbackDTOAssembler.createDTO(feedback)
                dtos.append(feedbackDTO)
            }
            
            completionBlock(dtos, error)
        }
    }

}
