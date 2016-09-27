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
    
    func openWebURL(url: NSURL) -> Bool {
        
        guard let components = url.pathComponents
            where components.count >= 6
            else { return false }
        
        let typeString = components[4]
        let identifierString = components[5]
        
        guard let identifier = Int(identifierString)
            else { return false }
        
        var dataType: AppActivitySummitDataType!
        
        switch typeString {
        case Event.webPathComponent: dataType = .event
        case PresentationSpeaker.webPathComponent:  dataType = .speaker
        default: return false
        }
        
        self.view(dataType, identifier: identifier)
        
        return true
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
        
        // find in cache
        guard Store.shared.realm.objects(data.realmType).filter("id = \(identifier)").first != nil
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
            
            let realmEntity = Video.RealmType.find(identifier, realm: Store.shared.realm)!
            let video = Video(realmEntity: realmEntity)
            
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
