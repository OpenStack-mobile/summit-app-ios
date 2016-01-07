//
//  SearchWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/23/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ISearchWireframe {
    func showEventDetail(eventId: Int)
    func showTrackSchedule(track: TrackDTO)
    func showAttendeeProfile(attendeeId: Int)
    func showSpeakerProfile(speakerId: Int)
}

public class SearchWireframe: NSObject, ISearchWireframe {
    var memberProfileWireframe : IMemberProfileWireframe!
    var searchViewController: ISearchViewController!
    var trackScheduleWireframe: ITrackScheduleWireframe!
    var eventDetailWireframe : IEventDetailWireframe!
    
    public func showEventDetail(eventId: Int) {
        eventDetailWireframe.presentEventDetailView(eventId, onNavigationViewController: searchViewController.navigationController!)
    }
    
    public func showTrackSchedule(track: TrackDTO) {
        trackScheduleWireframe.presentTrackScheduleView(track, viewController: searchViewController.navigationController!)
    }
    public func showAttendeeProfile(attendeeId: Int) {
        //memberProfileWireframe.presentAttendeeProfileView(attendeeId, viewController: searchViewController.navigationController!)
    }
    
    public func showSpeakerProfile(speakerId: Int) {
        memberProfileWireframe.presentSpeakerProfileView(speakerId, viewController: searchViewController.navigationController!)
    }

}
