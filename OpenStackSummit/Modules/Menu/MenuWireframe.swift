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
    func showSearchFor(term: String)
    func showEvents()
    func showVenues()
    func showPeople()
    func showSpeakers()
    func showMyProfile()
    func showMemberOrderConfirm()
    func showAbout()
}

public class MenuWireframe: NSObject, IMenuWireframe {
    var searchWireframe: ISearchWireframe!
    var eventsWireframe: IEventsWireframe!
    var venuesWireframe: IVenuesWireframe!
    var peopleWireframe: IPeopleWireframe!
    var myProfileWireframe: IMyProfileWireframe!
    var memberOrderConfirmWireframe: IMemberOrderConfirmWireframe!
    var aboutWireframe: IAboutWireframe!
    
    public func showSearchFor(term: String) {
        searchWireframe.pushSearchResultsView(term)
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
    
    public func showMyProfile() {
        myProfileWireframe.pushMyProfileView()
    }
    
    public func showMemberOrderConfirm() {
        memberOrderConfirmWireframe.pushMemberOrderConfirmView()
    }
    
    public func showAbout() {
        aboutWireframe.pushAboutView()
    }
}