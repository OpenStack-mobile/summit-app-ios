//
//  ScheduleablePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class ScheduleablePresenter: NSObject {
    
    var isOperationOngoing = false
    
    
    func toggleScheduledStatusForEvent(event: ScheduleItemDTO, scheduleableView: IScheduleableView, interactor: IScheduleableInteractor, completionBlock: ((NSError?) -> Void)?) {
        let isScheduled = interactor.isEventScheduledByLoggedMember(event.id)
        if (isScheduled) {
            removeEventFromSchedule(event, scheduleableView: scheduleableView, interactor: interactor, completionBlock: completionBlock)
        }
        else {
            addEventToSchedule(event, scheduleableView: scheduleableView, interactor: interactor, completionBlock: completionBlock)
        }
    }
    
    func addEventToSchedule(event: ScheduleItemDTO, scheduleableView: IScheduleableView, interactor: IScheduleableInteractor, completionBlock: ((NSError?) -> Void)?) {
        if isOperationOngoing {
            return
        }
        
        scheduleableView.scheduled = true
        
        isOperationOngoing = true
        
        interactor.addEventToLoggedInMemberSchedule(event.id) { error in
            dispatch_async(dispatch_get_main_queue(),{
                if (error != nil) {
                    scheduleableView.scheduled = !scheduleableView.scheduled
                }
                
                self.isOperationOngoing = false
                
                if (completionBlock != nil) {
                    completionBlock!(error)
                }
            })
        }
    }
    
    func removeEventFromSchedule(event: ScheduleItemDTO, scheduleableView: IScheduleableView, interactor: IScheduleableInteractor, completionBlock: ((NSError?) -> Void)?) {
        if isOperationOngoing {
            return
        }

        scheduleableView.scheduled = false

        isOperationOngoing = true
       
        interactor.removeEventFromLoggedInMemberSchedule(event.id) { error in
            dispatch_async(dispatch_get_main_queue(),{
                if (error != nil) {
                    scheduleableView.scheduled = !scheduleableView.scheduled
                }
                
                self.isOperationOngoing = false

                if (completionBlock != nil) {
                    completionBlock!(error)
                }
            })
        }
    }

}
