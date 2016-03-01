//
//  SpeakerPresentationsPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/20/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ISpeakerPresentationsPresenter: ISchedulePresenter {
    var speakerId: Int { get set }
}

public class SpeakerPresentationsPresenter: SchedulePresenter, ISpeakerPresentationsPresenter {
    
    weak var viewController : IScheduleViewController! {
        get {
            return internalViewController
        }
        set {
            internalViewController = newValue
        }
    }
    
    var interactor : ISpeakerPresentationsInteractor! {
        get {
            return internalInteractor as! ISpeakerPresentationsInteractor
        }
        set {
            internalInteractor = newValue
        }
    }
    
    var wireframe : IScheduleWireframe! {
        get {
            return internalWireframe
        }
        set {
            internalWireframe = newValue
        }
    }
    
    public var speakerId = 0
    
    override func getScheduledEventsActiveDatesSince(startDate: NSDate, to endDate: NSDate, withInteractor interactor: IScheduleInteractor) -> [NSDate] {
        let activeDates = (interactor as! ISpeakerPresentationsInteractor).getSpeakerPresentationsDates(speakerId, startDate: startDate, endDate: endDate)
        return activeDates
    }
    
    override func getScheduledEventsFrom(startDate: NSDate, to endDate: NSDate, withInteractor interactor: IScheduleInteractor) -> [ScheduleItemDTO] {
        let events = (interactor as! ISpeakerPresentationsInteractor).getSpeakerPresentations(speakerId, startDate: startDate, endDate: endDate)
        return events
    }
}
