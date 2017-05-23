//
//  MemberRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import AeroGearHttp
import AeroGearOAuth2
import JSON

public extension Store {
    
    func currentMember(for summit: Identifier, completion: @escaping (ErrorValue<MemberResponse.Member>) -> ()) {
        
        let uri = "/api/v1/summits/\(summit)/members/me?expand=attendee,speaker,feedback,groups"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.openIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        http.request(method: .get, path: url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.error(error!)); return }
            
            guard let json = try? JSON.Value(string: responseObject as! String),
                let member = MemberResponse.Member(json: json)
                else { completion(.error(Error.invalidResponse)); return }
            
            // cache
            try! context.performErrorBlockAndWait {
                
                let _ = try member.save(context)
                
                try context.validateAndSave()
            }
            
            // success
            completion(.value(member))
        }
    }
}

// MARK: - Supporting Types

public struct MemberResponse {
    
    public struct Member: Person {
        
        public let identifier: Identifier
        
        public let firstName: String
        
        public let lastName: String
        
        public let gender: String?
        
        public let picture: URL
        
        public let twitter: String?
        
        public let linkedIn: String?
        
        public let irc: String?
        
        public let biography: String?
        
        public let speakerRole: Speaker?
        
        public let attendeeRole: Attendee?
        
        public let groupEvents: [Event]
        
        public let groups: [Group]
        
        public let feedback: [Feedback]
        
        public let favoriteEvents: [Identifier]
        
        public let affiliations: [Affiliation]
    }
    
    public struct Event: Named {
        
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
        
        public let rsvp: String?
        
        public let externalRSVP: Bool
        
        public let willRecord: Bool
        
        public let attachment: URL?
        
        public let sponsors: [Company]
        
        public let tags: [Tag]
        
        public let location: Location?
        
        public let presentation: Presentation
        
        public let videos: [Video]
        
        public let slides: [Slide]
        
        public let links: [Link]
        
        public let groups: [Group]
    }
    
    public struct Track: Named {
        
        public let identifier: Identifier
        
        public let name: String
        
        public let groups: [TrackGroup]
    }
    
    public struct Feedback: FeedbackProtocol {
        
        public let identifier: Identifier
        
        public let rate: Int
        
        public let review: String
        
        public let date: Date
        
        public let event: Identifier
        
        public let member: Identifier
    }
    
    public typealias Presentation = CoreSummit.Presentation.DataUpdate
}

public extension MemberResponse.Member {
    
    public var title: String? { return speakerRole?.title }
}

// MARK: - Equatable

public func == (lhs: MemberResponse.Event, rhs: MemberResponse.Event) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.summit == rhs.summit
        && lhs.name == rhs.name
        && lhs.summit == rhs.summit
        && lhs.descriptionText == rhs.descriptionText
        && lhs.socialDescription == rhs.socialDescription
        && lhs.start == rhs.start
        && lhs.end == rhs.end
        && lhs.track == rhs.track
        && lhs.allowFeedback == rhs.allowFeedback
        && lhs.averageFeedback == rhs.averageFeedback
        && lhs.type == rhs.type
        && lhs.sponsors == rhs.sponsors
        && lhs.tags == rhs.tags
        && lhs.location == rhs.location
        && lhs.presentation == rhs.presentation
        && lhs.videos == rhs.videos
        && lhs.rsvp == rhs.rsvp
        && lhs.groups == rhs.groups
        && lhs.externalRSVP == rhs.externalRSVP
        && lhs.willRecord == rhs.willRecord
        && lhs.slides == rhs.slides
        && lhs.links == rhs.links
}

public func == (lhs: MemberResponse.Member, rhs: MemberResponse.Member) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.firstName == rhs.firstName
        && lhs.lastName == rhs.lastName
        && lhs.picture == rhs.picture
        && lhs.twitter == rhs.twitter
        && lhs.irc == rhs.irc
        && lhs.linkedIn == rhs.linkedIn
        && lhs.speakerRole == rhs.speakerRole
        && lhs.attendeeRole == rhs.attendeeRole
        && lhs.groups == rhs.groups
        && lhs.groupEvents == rhs.groupEvents
        && lhs.feedback == rhs.feedback
        && lhs.favoriteEvents == rhs.favoriteEvents
        && lhs.affiliations == rhs.affiliations
}

public func == (lhs: MemberResponse.Track, rhs: MemberResponse.Track) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.groups == rhs.groups
}

public func == (lhs: MemberResponse.Feedback, rhs: MemberResponse.Feedback) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.rate == rhs.rate
        && lhs.review == rhs.review
        && lhs.date == rhs.date
        && lhs.event == lhs.event
        && lhs.member == lhs.member
}
