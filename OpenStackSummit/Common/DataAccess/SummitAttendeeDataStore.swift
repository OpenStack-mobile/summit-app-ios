//
//  SummitAttendeeDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/15/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ISummitAttendeeDataStore {
    func addFeedback(attendee: SummitAttendee, feedback: Feedback, completionBlock : (Feedback?, NSError?)->Void)
}

public class SummitAttendeeDataStore: GenericDataStore, ISummitAttendeeDataStore {
    var summitAttendeeRemoteDataStore: ISummitAttendeeRemoteDataStore!
    
    public func addFeedback(attendee: SummitAttendee, feedback: Feedback, completionBlock : (Feedback?, NSError?)->Void) {
        summitAttendeeRemoteDataStore.addFeedback(attendee, feedback: feedback) {(feedback, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            
            self.realm.write{
                attendee.feedback.append(feedback!)
            }
            completionBlock(feedback, error)
        }
    }
}
