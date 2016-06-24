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
    var searchTerm: String! { get set }
    func showEventDetail(index: Int)
    func showTrackEvents(index: Int)
    func showSpeakerProfile(index: Int)
    func showAttendeeProfile(index: Int)
    func viewLoad()
    func buildEventCell(cell: IScheduleTableViewCell, index: Int)
    func buildTrackCell(cell: ITrackTableViewCell, index: Int)
    func buildSpeakerCell(cell: IPeopleTableViewCell, index: Int)
    func buildAttendeeCell(cell: IPeopleTableViewCell, index: Int)
    func getEventsCount() -> Int
    func getTracksCount() -> Int
    func getSpeakersCount() -> Int
    func getAttendeesCount() -> Int
    func search(searchTerm: String!)
    func toggleScheduledStatus(index: Int, cell: IScheduleTableViewCell)
}

public class SearchPresenter: ScheduleablePresenter {
    var interactor: ISearchInteractor!
    var viewController: ISearchViewController!
    var wireframe: ISearchWireframe!
    var events: [ScheduleItem]!
    var tracks: [TrackDTO]!
    var speakers = [PersonListItemDTO]()
    var attendees = [PersonListItemDTO]()
    let objectsPerPage = 1000
    var pageSpeakers = 1
    var loadedAllSpeakers = false
    var pageAttendees = 1
    var loadedAllAttendees = false
    var session: ISession!
    var searchTerm: String!
    var loadingSpeakers = false
    
    public func viewLoad() {
        if searchTerm != nil && !searchTerm!.isEmpty {
            viewController.searchTerm = searchTerm
            search(searchTerm)
        }
    }

    public func search(searchTerm: String!) {
        loadedAllSpeakers = false
        pageSpeakers = 1
        pageAttendees = 1
        speakers.removeAll()
        attendees.removeAll()
        
        events = interactor.getEventsBySearchTerm(searchTerm)
        viewController.reloadEvents()
        tracks = interactor.getTracksBySearchTerm(searchTerm)
        viewController.reloadTracks()

        getSpeakers()
    
        /*interactor.getAttendeesBySearchTerm(searchTerm, page: self.pageAttendees, objectsPerPage: self.objectsPerPage) { (attendeesPage, error) in
            dispatch_async(dispatch_get_main_queue(),{
                if (error != nil) {
                    self.viewController.showErrorMessage(error!)
                    return
                }
                
                self.attendees.appendContentsOf(attendeesPage!)
                self.viewController.reloadAttendees()
                self.loadedAllAttendees = attendeesPage!.count < self.objectsPerPage
                self.pageAttendees++
            })
        }*/
    }
    
    func getSpeakers() {
        if loadingSpeakers || loadedAllSpeakers {
            return
        }
        loadingSpeakers = true
        interactor.getSpeakersBySearchTerm(searchTerm, page: pageSpeakers, objectsPerPage: objectsPerPage) { (speakersPage, error) in
            defer { self.loadingSpeakers = false }
            if (error != nil) {
                self.viewController.showErrorMessage(error!)
                return
            }
            
            self.speakers.appendContentsOf(speakersPage!)
            self.viewController.reloadSpeakers()
            self.loadedAllSpeakers = speakersPage!.count < self.objectsPerPage
            self.pageSpeakers++
        }
    }
    
    public func buildEventCell(cell: IScheduleTableViewCell, index: Int){
        let event = events[index]
        cell.eventTitle = event.name
        cell.eventType = event.eventType
        cell.time = event.time
        cell.location = event.location
        cell.sponsors = event.sponsors
        cell.track = event.track
        cell.scheduled = interactor.isEventScheduledByLoggedMember(event.id)
        cell.isScheduledStatusVisible = interactor.isLoggedInAndConfirmedAttendee()
        cell.trackGroupColor = event.trackGroupColor != "" ? UIColor(hexaString: event.trackGroupColor) : nil
    }
    
    func buildTrackCell(cell: ITrackTableViewCell, index: Int) {
        let track = tracks[index]
        cell.name = track.name
    }
    
    func buildSpeakerCell(cell: IPeopleTableViewCell, index: Int) {
        let speaker = speakers[index]
        cell.name = speaker.name
        cell.title = speaker.title
        cell.picUrl = speaker.pictureUrl
        if (index == (speakers.count-1) && !loadedAllSpeakers) {
            getSpeakers()
        }
    }
    
    func buildAttendeeCell(cell: IPeopleTableViewCell, index: Int) {
        let attendee = attendees[index]
        cell.name = attendee.name
        cell.title = attendee.title
        cell.picUrl = attendee.pictureUrl
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
        wireframe.showTrackSchedule(track)
    }
   
    public func showSpeakerProfile(index: Int) {
        let person = speakers[index]
        wireframe.showSpeakerProfile(person.id)
    }

    public func showAttendeeProfile(index: Int) {
        let person = speakers[index]
        wireframe.showAttendeeProfile(person.id)
    }
    
    public func toggleScheduledStatus(index: Int, cell: IScheduleTableViewCell) {
        let event = events[index]
        toggleScheduledStatusForEvent(event, scheduleableView: cell, interactor: interactor) { error in
            if (error != nil) {
                self.viewController.showErrorMessage(error!)
            }
        }
    }
}