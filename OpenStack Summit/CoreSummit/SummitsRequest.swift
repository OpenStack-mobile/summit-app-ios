//
//  SummitsRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/24/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import AeroGearHttp
import AeroGearOAuth2
import JSON

public extension Store {
    
    func summits(_ page: Int = 1, objectsPerPage: Int = 30, completion: @escaping (ErrorValue<Page<SummitsResponse.Summit>>) -> ()) {
        
        // endpoint currently not supporting paging
        // let uri = "/api/v1/summits?page=\(page)&per_page=\(objectsPerPage)&relations=none&expand=none"
        let uri = "/api/v1/summits?relations=none&expand=none"
        
        let http = self.createHTTP(.serviceAccount)
        
        let url = environment.configuration.serverURL + uri
        
        http.request(method: .get, path: url) { (responseObject, error) in
            
            guard error == nil
                else {
                    
                    if error?.code == 401 {
                        
                        // revoke and retry
                        http.authzModule?.revokeAccess { (responseObject, error) in
                            
                            guard error == nil
                                else { completion(.error(error!)); return }
                            
                            self.summits(page, objectsPerPage: objectsPerPage, completion: completion)
                        }
                    }
                    else {
                        
                        // forward error
                        completion(.error(error!))
                    }
                    
                    return
            }
            
            guard let json = try? JSON.Value(string: responseObject as! String),
                let response = SummitsResponse(json: json)
                else { completion(.error(Error.invalidResponse)); return }
            
            // success
            completion(.value(response.page))
        }
    }
}

// MARK: - Supporting Types

public struct SummitsResponse: JSONDecodable {
    
    public let page: Page<Summit>
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let page = Page<Summit>(json: JSONValue)
            else { return nil }
        
        self.page = page
    }
}

public extension SummitsResponse {
    
    public struct Summit: JSONDecodable, Unique, Named {
        
        public typealias JSONKey = CoreSummit.Summit.JSONKey
        
        public let identifier: Identifier
        
        public let name: String
        
        public let timeZone: TimeZone
        
        public let datesLabel: String?
        
        public let start: Date
        
        public let end: Date
        
        public let defaultStart: Date?
        
        public let active: Bool
        
        public init?(json JSONValue: JSON.Value) {
            
            guard let JSONObject = JSONValue.objectValue,
                let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue,
                let name = JSONObject[JSONKey.name.rawValue]?.rawValue as? String,
                let startDate = JSONObject[JSONKey.start_date.rawValue]?.integerValue,
                let endDate = JSONObject[JSONKey.end_date.rawValue]?.integerValue,
                let timeZoneJSON = JSONObject[JSONKey.time_zone.rawValue],
                let timeZone = TimeZone(json: timeZoneJSON),
                let active = JSONObject[JSONKey.active.rawValue]?.rawValue as? Bool
                else { return nil }
            
            self.identifier = identifier
            self.name = name
            self.start = Date(timeIntervalSince1970: TimeInterval(startDate))
            self.end = Date(timeIntervalSince1970: TimeInterval(endDate))
            self.timeZone = timeZone
            self.active = active
            
            self.datesLabel = JSONObject[JSONKey.dates_label.rawValue]?.rawValue as? String
            
            if let scheduleStartDate = JSONObject[JSONKey.schedule_start_date.rawValue]?.integerValue {
                
                self.defaultStart = Date(timeIntervalSince1970: TimeInterval(scheduleStartDate))
                
            } else {
                
                self.defaultStart = nil
            }
        }
    }
}

public func == (lhs: SummitsResponse.Summit, rhs: SummitsResponse.Summit) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.timeZone == rhs.timeZone
        && lhs.datesLabel == rhs.datesLabel
        && lhs.start == rhs.start
        && lhs.end == rhs.end
        && lhs.defaultStart == rhs.defaultStart
        && lhs.active == rhs.active
}
