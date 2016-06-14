//
//  SearchWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/23/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SWRevealViewController

@objc
public protocol ISearchWireframe {
    func pushSearchResultsView(term: String)
    func showEventDetail(eventId: Int)
    func showTrackSchedule(track: TrackDTO)
    func showAttendeeProfile(attendeeId: Int)
    func showSpeakerProfile(speakerId: Int)
}

public class SearchWireframe: NSObject, ISearchWireframe {
    var navigationController: NavigationController!
    var revealViewController: SWRevealViewController!
    var searchViewController: SearchViewController!
    var eventDetailWireframe : IEventDetailWireframe!
    var trackScheduleWireframe: ITrackScheduleWireframe!
    var memberProfileWireframe : IMemberProfileWireframe!
    
    public func pushSearchResultsView(term: String) {
        let _ = searchViewController.view! // this is only to force viewLoad to trigger
        searchViewController.presenter.searchTerm = term
        searchViewController.presenter.viewLoad()
        navigationController.setViewControllers([searchViewController], animated: false)
        revealViewController.pushFrontViewController(navigationController, animated: true)
    }
    
    public func showEventDetail(eventId: Int) {
        eventDetailWireframe.pushEventDetailView(eventId, toNavigationViewController: searchViewController.navigationController!)
    }
    
    public func showTrackSchedule(track: TrackDTO) {
        trackScheduleWireframe.presentTrackScheduleView(track, toNavigationController: searchViewController.navigationController!)
    }
    
    public func showAttendeeProfile(attendeeId: Int) {
        //memberProfileWireframe.pushAttendeeProfileView(attendeeId, toNavigationController: searchViewController.navigationController!)
    }
    
    public func showSpeakerProfile(speakerId: Int) {
        memberProfileWireframe.pushSpeakerProfileView(speakerId, toNavigationController: searchViewController.navigationController!)
    }
}
