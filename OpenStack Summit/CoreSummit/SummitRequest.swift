//
//  SummitRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/14/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import OAuthSwift

public extension Store {
    
    func summit(identifier: Int? = nil, completion: ErrorValue<Summit> -> ()) {
        
        let summitID: String
        
        if let identifier = identifier {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/\(summitID)?expand=locations,sponsors,summit_types,event_types,presentation_categories,schedule"
        
        let url = Constants.Urls.ResourceServerBaseUrl + URI
                
        let oauth = OAuth2Swift(
            consumerKey:    Constants.Auth.ClientIdServiceAccount,
            consumerSecret: Constants.Auth.SecretServiceAccount,
            authorizeUrl:   Constants.Urls.AuthServerBaseUrl + "/oauth2/auth",
            responseType:   "code"
        )
        
        oauth.authorizeWithCallbackURL(NSURL(string: "org.openstack.ios.openstack-summit://oauthcallback/")!,
                                       scope: "\(Constants.Urls.ResourceServerBaseUrl)/summits/read",
                                       state: "",
                                       success: { (credential, response, parameters) in
                                        
                                        oauth.client.get(url, success: { (data, response) in
                                            
                                            guard let jsonString = String(UTF8Data: Data(foundation: data)),
                                                let json = JSON.Value(string: jsonString),
                                                let entity = Summit(JSONValue: json)
                                                else { completion(.Error(Store.Error.InvalidResponse)); return }
                                            
                                            // success
                                            completion(.Value(entity))
                                            
                                            }, failure: { (error) in
                                                
                                                completion(.Error(error))
                                        })
                                        
        }, failure: { (error) in
            
            completion(.Error(error))
        })
        
        
    }
}

private let jsonError = NSError(domain: "There was an error deserializing current summit", code: 6001, userInfo: nil)
