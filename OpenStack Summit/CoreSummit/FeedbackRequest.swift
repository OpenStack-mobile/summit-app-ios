//
//  EventFeedbackRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/12/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    func feedback(summit: Identifier? = nil, event: Identifier, page: Int, objectsPerPage: Int, completion: (ErrorValue<Page<Feedback>>) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/\(summitID)/events/\(event)/feedback?expand=owner&page=\(page)&per_page=\(objectsPerPage)"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.ServiceAccount)
        
        http.GET(URL) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String),
                let page = Page<Feedback>(JSONValue: json)
                else { completion(.Error(Error.InvalidResponse)); return }
            
            // cache
            try! self.realm.write { let _ = page.items.save(self.realm) }
            
            // success
            completion(.Value(page))
        }
    }
    
    func averageFeedback(summit: Identifier? = nil, event: Identifier, completion: (ErrorValue<Double>) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/\(summitID)/events/\(event)/published?fields=id,avg_feedback_rate&relations=none"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.ServiceAccount)
        
        http.GET(URL) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String),
                let jsonObject = json.objectValue,
                let averageFeedback = jsonObject[SummitEvent.JSONKey.avg_feedback_rate.rawValue]?.rawValue as? Double
                else { completion(.Error(Error.InvalidResponse)); return }
            
            // update cache
            if let realmEvent = RealmSummitEvent.find(event, realm: self.realm) {
                
                try! self.realm.write {
                    
                    realmEvent.averageFeedback = averageFeedback
                }
            }
            
            // success
            completion(.Value(averageFeedback))
        }
    }
    
    func addFeedback(summit: Identifier? = nil, event: Identifier, rate: Int, review: String, completion: (ErrorValue<Identifier>) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v2/summits/\(summitID)/events/\(event)/feedback"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.OpenIDJSON)
        
        var jsonDictionary = [String:AnyObject]()
        jsonDictionary["rate"] = rate
        jsonDictionary["note"] = review
        //jsonDictionary["attendee_id"] = attendee
        
        http.POST(URL, parameters: jsonDictionary) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            let id = Int(responseObject as! String)!
            
            // create new feedback in cache
            if let member = self.authenticatedMember,
                let attendee = member.attendeeRole {
                
                let owner = FeedbackOwner(identifier: member.id, attendee: attendee.id, firstName: member.firstName, lastName: member.lastName)
                
                let feedback = Feedback(identifier: id, rate: rate, review: review, date: Date(), event: event, owner: owner)
                
                try! self.realm.write {
                    
                    let realmFeedback = feedback.save(self.realm)
                    
                    attendee.feedback.append(realmFeedback)
                }
            }
            
            completion(.Value(id))
        }
    }
}
