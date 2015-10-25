//
//  SearchPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/23/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ISearchPresenter {
    func showEventDetail(index: Int)
    func showTrackEvents(index: Int)
    func showSpeakerProfile(index: Int)
    func showAttendeeProfile(index: Int)
    func viewLoad()
    func buildEventCell(cell: IScheduleTableViewCell, index: Int)
    func buildTrackCell(cell: ITrackTableViewCell, index: Int)
    func buildSpeakerCell(cell: IPersonTableViewCell, index: Int)
    func buildAttendeeCell(cell: IPersonTableViewCell, index: Int)
    func getEventsCount() -> Int
    func getTracksCount() -> Int
    func getSpeakersCount() -> Int
    func getAttendeesCount() -> Int
    func search(searchTerm: String!)
}

public class SearchPresenter: NSObject {
    var interactor: ISearchInteractor!
    var viewController: ISearchViewController!
    var wireframe: ISearchWireframe!
    var events: [ScheduleItemDTO]!
    var tracks: [TrackDTO]!
    var speakers = [PersonListItemDTO]()
    var attendees = [PersonListItemDTO]()
    let objectsPerPage = 100
    var pageSpeakers = 1
    var loadedAllSpeakers = false
    var pageAttendees = 1
    var loadedAllAttendees = false
    
    public func viewLoad() {
        //interactor.getEventsBySearchTerm()
    }

    public func search(searchTerm: String!) {
        events = interactor.getEventsBySearchTerm(searchTerm)
        viewController.reloadEvents()
        tracks = interactor.getTracksBySearchTerm(searchTerm)
        viewController.reloadTracks()
        interactor.getSpeakersBySearchTerm(searchTerm, page: pageSpeakers, objectsPerPage: objectsPerPage) { (speakersPage, error) in
            if (error != nil) {
                self.viewController.showErrorMessage(error!)
                return
            }
            
            self.speakers.appendContentsOf(speakersPage!)
            self.viewController.reloadSpeakers()
            self.loadedAllSpeakers = speakersPage!.count < self.objectsPerPage
            self.pageSpeakers++
        }
        
        interactor.getAttendeesBySearchTerm(searchTerm, page: pageAttendees, objectsPerPage: objectsPerPage) { (attendeesPage, error) in
            if (error != nil) {
                self.viewController.showErrorMessage(error!)
                return
            }
            
            self.attendees.appendContentsOf(attendeesPage!)
            self.viewController.reloadAttendees()
            self.loadedAllAttendees = attendeesPage!.count < self.objectsPerPage
            self.pageAttendees++
        }
    }
    
    public func buildEventCell(cell: IScheduleTableViewCell, index: Int){
        let event = events[index]
        cell.eventTitle = event.name
        cell.timeAndPlace = event.date
        //cell.scheduledStatus = internalInteractor.isEventScheduledByLoggedMember(event.id) ? ScheduledStatus.Scheduled : ScheduledStatus.NotScheduled
        //cell.isScheduledStatusVisible = internalInteractor.isMemberLoggedIn()
    }
    
    func buildTrackCell(cell: ITrackTableViewCell, index: Int) {
        let track = tracks[index]
        cell.name = track.name
    }
    
    func buildSpeakerCell(cell: IPersonTableViewCell, index: Int) {
        let speaker = speakers[index]
        cell.name = speaker.name
    }
    
    
    func buildAttendeeCell(cell: IPersonTableViewCell, index: Int) {
        let speaker = attendees[index]
        cell.name = speaker.name
    }
 
    public func getEventsCount() -> Int {
        return events.count
    }
    
    public func getTracksCount() -> Int {
        return tracks.count
    }

    public func getSpeakersCount() -> Int {
        return speakers.count
    }

    public func getAttendeesCount() -> Int {
        return attendees.count
    }
    
    public func showEventDetail(index: Int) {
        let event = events[index]
        wireframe.showEventDetail(event.id)
    }
    
    public func showTrackEvents(index: Int) {
        let track = tracks[index]
        wireframe.showTrackSchedule(track.id)
    }
   
    public func showSpeakerProfile(index: Int) {
        let person = speakers[index]
        wireframe.showSpeakerProfile(person.id)
    }

    public func showAttendeeProfile(index: Int) {
        let person = speakers[index]
        wireframe.showAttendeeProfile(person.id)
    }
}
