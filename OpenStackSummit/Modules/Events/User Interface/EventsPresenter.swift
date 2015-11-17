//
//  EventsPresenter.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 11/17/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Foundation

@objc
public protocol IEventsPresenter {
    func showFilters()
}

public class EventsPresenter: NSObject, IEventsPresenter {

    var internalWireframe: IEventsWireframe!
    
    var wireframe : IEventsWireframe! {
        get {
            return internalWireframe
        }
        set {
            internalWireframe = newValue
        }
    }
    
    public func showFilters() {
        wireframe.showFilters()
    }
}
