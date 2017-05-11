//
//  EventFeedbackRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/12/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import AeroGearHttp
import AeroGearOAuth2
import JSON

public extension Store {
    
    func feedback(_ summit: Identifier, event: Identifier, page: Int, objectsPerPage: Int, completion: @escaping (ErrorValue<Page<Feedback>>) -> ()) {
        
        let uri = "/api/v1/summits/\(summit)/events/\(event)/feedback?expand=owner&page=\(page)&per_page=\(objectsPerPage)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.serviceAccount)
        
        let context = privateQueueManagedObjectContext
        
        http.request(method: .get, path: url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.error(error!)); return }
            
            guard let json = try? JSON.Value(string: responseObject as! String),
                let page = Page<Feedback>(json: json)
                else { completion(.error(Error.invalidResponse)); return }
            
            // cache
            try! context.performErrorBlockAndWait {
                
                // only cache if event exists
                guard let _ = try EventManagedObject.find(event, context: context)
                    else { return }
                
                let _ = try page.items.save(context)
                
                try context.validateAndSave()
            }
            
            // success
            completion(.value(page))
        }
    }
    
    func averageFeedback(_ summit: Identifier, event: Identifier, completion: @escaping (ErrorValue<Double>) -> ()) {
        
        let uri = "/api/v1/summits/\(summit)/events/\(event)/published?fields=id,avg_feedback_rate&relations=none"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.serviceAccount)
        
        let context = privateQueueManagedObjectContext
        
        http.request(method: .get, path: url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.error(error!)); return }
            
            guard let json = try? JSON.Value(string: responseObject as! String),
                let jsonObject = json.objectValue,
                let averageFeedbackJSON = jsonObject[Event.JSONKey.avg_feedback_rate.rawValue]
                else { completion(.error(Error.invalidResponse)); return }
            
            let averageFeedback: Double
            
            if let doubleValue = averageFeedbackJSON.rawValue as? Double {
                
                averageFeedback = doubleValue
                
            } else if let integerValue = averageFeedbackJSON.integerValue {
                
                averageFeedback = Double(integerValue)
                
            } else {
                
                completion(.error(Error.invalidResponse)); return
            }
                        
            // update cache
            try! context.performErrorBlockAndWait {
                
                if let managedObject = try EventManagedObject.find(event, context: context) {
                    
                    managedObject.averageFeedback = averageFeedback
                    
                    try context.save()
                }
            }
            
            // success
            completion(.value(averageFeedback))
        }
    }
    
    func addFeedback(_ summit: Identifier, event: Identifier, rate: Int, review: String, completion: @escaping (ErrorValue<Identifier>) -> ()) {
        
        let uri = "/api/v2/summits/\(summit)/events/\(event)/feedback"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.openIDJSON)
        
        var jsonDictionary = [String: Any]()
        jsonDictionary["rate"] = rate
        jsonDictionary["note"] = review
        
        let context = privateQueueManagedObjectContext
        
        http.request(method: .post, path: url, parameters: jsonDictionary) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.error(error!)); return }
            
            let identifier = Identifier(responseObject as! String)!
            
            // create new feedback in cache
            try! context.performErrorBlockAndWait {
                
                if let memberManagedObject = try self.authenticatedMember(context) {
                    
                    let member = Member(managedObject: memberManagedObject)
                    
                    let feedback = Feedback(identifier: identifier, rate: rate, review: review, date: Date(), event: event, member: member)
                    
                    let managedObject = try feedback.save(context)
                    
                    memberManagedObject.feedback.insert(managedObject)
                    
                    try context.validateAndSave()
                }
            }
            
            completion(.value(identifier))
        }
    }
    
    func editFeedback(_ summit: Identifier, event: Identifier, rate: Int, review: String, completion: @escaping (Swift.Error?) -> ()) {
        
        let uri = "/api/v2/summits/\(summit)/events/\(event)/feedback"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.openIDJSON)
        
        var jsonDictionary = [String: Any]()
        jsonDictionary["rate"] = rate
        jsonDictionary["note"] = review
        
        let context = privateQueueManagedObjectContext
        
        http.request(method: .put, path: url, parameters: jsonDictionary) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(error!); return }
            
            // create new feedback in cache
            try! context.performErrorBlockAndWait {
                
                if let member = try self.authenticatedMember(context),
                    let feedback = member.feedback(for: event) {
                    
                    feedback.rate = Int16(rate)
                    
                    feedback.review = review
                    
                    try context.save()
                }
            }
            
            completion(nil)
        }
    }
}
