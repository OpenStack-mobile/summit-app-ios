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
    
    func feedback(summit: Identifier? = nil, event: Identifier, page: Int, objectsPerPage: Int, completion: (ErrorValue<[Feedback]>) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/\(summitID)/events/\(event)/feedback?expand=owner&page=\(page)&per_page=\(objectsPerPage)"
        
        let URL = Constants.Urls.ResourceServerBaseUrl + URI
        
        let http = self.createHTTP(.ServiceAccount)
        
        http.GET(URL) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String),
                let jsonArray = json.arrayValue,
                let feedback = Feedback.fromJSON(jsonArray)
                else { completion(.Error(Error.InvalidResponse)); return }
            
            // cache
            try! self.realm.write { let _ = feedback.save(self.realm) }
            
            // success
            completion(.Value(feedback))
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
        
        let URL = Constants.Urls.ResourceServerBaseUrl + URI
        
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
    
    func saveFeedback(summit: Identifier? = nil, event: Identifier, rate: Int, review: String, completion: (ErrorValue<Double>) -> ()) {
        
        
    }
}