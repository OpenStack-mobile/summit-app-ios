//
//  LoggedInMemberRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import RealmSwift
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    func loggedInMember(summitIdentifier: Identifier? = nil, completion: (ErrorValue<Member>) -> ()) {
        
        let summitID: String
        
        if let identifier = summitIdentifier {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/" + summitID + "/attendees/me?expand=speaker,feedback,tickets"
        
        let URL = configuration[.ServerURL] + URI
        
        let http = self.createHTTP(.OpenIDGetFormUrlEncoded)
        
        http.GET(URL, parameters: nil, completionHandler: { (responseObject, error) in
          
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String),
                let entity = Member(JSONValue: json)
                else { completion(.Error(Error.InvalidResponse)); return }
            
            // cache
            try! self.realm.write { let _ = entity.save(self.realm) }
            
            // success
            completion(.Value(entity))
        })
    }
}
