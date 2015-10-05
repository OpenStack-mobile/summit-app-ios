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
}

public class PeoplePresenter: NSObject, IPeoplePresenter {
    var viewController: IPeopleViewController!
    var interactor: IPeopleInteractor!
    var wireframe: IPeopleWireframe!
    var speakers: [PersonListItemDTO]?
    var attendees: [PersonListItemDTO]?
    var page = 1
    let objectsPerPage = 10
    
    public func viewLoad() {
        
    }
    
    func getSpekeakers() {
        interactor.getSpeakersByFilter(viewController.searchTerm, page: page, objectsPerPage: objectsPerPage) { speakers, error in
            if (error != nil) {
                self.viewController.showErrorMessage(error!)
                return
            }	
            
            self.viewController.reloadData()
        }
    }
    
    public func showPersonProfile(index: Int) {
        
    }
}
