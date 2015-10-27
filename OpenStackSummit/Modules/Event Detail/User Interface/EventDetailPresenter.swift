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
    func addEventToMySchedule()
    func getSpeakersCount()->Int
    func getFeedbackCount()->Int
    func buildSpeakerCell(cell: IPersonTableViewCell, index: Int)
    func buildFeedbackCell(cell: IFeedbackGivenTableViewCell, index: Int)
    func showSpeakerProfile(index: Int)
    func loadFeedback()
    func showVenueDetail()
}

public class EventDetailPresenter: NSObject {
    weak var viewController : IEventDetailViewController!
    var interactor : IEventDetailInteractor!
    var wireframe: IEventDetailWireframe!
    var eventId = 0
    private var event: EventDetailDTO!
    private var feedbackPage = 1
    private var feedbackObjectsPerPage = 10
    private var feedbackList = [FeedbackDTO]()
    private var loadedAllFeedback: Bool!
    
    public func viewLoad() {
        feedbackPage = 1
        feedbackList.removeAll()
        event = interactor.getEventDetail(eventId)
       
        viewController.eventTitle = event.name
        viewController.eventDescription = event.eventDescription
        viewController.location = event.location
        viewController.date = event.date
        viewController.allowFeedback = event.allowFeedback && interactor.isMemberLoggedIn()
        viewController.reloadSpeakersData()
        
        loadFeedback()
    }
    
    public func loadFeedback() {
        interactor.getFeedbackForEvent(eventId, page: feedbackPage, objectsPerPage: feedbackObjectsPerPage) { (feedbackList, error) in
            dispatch_async(dispatch_get_main_queue(),{
                if (error != nil) {
                    self.viewController.showErrorMessage(error!)
                    return
                }
                
                self.feedbackList.appendContentsOf(feedbackList!)
                self.viewController.reloadFeedbackData()
                self.feedbackPage++
                self.viewController.loadedAllFeedback = feedbackList!.count < self.feedbackObjectsPerPage
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
        cell.rate = String(feedback.rate)
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
}
