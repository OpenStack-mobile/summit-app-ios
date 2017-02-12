//
//  ServiceProvider.swift
//  OpenStackTVService
//
//  Created by Alsey Coleman Miller on 2/11/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import SwiftFoundation
import TVServices
import CoreSummit

final class ServiceProvider: NSObject, TVTopShelfProvider {

    override init() {
        super.init()
        
        print("Launching OpenStack Summit tvOS Services Provider v\(AppVersion) Build \(AppBuild)")
        print("Using Environment: \(AppEnvironment.rawValue)")
    }

    // MARK: - TVTopShelfProvider

    let topShelfStyle: TVTopShelfContentStyle = .Sectioned

    var topShelfItems: [TVContentItem] {
        
        print("Get Top Shelf Items")
        
        return [Section.recentlyPlayed.toContentItem("Recently Played", items: recentlyPlayedItems)]
    }
    
    var recentlyPlayedItems: [TVContentItem] {
        
        let context = Store.shared.managedObjectContext
        
        let recentlyPlayed = Preferences.shared.recentlyPlayed as [NSNumber]
        
        print("Recently played videos: \(recentlyPlayed)")
        
        // fetch all videos from CoreData at once. Will be sorted by `id`.
        let fetchedVideos = try! context.managedObjects(VideoManagedObject.self,predicate: NSPredicate(format: "id IN %@", recentlyPlayed))
        
        // sort videos
        let videos = recentlyPlayed.map { playedVideo in fetchedVideos.firstMatching({ $0.identifier == playedVideo })! }
        
        return videos.map { $0.toContentItem() }
    }
}

// MARK: - Extensions

extension ServiceProvider {
    
    enum Section: String {
        
        case recentlyPlayed
        
        func toContentItem(title: String, items: [TVContentItem]) -> TVContentItem {
            
            let identifier = TVContentIdentifier(identifier: rawValue, container: nil)!
            
            let contentItem = TVContentItem(contentIdentifier: identifier)!
            
            contentItem.title = title
            
            contentItem.topShelfItems = items
            
            return contentItem
        }
    }
}

extension VideoManagedObject {
    
    func toContentItem() -> TVContentItem {
        
        let serviceURL = ServiceURL(identifier: self.identifier).url
        
        let identifier = TVContentIdentifier(identifier: serviceURL.absoluteString!, container: nil)!
        
        let contentItem = TVContentItem(contentIdentifier: identifier)!
        
        contentItem.title = event.name
        
        contentItem.creationDate = event.start
        
        contentItem.imageURL = NSURL(youtubeThumbnail: youtube)
        
        contentItem.imageShape = .Square
        
        contentItem.displayURL = serviceURL
        
        return contentItem
    }
}
