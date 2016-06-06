//
//  SummitRemoteDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import AeroGearHttp
import AeroGearOAuth2
import SwiftFoundation
import CoreSummit

public protocol SummitRemoteDataStoreProtocol {
    
    func getActive(completion: (ErrorValue<Summit>) -> ())
}


public final class SummitRemoteDataStore: SummitRemoteDataStoreProtocol {
        
    public let httpFactory: HttpFactory = HttpFactory()
    
    public func getActive(completion: (ErrorValue<Summit>) -> ()) {
        
        let http = httpFactory.create(HttpType.ServiceAccount)
        
        let url = "\(Constants.Urls.ResourceServerBaseUrl)/api/v1/summits/current?expand=locations,sponsors,summit_types,event_types,presentation_categories,schedule"
        
        http.GET(url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            let foundationJSON = NSJSONSerialization.Value(rawValue: responseObject!)!
            let json = JSON.Value(foundation: foundationJSON)
            
            // parse
            guard let entity = Summit(JSONValue: json)
                else { completion(.Error(SummitRemoteDataStore.jsonError)); return }
            
            // success
            completion(.Value(entity))
        }
    }
}

// MARK: - Private

private extension SummitRemoteDataStore {
    
    static let jsonError = NSError(domain: "There was an error deserializing current summit", code: 6001, userInfo: nil)
}
