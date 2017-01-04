//
//  ListMembersRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/28/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    func members(filter: MemberListRequest.Filter? = nil,
                 sort: MemberListRequest.SortDescriptor? = nil,
                 page: Int = 1,
                 perPage: Int = 10,
                 completion: (ErrorValue<Page<Member>>) -> ()) {
        
        let urlComponents = NSURLComponents(string: environment.configuration.serverURL + "/api/v1/members")!
        
        var queryItems = [NSURLQueryItem]()
        
        queryItems.append(NSURLQueryItem(name: "page", value: "\(page)"))
        queryItems.append(NSURLQueryItem(name: "per_page", value: "\(perPage)"))
        
        if let filter = filter {
            
            let queryValueString = filter.property.rawValue + "==" + filter.value
            
            queryItems.append(NSURLQueryItem(name: "filter", value: queryValueString))
        }
        
        if let sort = sort {
            
            queryItems.append(NSURLQueryItem(name: "sort", value: sort.rawValue))
        }
        
        urlComponents.queryItems = queryItems
        
        let url = urlComponents.URL!.absoluteString!
        
        let http = self.createHTTP(.ServiceAccount)
        
        let context = privateQueueManagedObjectContext
        
        http.GET(url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String),
                let page = Page<Member>(JSONValue: json)
                else { completion(.Error(Error.InvalidResponse)); return }
            
            // cache
            try! context.performErrorBlockAndWait {
                
                try page.items.save(context)
                
                try context.save()
            }
            
            // success
            completion(.Value(page))
        }
    }
}

// MARK: - Supporting Types

public struct MemberListRequest {
    
    public var page: Int
    
    public var perPage: Int
    
    public var filter: Filter?
    
    public var sort: SortDescriptor?
}

public extension MemberListRequest {
    
    public struct Filter {
        
        public enum Property: String {
            
            case firstName = "first_name"
            case lastName = "last_name"
            case irc
            case twitter
        }
        
        public var value: String
        
        public var property: Property
        
        public init(value: String, property: Property) {
            
            self.value = value
            self.property = property
        }
    }
    
    public enum SortDescriptor: String {
        
        case firstName = "first_name"
        case lastName = "last_name"
        case identifier = "id"
        
        public init() { self = .identifier }
    }
}



