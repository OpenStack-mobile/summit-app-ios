//
//  EventDetailInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IEventDetailInteractor : IScheduleableInteractor {
    func getEventDetail(eventId: Int) -> EventDetailDTO
    func addEventToMySchedule(eventId: Int, completionBlock : (EventDetailDTO?, NSError?) -> Void)
    func getFeedbackForEvent(eventId: Int, page: Int, objectsPerPage: Int, completionBlock : ([FeedbackDTO]?, NSError?) -> Void)
    func getMyFeedbackForEvent(eventId: Int) -> FeedbackDTO?
}

public class EventDetailInteractor: ScheduleableInteractor {
    var eventDetailDTOAssembler: IEventDetailDTOAssembler!
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
        summitAttendeeDataStore.addEventToMemberShedule(member.attendeeRole!, event: event!) { attendee, error in
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
                return
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
    
    public func getMyFeedbackForEvent(eventId: Int) -> FeedbackDTO? {
        var feedbackDTO: FeedbackDTO?
        if let currentMember = securityManager.getCurrentMember() {
            let feedback = currentMember.attendeeRole?.feedback.filter("event.id = %@", eventId).first
            if (feedback != nil) {
                feedbackDTO = feedbackDTOAssembler.createDTO(feedback!)
            }
        }
        return feedbackDTO
    }
}
