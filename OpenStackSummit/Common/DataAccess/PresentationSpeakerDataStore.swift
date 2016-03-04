//
//  PresentationSpeakerDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/15/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import RealmSwift

@objc
public protocol IPresentationSpeakerDataStore {
    func getByIdLocal(id: Int) -> PresentationSpeaker?
    func getByFilterLocal(searchTerm: String?, page: Int, objectsPerPage: Int) -> [PresentationSpeaker]
}

public class PresentationSpeakerDataStore: GenericDataStore, IPresentationSpeakerDataStore {
    public func getByIdLocal(id: Int) -> PresentationSpeaker? {
        return super.getByIdLocal(id)
    }
    
    public func getByFilterLocal(searchTerm: String?, page: Int, objectsPerPage: Int) -> [PresentationSpeaker] {
        
        let sortProperties = [SortDescriptor(property: "firstName", ascending: true), SortDescriptor(property: "lastName", ascending: true)]
        var result = realm.objects(PresentationSpeaker.self).sorted(sortProperties)
        
        // HACK: filter speakers with empty name
        result = result.filter("fullName != ''")
        
        if searchTerm != nil && !(searchTerm!.isEmpty) {
            result = result.filter("fullName CONTAINS [c]%@", searchTerm!)
        }
        
        var speakers = [PresentationSpeaker]()
        
        let startRecord = (page - 1) * objectsPerPage;
        let endRecord = (startRecord + (objectsPerPage - 1)) <= result.count ? startRecord + (objectsPerPage - 1) : result.count - 1;
        
        if (startRecord <= endRecord) {
            
            for index in (startRecord...endRecord) {
                speakers.append(result[index])
            }
        }
        
        return speakers
    }
}
