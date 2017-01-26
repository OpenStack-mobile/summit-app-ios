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
        
        let request = MemberListRequest(page: page, perPage: perPage, filter: filter, sort: sort)
        
        let url = request.toURL(environment.configuration.serverURL)
        
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
    
    public func toURL(serverURL: String) -> String {
        
        let urlComponents = NSURLComponents(string: serverURL + "/api/v1/members")!
        
        var queryItems = [NSURLQueryItem]()
        
        queryItems.append(NSURLQueryItem(name: "page", value: "\(page)"))
        queryItems.append(NSURLQueryItem(name: "per_page", value: "\(perPage)"))
        queryItems.append(NSURLQueryItem(name: "expand", value: "groups"))
        
        if let filter = filter {
            
            let queryValueString = filter.property.rawValue + filter.filterOperator.rawValue + filter.value
            
            queryItems.append(NSURLQueryItem(name: "filter", value: queryValueString))
        }
        
        if let sort = sort {
            
            queryItems.append(NSURLQueryItem(name: "sort", value: sort.rawValue))
        }
        
        urlComponents.queryItems = queryItems
        
        return urlComponents.URL!.absoluteString!
    }
}

public extension MemberListRequest {
    
    public struct Filter {
        
        public enum Property: String {
            
            case firstName = "first_name"
            case lastName = "last_name"
            case twitter
            case irc
        }
        
        public enum Operator: String {
            
            case equal = "=="
            case contains = "=@"
        }
        
        public var value: String
        
        public var property: Property
        
        public var filterOperator: Operator
        
        public init(value: String, property: Property, filterOperator: Operator = .contains) {
            
            self.value = value
            self.property = property
            self.filterOperator = filterOperator
        }
    }
    
    public enum SortDescriptor: String {
        
        case firstName = "first_name"
        case lastName = "last_name"
        case identifier = "id"
        
        public init() { self = .identifier }
    }
}
