//
//  SummitAttendeeRemoteDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/5/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ISummitAttendeeRemoteDataStore {
    func getByFilter(searchTerm: String?, page: Int, objectsPerPage: Int, completionBlock : ([SummitAttendee]?, NSError?) -> Void)
    func getById(id: Int, completionBlock : (SummitAttendee?, NSError?) -> Void)
    func addFeedback(attendee: SummitAttendee, feedback: Feedback, completionBlock : (Feedback?, NSError?)->Void)
    func addEventToShedule(attendee: SummitAttendee, event: SummitEvent, completionBlock : (NSError?) -> Void)
    func removeEventFromShedule(attendee: SummitAttendee, event: SummitEvent, completionBlock : (NSError?) -> Void)
}

public class SummitAttendeeRemoteDataStore: NSObject, ISummitAttendeeRemoteDataStore {
    var deserializerFactory: DeserializerFactory!
    var httpFactory: HttpFactory!
    
    public func getByFilter(searchTerm: String?, page: Int, objectsPerPage: Int, completionBlock : ([SummitAttendee]?, NSError?) -> Void) {
        let http = httpFactory.create(HttpType.ServiceAccount)
        
        http.GET("https://testresource-server.openstack.org/api/v1/summits/current/attendees?page=\(page)&per_page=\(objectsPerPage)") {(responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            
            let json = responseObject as! String
            let deserializer : IDeserializer!
            var innerError: NSError?
            var attendees: [SummitAttendee]?
            
            deserializer = self.deserializerFactory.create(DeserializerFactoryType.SummitAttendee)
            
            do {
                attendees = try deserializer.deserializePage(json) as? [SummitAttendee]
            }
            catch {
                innerError = NSError(domain: "There was an error deserializing summit attendees", code: 4001, userInfo: nil)
            }
            
            completionBlock(attendees, innerError)
        }
    }
    
    public func getById(id: Int, completionBlock : (SummitAttendee?, NSError?) -> Void) {
        let http = httpFactory.create(HttpType.ServiceAccount)
        
        http.GET("https://testresource-server.openstack.org/api/v1/summits/current/attendees/\(id)") {(responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            
            let json = responseObject as! String
            let deserializer : IDeserializer!
            var innerError: NSError?
            var attendee: SummitAttendee?
            
            deserializer = self.deserializerFactory.create(DeserializerFactoryType.SummitAttendee)
            
            do {
                attendee = try deserializer.deserialize(json) as? SummitAttendee
            }
            catch {
                innerError = NSError(domain: "There was an error deserializing summit attendee", code: 4002, userInfo: nil)
            }
            
            completionBlock(attendee, innerError)
        }
    }
    
    public func addFeedback(attendee: SummitAttendee, feedback: Feedback, completionBlock : (Feedback?, NSError?)->Void) {
        let endpoint = "https://testresource-server.openstack.org/api/v1/summits/current/events/\(feedback.event.id)/feedback"
        let http = httpFactory.create(HttpType.OpenIDJson)
        var jsonDictionary = [String:AnyObject]()
        jsonDictionary["rate"] = feedback.rate
        jsonDictionary["note"] = feedback.review
        jsonDictionary["owner_id"] = attendee.id
        
        http.POST(endpoint, parameters: jsonDictionary, completionHandler: {(responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            
            let id = Int(responseObject as! String)!
            feedback.id = id
            completionBlock(feedback, error)
        })
    }
    
    public func addEventToShedule(attendee: SummitAttendee, event: SummitEvent, completionBlock : (NSError?) -> Void) {
        let endpoint = "https://testresource-server.openstack.org/api/v1/summits/current/attendees/\(attendee.id)/schedule/\(event.id)"
        let http = httpFactory.create(HttpType.OpenIDGetFormUrlEncoded)
        //json[""]
        http.POST(endpoint, parameters: nil, completionHandler: {(responseObject, error) in
            if (error != nil) {
                completionBlock(error)
                return
            }
            completionBlock(error)
        })
    }
    
    public func removeEventFromShedule(attendee: SummitAttendee, event: SummitEvent, completionBlock : (NSError?) -> Void) {
        let endpoint = "https://testresource-server.openstack.org/api/v1/summits/current/attendees/\(attendee.id)/schedule/\(event.id)"
        let http = httpFactory.create(HttpType.OpenIDGetFormUrlEncoded)
        http.DELETE(endpoint, parameters: nil, completionHandler: {(responseObject, error) in
            if (error != nil) {
                completionBlock(error)
                return
            }
            completionBlock(error)
        })
    }    
}
