//
//  TrackDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ITrackDataStore {
    func getAllLocal() -> [Track]
    func getBySearchTerm(searchTerm: String)->[Track]
}

public class TrackDataStore: GenericDataStore, ITrackDataStore {
    public func getAllLocal() -> [Track] {
        return super.getAllLocal()
    }
    
    public func getBySearchTerm(searchTerm: String)->[Track] {
        let tracks = realm.objects(Track).filter("name CONTAINS [c]%@ ", searchTerm).sorted("name")
        return tracks.map { $0 }
    }
}