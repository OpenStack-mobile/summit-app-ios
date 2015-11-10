//
//  EventDetailPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IEventDetailPresenter: IBasePresenter {
    func viewLoad()
    var eventId: Int { get set }
    
    func leaveFeedback()
    func addEventToMySchedule()
    func getSpeakersCount()->Int
    func getFeedbackCount()->Int
    func buildSpeakerCell(cell: IPersonTableViewCell, index: Int)
    func buildFeedbackCell(cell: IFeedbackGivenTableViewCell, index: Int)
    func showSpeakerProfile(index: Int)
    func loadFeedback()
    func showVenueDetail()
    func viewUnload()
    func toggleScheduledStatus()
}

public class EventDetailPresenter: ScheduleablePresenter, IEventDetailPresenter {
    weak var viewController : IEventDetailViewController!
    var interactor : IEventDetailInteractor!
    var wireframe: IEventDetailWireframe!
    public var eventId = 0
    private var event: EventDetailDTO!
    private var myFeedbackForEvent: FeedbackDTO?
    private var feedbackPage = 1
    private var feedbackObjectsPerPage = 10
    private var feedbackList = [FeedbackDTO]()
    private var loadedAllFeedback: Bool!
    
    public func viewLoad() {
        feedbackPage = 1
        feedbackList.removeAll()
        event = interactor.getEventDetail(eventId)
        myFeedbackForEvent = interactor.getMyFeedbackForEvent(eventId)
            
        viewController.eventTitle = event.name
        viewController.eventDescription = event.eventDescription
        viewController.location = event.location
        viewController.date = event.date
        viewController.sponsors = event.sponsors
        viewController.summitTypes = event.credentials
        viewController.allowFeedback = event.allowFeedback && interactor.isMemberLoggedIn()
        viewController.hasSpeakers = event.speakers.count > 0
        viewController.hasAnyFeedback = false
        viewController.reloadSpeakersData()
        viewController.scheduled = interactor.isEventScheduledByLoggedMember(eventId)
        viewController.hasMyFeedback = myFeedbackForEvent != nil
        viewController.isScheduledStatusVisible = interactor.isMemberLoggedIn()
        viewController.tags = event.tags
        
        if (myFeedbackForEvent != nil) {
            viewController.myFeedbackDate = myFeedbackForEvent!.date
            viewController.myFeedbackRate = Double(myFeedbackForEvent!.rate)
            viewController.myFeedbackReview = myFeedbackForEvent!.review
        }
        
        loadFeedback()
    }
    
    public func loadFeedback() {
        interactor.getFeedbackForEvent(self.eventId, page: self.feedbackPage, objectsPerPage: self.feedbackObjectsPerPage) { (feedbackPage, error) in
            dispatch_async(dispatch_get_main_queue(),{
                
                if (error != nil) {
                    self.viewController.showErrorMessage(error!)
                    return
                }
                
                self.feedbackList.appendContentsOf(feedbackPage!)
                self.viewController.reloadFeedbackData()
                self.viewController.hasAnyFeedback = self.feedbackList.count > 0
                self.feedbackPage++
                self.viewController.loadedAllFeedback = feedbackPage!.count < self.feedbackObjectsPerPage
            })
        }
    }
    
    public func addEventToMySchedule() {
        interactor.addEventToMySchedule(eventId) { (event, error) in
            dispatch_async(dispatch_get_main_queue(),{
                if (error != nil) {
                    self.viewController.showErrorMessage(error!)
                }
                self.viewController.didAddEventToMySchedule(event!)
            })
        }
    }
    
    public func getSpeakersCount()->Int {
        return event.speakers.count
    }
    
    public func getFeedbackCount()->Int {
        return feedbackList.count
    }
    
    public func buildSpeakerCell(cell: IPersonTableViewCell, index: Int) {
        let speaker = event.speakers[index]
        cell.name = speaker.name
        cell.title = speaker.title
        cell.picUrl = speaker.pictureUrl
    }
    
    public func buildFeedbackCell(cell: IFeedbackGivenTableViewCell, index: Int) {
        let feedback = feedbackList[index]
        cell.eventName = feedback.eventName
        cell.owner = feedback.owner
        cell.rate = Double(feedback.rate)
        cell.review = feedback.review
        cell.date = feedback.date
    }
    
    public func leaveFeedback() {
        wireframe.showFeedbackEdit(eventId)
    }
    
    public func showSpeakerProfile(index: Int) {
        let speaker = event.speakers[index]
        wireframe.showSpeakerProfile(speaker.id)
    }
    
    public func showVenueDetail() {
        if event.venueRoomId != nil {
            wireframe.showVenueRoomDetail(event.venueRoomId!)
        }
        else if event.venueId != nil {
            wireframe.showVenueDetail(event.venueId!)
        }
    }
    
    public func toggleScheduledStatus() {
        toggleScheduledStatusForEvent(event, scheduleableView: viewController, interactor: interactor) { error in
            if (error != nil) {
                self.viewController.showErrorMessage(error!)
            }
        }
    }
    
    public func viewUnload() {
    }
}
