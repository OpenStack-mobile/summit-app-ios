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
        
    public func getFeedbackForEvent(eventId: Int, page: Int, objectsPerPage: Int, completionBlock : ([FeedbackDTO]?, NSError?) -> Void) {
        if !reachability.isConnectedToNetwork() {
            let error = NSError(domain: "There is no network connectivity. Can't load event feedback", code: 11001, userInfo: nil)
            completionBlock(nil, error)
            return
        }
        
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
