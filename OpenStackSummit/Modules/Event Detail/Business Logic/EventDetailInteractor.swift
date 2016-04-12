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
            // for now we don't want to show this annoying pop up since during summit they could be under hard connectivity situation
            /*let error = NSError(domain: "There is no network connectivity. Can't load event feedback", code: 11001, userInfo: nil)*/
            completionBlock(nil, nil)
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
}
