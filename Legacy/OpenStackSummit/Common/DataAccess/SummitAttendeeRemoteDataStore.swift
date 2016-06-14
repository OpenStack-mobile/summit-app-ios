//
//  SummitAttendeeRemoteDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/5/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Crashlytics
import CoreSummit
import SwiftFoundation
import RealmSwift

public protocol SummitAttendeeRemoteDataStoreProtocol {
    
    func getByFilter(searchTerm: String?, page: Int, objectsPerPage: Int, completion: ErrorValue<[RealmSummitAttendee]> -> ())
    func getById(id: Int, completionBlock : ErrorValue<SummitAttendee> -> ())
    func addFeedback(attendee: SummitAttendee, feedback: Feedback, completionBlock : ErrorValue<Feedback> -> ())
    func addEventToShedule(attendee: SummitAttendee, event: SummitEvent, completionBlock : (NSError?) -> Void)
    func removeEventFromShedule(attendee: SummitAttendee, event: SummitEvent, completionBlock : (NSError?) -> Void)
}

public final class SummitAttendeeRemoteDataStore: SummitAttendeeRemoteDataStoreProtocol {

    var httpFactory = HttpFactory()
    
    var realm = try! Realm()
    
    public func getByFilter(searchTerm: String?, page: Int, objectsPerPage: Int, completion: ErrorValue<[RealmSummitAttendee]> -> ()) {
        
        let http = httpFactory.create(HttpType.ServiceAccount)
    
        var filter = ""
        if (searchTerm != nil && !(searchTerm!.isEmpty)) {
            filter = "filter=first_name=@\(searchTerm!),last_name=@\(searchTerm!)&"
        }
        
        http.GET("\(Constants.Urls.ResourceServerBaseUrl)/api/v1/summits/current/attendees?\(filter)page=\(page)&per_page=\(objectsPerPage)") { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            let foundationJSON = NSJSONSerialization.Value(rawValue: responseObject!)!
            let json = JSON.Value(foundation: foundationJSON)
            
            // parse
            guard let jsonArray = json.arrayValue,
                let entities = SummitAttendee.fromJSON(jsonArray)
                else {
                    
                    let userInfo: [NSObject : AnyObject] = [NSLocalizedDescriptionKey :  NSLocalizedString("There was an error deserializing summit attendees", value: "", comment: "")]
                    
                    let friendlyError = NSError(domain: Constants.ErrorDomain, code: 4001, userInfo: userInfo)
                    
                    completion(.Error(friendlyError))
                    
                    return
            }
            
            // save in Realm
            let realmEntities = entities.save(self.realm)
            
            // success
            completion(.Value(realmEntities))
        }
    }
    
    public func getById(id: Int, completionBlock : (SummitAttendee?, NSError?) -> Void) {
        let http = httpFactory.create(HttpType.ServiceAccount)
        
        http.GET("\(Constants.Urls.ResourceServerBaseUrl)/api/v1/summits/current/attendees/\(id)") {(responseObject, error) in
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
                let nsError = error as NSError
                Crashlytics.sharedInstance().recordError(nsError)
                printerr(nsError.localizedDescription)
                innerError = NSError(domain: "There was an error deserializing summit attendee", code: 4002, userInfo: nil)
            }
            
            completionBlock(attendee, innerError)
        }
    }
    
    public func addFeedback(attendee: SummitAttendee, feedback: Feedback, completionBlock : (Feedback?, NSError?)->Void) {
        let endpoint = "\(Constants.Urls.ResourceServerBaseUrl)/api/v1/summits/current/events/\(feedback.event.id)/feedback"
        let http = httpFactory.create(HttpType.OpenIDJson)
        var jsonDictionary = [String:AnyObject]()
        jsonDictionary["rate"] = feedback.rate
        jsonDictionary["note"] = feedback.review
        jsonDictionary["attendee_id"] = attendee.id
        
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
        let endpoint = "\(Constants.Urls.ResourceServerBaseUrl)/api/v1/summits/current/attendees/\(attendee.id)/schedule/\(event.id)"
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
        let endpoint = "\(Constants.Urls.ResourceServerBaseUrl)/api/v1/summits/current/attendees/\(attendee.id)/schedule/\(event.id)"
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
