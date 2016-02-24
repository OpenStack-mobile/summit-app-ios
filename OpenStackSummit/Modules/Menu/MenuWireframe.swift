//
//  MenuWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/24/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMenuWireframe {
    func showSearchResults()
    func showEvents()
    func showVenues()
    func showPeople()
    func showSpeakers()
    func showMyProfile(memberId: Int)
}

public class MenuWireframe: NSObject, IMenuWireframe {
    var searchWireframe: ISearchWireframe!
    var eventsWireframe: IEventsWireframe!
    var venuesWireframe: IVenuesWireframe!
    var peopleWireframe: IPeopleWireframe!
    var myProfileWireframe: IMyProfileWireframe!
    
    public func showSearchResults() {
        searchWireframe.pushSearchResultsView()
    }
    
    public func showEvents() {
        eventsWireframe.pushEventsView()
    }
    
    public func showVenues() {
        venuesWireframe.pushVenuesView()
    }
    
    public func showPeople() {
        // TODO: Implement people segue
    }
    
    public func showSpeakers() {
        peopleWireframe.pushSpeakersView()
    }
    
    public func showMyProfile(memberId: Int) {
        myProfileWireframe.pushMyProfileView()
    }
}