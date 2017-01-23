//
//  LoggedInMemberRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    func member(for summit: Identifier, completion: (ErrorValue<MemberResponse.Member>) -> ()) {
        
        let URI = "/api/v1/summits/\(summit)/members/me/?expand=attendee,speaker,feedback,groups"
        
        let URL = environment.configuration.authenticationURL + URI
        
        let http = self.createHTTP(.OpenIDGetFormUrlEncoded)
        
        let context = privateQueueManagedObjectContext
        
        http.GET(URL, parameters: nil, completionHandler: { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String),
                let entity = Member(JSONValue: json)
                else { completion(.Error(Error.InvalidResponse)); return }
            
            // cache
            try! context.performErrorBlockAndWait {
                
                try entity.save(context)
                
                try context.save()
            }
            
            // success
            completion(.Value(entity))
        })
    }
}

// MARK: - Supporting Types

public struct MemberResponse {
    
    public struct Member {
        
        public let identifier: Identifier
        
        public let firstName: String
        
        public let lastName: String
        
        public let gender: Gender
        
        public let pictureURL: String
        
        public let twitter: String?
        
        public let linkedIn: String?
        
        public let irc: String?
        
        public let biography: String?
        
        public let speakerRole: Speaker?
        
        public let attendeeRole: Attendee?
        
        public let groupEvents: [Event]
        
        public let groups: [Group]
    }
    
    public struct Event {
        
        public let identifier: Identifier
        
        public let name: String
        
        public let descriptionText: String?
        
        public let socialDescription: String?
        
        public let start: Date
        
        public let end: Date
        
        public let summit: Identifier
        
        public let track: Track?
        
        public let allowFeedback: Bool
        
        public let averageFeedback: Double
        
        public let type: EventType
        
        public let sponsors: [Company]
        
        public let tags: [Tag]
        
        public let location: Location
        
        public let presentation: Presentation
        
        public let videos: [Video]
        
        public let rsvp: String?
        
        public let groups: [Group]
    }
    
    public struct 
}

// MARK: - Equatable


