//
//  PeoplePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/5/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IPeoplePresenter {
    func attendeesListViewLoad()
    func speakersListViewLoad()
    func attendeesListViewWillAppear()
    func speakersListViewWillAppear()
    func showPersonProfile(index: Int)
    func buildScheduleCell(cell: IPeopleTableViewCell, index: Int)
    func getPeopleCount() -> Int
}

public class PeoplePresenter: NSObject, IPeoplePresenter {
    var attendeesListViewController: IPeopleListViewController!
    var speakersListViewController: IPeopleListViewController!
    var interactor: IPeopleInteractor!
    var wireframe: IPeopleWireframe!
    var speakers = [PersonListItemDTO]()
    var attendees = [PersonListItemDTO]()
    var pageSpeakers = 1
    var pageAttendees = 1
    let objectsPerPage = 10
    var loadedAllSpeakers = false
    var loadedAllAttendees = false
    var isAttendeesView = false;
    var isSpeakerView = false;
    
    public func attendeesListViewLoad() {
        isAttendeesView = true
        isSpeakerView = false;
        if (pageAttendees == 1) {
            getAttendees()
        }
    }

    public func speakersListViewLoad() {
        isAttendeesView = false
        isSpeakerView = true;
        if (pageSpeakers == 1) {
            getSpeakers()
        }
    }

    public func attendeesListViewWillAppear() {
        isAttendeesView = true
        isSpeakerView = false;
    }

    public func speakersListViewWillAppear() {
        isAttendeesView = false
        isSpeakerView = true;
    }
    
    func getAttendees() {
        attendeesListViewController.showActivityIndicator()

        interactor.getAttendeesByFilter(attendeesListViewController.searchTerm, page: pageAttendees, objectsPerPage: objectsPerPage) { attendeesPage, error in
            defer { self.attendeesListViewController.hideActivityIndicator() }

            if (error != nil) {
                self.attendeesListViewController.showErrorMessage(error!)
                return
            }
            
            self.attendees.appendContentsOf(attendeesPage!)
            self.attendeesListViewController.reloadData()
            self.loadedAllAttendees = attendeesPage!.count < self.objectsPerPage
            self.pageAttendees++
        }
    }
    
    func getSpeakers() {
        speakersListViewController.showActivityIndicator()

        interactor.getSpeakersByFilter(speakersListViewController.searchTerm, page: pageSpeakers, objectsPerPage: objectsPerPage) { speakersPage, error in
            defer { self.speakersListViewController.hideActivityIndicator() }

            if (error != nil) {
                self.speakersListViewController.showErrorMessage(error!)
                return
            }
            
            self.speakers.appendContentsOf(speakersPage!)
            self.speakersListViewController.reloadData()
            self.loadedAllSpeakers = speakersPage!.count < self.objectsPerPage
            self.pageSpeakers++
        }
    }
    
    public func buildScheduleCell(cell: IPeopleTableViewCell, index: Int){
        dispatch_async(dispatch_get_main_queue(),{
            let person = self.isAttendeesView ? self.attendees[index] : self.speakers[index]
            cell.name = person.name
            cell.title = person.title
            cell.picUrl = person.pictureUrl
            
            if (index == (self.speakers.count-1) && !self.loadedAll()) {
                self.getSpeakers()
            }
        })
    }
    
    public func getPeopleCount() -> Int {
        return self.isAttendeesView ? self.attendees.count: self.speakers.count
    }
    
    public func showPersonProfile(index: Int) {
        let person = self.isAttendeesView ? self.attendees[index] : self.speakers[index]
        if (isAttendeesView) {
            wireframe.showAttendeeProfile(person.id, fromViewController: attendeesListViewController as! AttendeesListViewController)
        }
        else {
            wireframe.showSpeakerProfile(person.id, fromViewController: speakersListViewController as! SpeakerListViewController)
        }
    }
    
    func loadedAll() -> Bool {
        return self.isAttendeesView ? loadedAllAttendees : loadedAllSpeakers
    }
}
