//
//  EventsInteractor.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 3/24/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IEventsInteractor {
    func isDataLoaded() -> Bool
    func isNetworkAvailable() -> Bool
}

public class EventsInteractor: NSObject, IEventsInteractor {
    var reachability: IReachability!
    var summitDataStore: ISummitDataStore!
    
    public func isDataLoaded() -> Bool {
        return summitDataStore.getActiveLocal() != nil
    }
    
    public func isNetworkAvailable() -> Bool {
        return reachability.isConnectedToNetwork()
    }
}
