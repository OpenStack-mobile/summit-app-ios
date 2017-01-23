//
//  SummitsRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/24/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    func summits(completion: ErrorValue<Page<SummitsResponse.Summit>> -> ()) {
        
        let URI = "/api/v1/summits"
        
        let http = self.createHTTP(.ServiceAccount)
        
        let url = environment.configuration.serverURL + URI
        
        http.GET(url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String),
                let response = SummitsResponse(JSONValue: json)
                else { completion(.Error(Error.InvalidResponse)); return }
            
            // success
            completion(.Value(response.page))
        }
    }
}

// MARK: - Supporting Types

public struct SummitsResponse: JSONDecodable {
    
    public let page: Page<Summit>
    
    public init?(JSONValue: JSON.Value) {
        
        guard let page = Page<Summit>(JSONValue: JSONValue)
            else { return nil }
        
        self.page = page
    }
}

public extension SummitsResponse {
    
    public struct Summit: JSONDecodable, Unique, Named {
        
        public typealias JSONKey = CoreSummit.Summit.JSONKey
        
        public let identifier: Identifier
        
        public let name: String
        
        //public let timeZone: String
        
        public let start: Date
        
        public let end: Date
        
        public let active: Bool
        
        public init?(JSONValue: JSON.Value) {
            
            guard let JSONObject = JSONValue.objectValue,
                let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
                let name = JSONObject[JSONKey.name.rawValue]?.rawValue as? String,
                let startDate = JSONObject[JSONKey.start_date.rawValue]?.rawValue as? Int,
                let endDate = JSONObject[JSONKey.end_date.rawValue]?.rawValue as? Int,
                //let timeZoneJSON = JSONObject[JSONKey.time_zone.rawValue],
                //let timeZone = TimeZone(JSONValue: timeZoneJSON),
                let active = JSONObject[JSONKey.active.rawValue]?.rawValue as? Bool
                else { return nil }
            
            self.identifier = identifier
            self.name = name
            self.start = Date(timeIntervalSince1970: TimeInterval(startDate))
            self.end = Date(timeIntervalSince1970: TimeInterval(endDate))
            //self.timeZone = timeZone.name
            self.active = active
        }
    }
}

public func == (lhs: SummitsResponse.Summit, rhs: SummitsResponse.Summit) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        //&& lhs.timeZone == rhs.timeZone
        && lhs.start == rhs.start
        && lhs.end == rhs.end
        && lhs.active == rhs.active
}
