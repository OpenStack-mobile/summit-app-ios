//
//  PresentationSpeakerDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/15/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
@objc
public protocol IPresentationSpeakerDataStore {
    func getByFilterLocal(searchTerm: String?, page: Int, objectsPerPage: Int) -> [PresentationSpeaker]
    func getByIdLocal(id: Int) -> PresentationSpeaker?
}

public class PresentationSpeakerDataStore: GenericDataStore, IPresentationSpeakerDataStore {
    public func getByIdLocal(id: Int) -> PresentationSpeaker? {
        return super.getByIdLocal(id)
    }
    
    public func getByFilterLocal(searchTerm: String?, page: Int, objectsPerPage: Int) -> [PresentationSpeaker] {
        
        var result = realm.objects(PresentationSpeaker.self).sorted("firstName")
        
        if searchTerm != nil && !(searchTerm!.isEmpty) {
            result = result.filter("fullName CONTAINS [c]%@ or bio CONTAINS [c]%@ ", searchTerm!, searchTerm!)
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
