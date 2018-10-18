//
//  SummitActivityHandling.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreSummit

protocol SummitActivityHandling {
    
    func view(data: AppActivitySummitDataType, identifier: Identifier)
    
    func view(screen: AppActivityScreen)
    
    func search(_ searchTerm: String)
}

extension SummitActivityHandling {
    
    /// Opens URL of universal domain.
    func openWeb(url: URL) -> Bool {
        
        if url.pathComponents.last == "summit-schedule" {
            
            self.view(screen: .events)
            return true
        }
        
        // perform search
        if url.pathComponents.last == "global-search",
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let searchQuery = urlComponents.queryItems?.first(where: { $0.name == "t" && ($0.value ?? "").isEmpty == false }),
            let searchTerm = searchQuery.value {
            
            self.search(searchTerm)
            return true
        }
        
        let typeString: String
        let identifierString: String
        
        let components = url.pathComponents
        
        if let scheme = url.scheme,
            scheme == "http" || scheme == "https" {
            
            guard components.count >= 6
                else { return false }
            
            typeString = components[4]
            identifierString = components[5]
            
        } else {
            
            guard let host = url.host,
                components.count >= 2
                else { return false }
            
            typeString = host
            identifierString = components[1]
        }
        
        // show data
        guard let identifier = Identifier(identifierString),
            let type = WebPathComponent(rawValue: typeString)
            else { return false }
        
        let dataType = AppActivitySummitDataType(webPathComponent: type)
        
        /*guard self.canView(data: dataType, identifier: identifier)
            else { return false }*/
        
        self.view(data: dataType, identifier: identifier)
        
        return true
    }
    
    func canView(data: AppActivitySummitDataType, identifier: Identifier) -> Bool {
        
        // find in cache
        guard let _ = try! data.managedObject.find(identifier, context: Store.shared.managedObjectContext)
            else { return false }
        
        return true
    }
}

#if os(iOS)

// MARK: - View Controller

protocol SummitActivityHandlingViewController: class, SummitActivityHandling { }

extension SummitActivityHandlingViewController {
    
    func view(data: AppActivitySummitDataType, identifier: Identifier) {
        
        guard let viewController = self as? UIViewController
            else { fatalError() }
        
        viewController.show(data: data, identifier: identifier)
    }
    
    func view(screen: AppActivityScreen) {
        
        AppDelegate.shared.view(screen: screen)
    }
    
    func search(_ searchTerm: String) {
        
        AppDelegate.shared.search(searchTerm)
    }
}
    
extension UIViewController {
    
    func show(data: AppActivitySummitDataType, identifier: Identifier) {
        
        let context = Store.shared.managedObjectContext
        
        switch data {
            
        case .event:
            
            let eventDetailViewController = R.storyboard.event.eventDetailViewController()!
            eventDetailViewController.event = identifier
            self.show(eventDetailViewController, sender: nil)
            
        case .speaker:
            
            let memberProfileViewController = MemberProfileViewController(profile: .speaker(identifier))
            self.show(memberProfileViewController, sender: nil)
            
        case .video:
            
            // find in cache
            guard let video = try! Video.find(identifier, context: context)
                else { return }
            
            self.play(video: video)
            
        case .venue, .venueRoom:
            
            self.show(location: identifier)
        }
    }
}

#endif
