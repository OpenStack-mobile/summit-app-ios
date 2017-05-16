//
//  ListMembersRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/28/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import AeroGearHttp
import AeroGearOAuth2
import JSON

public extension Store {
    
    func members(_ filter: MemberListRequest.Filter? = nil,
                 sort: MemberListRequest.SortDescriptor? = nil,
                 page: Int = 1,
                 perPage: Int = 10,
                 completion: @escaping (ErrorValue<Page<Member>>) -> ()) {
        
        let request = MemberListRequest(page: page, perPage: perPage, filter: filter, sort: sort)
        
        let url = request.toURL(environment.configuration.serverURL)
        
        let http = self.createHTTP(.serviceAccount)
        
        let context = privateQueueManagedObjectContext
        
        http.request(method: .get, path: url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.error(error!)); return }
            
            guard let json = try? JSON.Value(string: responseObject as! String),
                let page = Page<Member>(json: json)
                else { completion(.error(Error.invalidResponse)); return }
            
            // cache
            try! context.performErrorBlockAndWait {
                
                let _ = try page.items.save(context)
                
                try context.validateAndSave()
            }
            
            // success
            completion(.value(page))
        }
    }
}

// MARK: - Supporting Types

public struct MemberListRequest {
    
    public var page: Int
    
    public var perPage: Int
    
    public var filter: Filter?
    
    public var sort: SortDescriptor?
    
    public func toURL(_ serverURL: String) -> String {
        
        var urlComponents = URLComponents(string: serverURL + "/api/v1/members")!
        
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
        queryItems.append(URLQueryItem(name: "per_page", value: "\(perPage)"))
        queryItems.append(URLQueryItem(name: "expand", value: "groups"))
        
        if let filter = filter {
            
            let queryValueString = filter.property.rawValue + filter.filterOperator.rawValue + filter.value
            
            queryItems.append(URLQueryItem(name: "filter", value: queryValueString))
        }
        
        if let sort = sort {
            
            queryItems.append(URLQueryItem(name: "sort", value: sort.rawValue))
        }
        
        urlComponents.queryItems = queryItems
        
        return urlComponents.url!.absoluteString
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
