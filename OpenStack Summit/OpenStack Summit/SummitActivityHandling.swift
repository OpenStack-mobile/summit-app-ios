//
//  SummitActivityHandling.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import CoreSummit

protocol SummitActivityHandling {
    
    func view(data: AppActivitySummitDataType, identifier: Identifier) -> Bool
    
    func view(screen: AppActivityScreen)
}

extension SummitActivityHandling {
    
    /// Opens URL of universal domain.
    func openWebURL(url: NSURL) -> Bool {
        
        guard let components = url.pathComponents
            where components.count >= 6
            else { return false }
        
        let typeString = components[4]
        let identifierString = components[5]
        
        guard let identifier = Int(identifierString),
            let type = WebPathComponent(rawValue: typeString)
            else { return false }
        
        let dataType = AppActivitySummitDataType(webPathComponent: type)
        
        return self.view(dataType, identifier: identifier)
    }
    
    /// Opens URL of custom scheme.
    func openSchemeURL(url: NSURL) -> Bool {
        
        guard let typeString = url.host, let components = url.pathComponents
            where components.count >= 2
            else { return false }
        
        let identifierString = components[1]
        
        guard let identifier = Int(identifierString),
            let type = WebPathComponent(rawValue: typeString)
            else { return false }
        
        let dataType = AppActivitySummitDataType(webPathComponent: type)
        
        return self.view(dataType, identifier: identifier)
    }
}

// MARK: - View Controller

protocol SummitActivityHandlingViewController: class, SummitActivityHandling {
    
    func showViewController(vc: UIViewController, sender: AnyObject?)
    
    func playVideo(video: Video)
    
    func showLocationDetail(location: Identifier)
}

extension SummitActivityHandlingViewController {
    
    func view(data: AppActivitySummitDataType, identifier: Identifier) -> Bool  {
        
        let context = Store.shared.managedObjectContext
        
        // find in cache
        guard let managedObject = try! data.managedObject.find(identifier, context: context)
            else { return false }
        
        switch data {
            
        case .event:
            
            let eventDetailVC = R.storyboard.event.eventDetailViewController()!
            eventDetailVC.event = identifier
            self.showViewController(eventDetailVC, sender: nil)
            
        case .speaker:
            
            let memberProfileVC = MemberProfileViewController(profile: .speaker(identifier))
            self.showViewController(memberProfileVC, sender: nil)
            
        case .video:
            
            let video = Video(managedObject: managedObject as! VideoManagedObject)
            
            self.playVideo(video)
            
        case .venue, .venueRoom:
            
            self.showLocationDetail(identifier)
        }
        
        return true
    }
    
    func view(screen: AppActivityScreen) {
        
        AppDelegate.shared.view(screen)
    }
}
