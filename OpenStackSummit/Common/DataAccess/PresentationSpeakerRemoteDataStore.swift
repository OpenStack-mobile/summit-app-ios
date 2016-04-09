//
//  PresentationSpeakerRemoteDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/5/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Crashlytics

@objc
public protocol IPresentationSpeakerRemoteDataStore {
    func getByFilter(searchTerm: String?, page: Int, objectsPerPage: Int, completionBlock : ([PresentationSpeaker]?, NSError?) -> Void)
    func getById(id: Int, completionBlock : (PresentationSpeaker?, NSError?) -> Void)
}

public class PresentationSpeakerRemoteDataStore: NSObject {
    var deserializerFactory: DeserializerFactory!
    var httpFactory: HttpFactory!
    
    public func getByFilter(searchTerm: String?, page: Int, objectsPerPage: Int, completionBlock : ([PresentationSpeaker]?, NSError?) -> Void) {
        let http = httpFactory.create(HttpType.ServiceAccount)
        
        var filter = ""
        if (searchTerm != nil && !searchTerm!.isEmpty) {
            filter = "filter=first_name==\(searchTerm!),last_name==\(searchTerm!)&"
        }
        
        http.GET("\(Constants.Urls.ResourceServerBaseUrl)/api/v1/summits/current/speakers?\(filter)page=\(page)&per_page=\(objectsPerPage)") {(responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            
            let json = responseObject as! String
            let deserializer : IDeserializer!
            var friendlyError: NSError?
            var speakers: [PresentationSpeaker]?
            
            deserializer = self.deserializerFactory.create(DeserializerFactoryType.PresentationSpeaker)
            
            do {
                speakers = try deserializer.deserializePage(json) as? [PresentationSpeaker]
            }
            catch {
                let nsError = error as NSError
                printerr(nsError)
                Crashlytics.sharedInstance().recordError(nsError)
                let userInfo: [NSObject : AnyObject] = [NSLocalizedDescriptionKey :  NSLocalizedString("There was an error deserializing presentation speakers", value: nsError.localizedDescription, comment: "")]
                friendlyError = NSError(domain: Constants.ErrorDomain, code: 3001, userInfo: userInfo)
                
            }
            
            completionBlock(speakers, friendlyError)
        }
    }
    
    public func getById(id: Int, completionBlock : (PresentationSpeaker?, NSError?) -> Void) {
        let http = httpFactory.create(HttpType.ServiceAccount)
        
        http.GET("\(Constants.Urls.ResourceServerBaseUrl)/api/v1/summits/current/speakers/\(id)") {(responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            
            let json = responseObject as! String
            let deserializer : IDeserializer!
            var innerError: NSError?
            var speaker: PresentationSpeaker?
            
            deserializer = self.deserializerFactory.create(DeserializerFactoryType.PresentationSpeaker)
            
            do {
                speaker = try deserializer.deserialize(json) as? PresentationSpeaker
            }
            catch {
                innerError = NSError(domain: "There was an error deserializing presentation speaker", code: 3002, userInfo: nil)
            }
            
            completionBlock(speaker, innerError)
        }
    }
    
}
