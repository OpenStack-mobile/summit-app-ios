//
//  EventDetailPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IEventDetailPresenter {
    func viewLoad()
    var eventId: Int { get set }
    
    func leaveFeedback()
    func getSpeakersCount()->Int
    func getFeedbackCount()->Int
    func buildSpeakerCell(cell: IPeopleTableViewCell, index: Int)
    func buildFeedbackCell(cell: IFeedbackTableViewCell, index: Int)
    func showSpeakerProfile(index: Int)
    func loadFeedback()
    func showVenueDetail()
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
    private var feedbackObjectsPerPage = 5
    private var feedbackList = [FeedbackDTO]()
    private var loadedAllFeedback = false
    private var loadingFeedback = false
    
    public func viewLoad() {
        loadedAllFeedback = false
        loadingFeedback = false
        feedbackPage = 1
        feedbackList.removeAll()
        event = interactor.getEventDetail(eventId)
            
        viewController.eventTitle = event.name
        viewController.eventDescription = event.eventDescription
        viewController.location = event.location
        viewController.date = event.dateTime
        viewController.sponsors = event.sponsors
        viewController.summitTypes = event.summitTypes
        viewController.allowFeedback = event.allowFeedback && event.finished && interactor.isLoggedInAndConfirmedAttendee() && myFeedbackForEvent == nil
        viewController.hasSpeakers = event.speakers.count > 0
        viewController.hasAnyFeedback = false
        viewController.reloadSpeakersData()
        viewController.scheduled = interactor.isEventScheduledByLoggedMember(eventId)
        viewController.isScheduledStatusVisible = interactor.isLoggedInAndConfirmedAttendee()
        viewController.tags = event.tags
        viewController.level = event.level
        viewController.track = event.track
        viewController.hasAverageFeedback = event.averageFeedback != 0
        viewController.averageFeedback = event.averageFeedback
        
        if event.allowFeedback && event.finished {
            loadFeedback()
        }
    }
    
    public func loadFeedback() {
        if (loadingFeedback || loadedAllFeedback) {
            return
        }
        
        loadingFeedback = true
        viewController.showFeedbackListActivityIndicator()
        interactor.getFeedbackForEvent(self.eventId, page: self.feedbackPage, objectsPerPage: self.feedbackObjectsPerPage) { (feedbackPage, error) in
            dispatch_async(dispatch_get_main_queue(),{
                defer {
                    self.loadingFeedback = false
                    self.viewController.hideFeedbackListActivityIndicator()
                }
                
                if (error != nil) {
                    self.viewController.showErrorMessage(error!)
                    return
                }
                
                if let feedbackPage = feedbackPage {
                    var feedbackPageWithoutMe = [FeedbackDTO]()
                    for feedbackDTO in feedbackPage {
                        if self.myFeedbackForEvent == nil || (feedbackDTO.owner != self.myFeedbackForEvent!.owner) {
                            feedbackPageWithoutMe.append(feedbackDTO)
                        }
                    }
                    
                    
                    self.feedbackList.appendContentsOf(feedbackPageWithoutMe)
                    self.viewController.reloadFeedbackData()
                    self.viewController.hasAnyFeedback = self.feedbackList.count > 0
                    self.feedbackPage += 1
                    self.loadedAllFeedback = feedbackPage.count < self.feedbackObjectsPerPage
                }
            })
        }
    }
    
    public func getSpeakersCount()->Int {
        return event.speakers.count
    }
    
    public func getFeedbackCount()->Int {
        return feedbackList.count
    }
    
    public func buildSpeakerCell(cell: IPeopleTableViewCell, index: Int) {
        let speaker = event.speakers[index]
        cell.name = speaker.name
        cell.title = speaker.title
        cell.picUrl = speaker.pictureUrl
        cell.isModerator = event.moderator != nil && speaker.id == event.moderator?.id
    }
    
    public func buildFeedbackCell(cell: IFeedbackTableViewCell, index: Int) {
        let feedback = feedbackList[index]
        cell.eventName = ""
        cell.owner = feedback.owner
        cell.rate = Double(feedback.rate)
        cell.review = feedback.review
        cell.date = feedback.date
    }
    
    public func leaveFeedback() {
        wireframe.showFeedbackEdit(eventId, fromViewController: viewController)
    }
    
    public func showSpeakerProfile(index: Int) {
        let speaker = event.speakers[index]
        wireframe.showSpeakerProfile(speaker.id, fromViewController: viewController)
    }
    
    public func showVenueDetail() {
        if event.venueId != nil { 
            wireframe.showVenueDetail(event.venueId!, fromViewController: viewController)
        }
    }
    
    public func toggleScheduledStatus() {
        toggleScheduledStatusForEvent(event, scheduleableView: viewController, interactor: interactor) { error in
            if (error != nil) {
                self.viewController.showErrorMessage(error!)
            }
        }
    }
}
