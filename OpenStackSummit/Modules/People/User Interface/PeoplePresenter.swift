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
    func buildCell(cell: IPeopleTableViewCell, index: Int)
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
    
    public func viewLoad() {
        getAttendees()
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
        }
    }
    
    public func buildCell(cell: IPeopleTableViewCell, index: Int){
        let person = attendees[index]
        cell.name = person.name
        cell.title = person.title
    }
    
    public func getPeopleCount() -> Int {
        return attendees.count
    }
    
    public func showPersonProfile(index: Int) {
        let person = attendees[index]
        wireframe.showAttendeeProfile(person.id)
    }
}
