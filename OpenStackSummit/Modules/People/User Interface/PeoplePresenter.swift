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
    func viewLoad()
    func showPersonProfile(index: Int)
    func buildScheduleCell(cell: IPersonTableViewCell, index: Int)
    func getPeopleCount() -> Int
}

public class PeoplePresenter: NSObject, IPeoplePresenter {
    var viewController: IPeopleViewController!
    var interactor: IPeopleInteractor!
    var wireframe: IPeopleWireframe!
    var speakers = [PersonListItemDTO]()
    var attendees = [PersonListItemDTO]()
    var page = 1
    let objectsPerPage = 10
    var loadedAll = false
    
    public func viewLoad() {
        getSpeakers()
    }

    func getAttendees() {
        viewController.showActivityIndicator()

        interactor.getAttendeesByFilter(viewController.searchTerm, page: page, objectsPerPage: objectsPerPage) { attendeesPage, error in
            defer { self.viewController.hideActivityIndicator() }

            if (error != nil) {
                self.viewController.showErrorMessage(error!)
                return
            }
            
            self.attendees.appendContentsOf(attendeesPage!)
            self.viewController.reloadData()
            self.loadedAll = attendeesPage!.count < self.objectsPerPage
            self.page++
        }
    }
    
    func getSpeakers() {
        viewController.showActivityIndicator()

        interactor.getSpeakersByFilter(viewController.searchTerm, page: page, objectsPerPage: objectsPerPage) { speakersPage, error in
            defer { self.viewController.hideActivityIndicator() }

            if (error != nil) {
                self.viewController.showErrorMessage(error!)
                return
            }
            
            self.speakers.appendContentsOf(speakersPage!)
            self.viewController.reloadData()
            self.loadedAll = speakersPage!.count < self.objectsPerPage
            self.page++            
        }
    }
    
    public func buildScheduleCell(cell: IPersonTableViewCell, index: Int){
        dispatch_async(dispatch_get_main_queue(),{
            let person = self.speakers[index]
            cell.name = person.name
            cell.title = person.title
            cell.picUrl = person.pictureUrl
            
            if (index == (self.speakers.count-1) && !self.loadedAll) {
                self.getSpeakers()
            }
        })
    }
    
    public func getPeopleCount() -> Int {
        return speakers.count
    }
    
    public func showPersonProfile(index: Int) {
        let person = speakers[index]
        wireframe.showSpeakerProfile(person.id)
    }
}
