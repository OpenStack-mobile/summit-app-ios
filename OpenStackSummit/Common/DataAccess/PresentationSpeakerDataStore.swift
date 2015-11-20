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
    func getByFilterLocal(searchTerm: String?, page: Int, objectsPerPage: Int, completionBlock : ([PresentationSpeaker]?, NSError?) -> Void)
}

public class PresentationSpeakerDataStore: GenericDataStore, IPresentationSpeakerDataStore {
    public func getByFilterLocal(searchTerm: String?, page: Int, objectsPerPage: Int, completionBlock : ([PresentationSpeaker]?, NSError?) -> Void) {
        
        let result = realm.objects(PresentationSpeaker.self)
        
        if searchTerm != nil && !(searchTerm!.isEmpty) {
            result.filter("firstName CONTAINS [c]%@ or lastName CONTAINS [c]%@ ", searchTerm!, searchTerm!)
        }
        
        let startRecord = (page - 1) * objectsPerPage;
        let endRecord = (startRecord + (objectsPerPage - 1)) <= result.count ? startRecord + (objectsPerPage - 1) : result.count - 1;
        
        
        var speakers = [PresentationSpeaker]()
        for index in (startRecord...endRecord) {
            speakers.append(result[index])
        }
        
        completionBlock(speakers, nil)
    }

}
