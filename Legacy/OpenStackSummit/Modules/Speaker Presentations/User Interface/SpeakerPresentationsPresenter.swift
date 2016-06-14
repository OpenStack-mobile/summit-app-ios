//
//  SpeakerPresentationsPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/20/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public protocol SpeakerPresentationsPresenterProtocol: SchedulePresenterProtocol {
    
    var speakerId: Int { get set }
}

public class SpeakerPresentationsPresenter: SchedulePresenter, SpeakerPresentationsPresenterProtocol {
    
    weak var viewController : ScheduleViewController! {
        get {
            return internalViewController
        }
        set {
            internalViewController = newValue
        }
    }
    
    var interactor : SpeakerPresentationsInteractor! {
        get {
            return internalInteractor as! ISpeakerPresentationsInteractor
        }
        set {
            internalInteractor = newValue
        }
    }
    
    var wireframe : ScheduleWireframe {
        get {
            return internalWireframe
        }
        set {
            internalWireframe = newValue
        }
    }
    
    public var speakerId = 0
    
    override func getScheduleAvailableDatesFrom(startDate: NSDate, to endDate: NSDate, withInteractor interactor: ScheduleInteractorProtocol) -> [NSDate] {
        let availableDates = (interactor as! SpeakerPresentationsInteractor).getSpeakerPresentationsDates(speakerId, startDate: startDate, endDate: endDate)
        return availableDates
    }
    
    override func getScheduledEventsFrom(startDate: NSDate, to endDate: NSDate, withInteractor interactor: ScheduleInteractorProtocol) -> [ScheduleItem] {
        let events = (interactor as! SpeakerPresentationsInteractor).getSpeakerPresentations(speakerId, startDate: startDate, endDate: endDate)
        return events
    }
}
