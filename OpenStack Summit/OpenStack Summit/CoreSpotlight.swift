//
//  CoreSpotlight.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/29/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import SwiftFoundation
import CoreSpotlight
import MobileCoreServices
import CoreSummit
import Haneke
import CoreData

// MARK: - Model Extensions

@available(iOS 9.0, *)
protocol CoreSpotlightSearchable: AppActivitySummitData {
    
    static var itemContentType: String { get }
    
    static var searchDomain: String { get }
    
    var searchIdentifier: String { get }
    
    func toSearchableItem() -> CSSearchableItem
}

@available(iOS 9.0, *)
extension CoreSpotlightSearchable where Self: CoreSummit.Unique {
    
    var searchIdentifier: String { return Self.activityDataType.rawValue + "/" + "\(identifier)" }
}

@available(iOS 9.0, *)
extension Event: CoreSpotlightSearchable {
    
    static var itemContentType: String { return kUTTypeText as String }
    
    static let searchDomain = "org.openstack.SummitEvent"
    
    func toSearchableItem() -> CSSearchableItem {
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: self.dynamicType.itemContentType)
        
        attributeSet.displayName = name
        attributeSet.startDate = start.toFoundation()
        attributeSet.endDate = end.toFoundation()
        
        let tags = self.tags.map { $0.name }
        attributeSet.keywords = tags
        
        if let descriptionText = self.descriptionText,
            let data = descriptionText.dataUsingEncoding(NSUTF8StringEncoding),
            let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil) {
            
            attributeSet.contentDescription = attributedString.string
        }
        
        return CSSearchableItem(uniqueIdentifier: searchIdentifier, domainIdentifier: self.dynamicType.searchDomain, attributeSet: attributeSet)
    }
}

@available(iOS 9.0, *)
extension Speaker: CoreSpotlightSearchable {
    
    static var itemContentType: String { return kUTTypeText as String }
    
    static let searchDomain = "org.openstack.PresentationSpeaker"
    
    func toSearchableItem() -> CSSearchableItem {
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: self.dynamicType.itemContentType)
        
        attributeSet.displayName = name
        attributeSet.contentDescription = title
        
        /*
        // user image
        let imageURLString = pictureURL.stringByReplacingOccurrencesOfString("https", withString: "http", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        if let imageURL = NSURL(string: imageURLString) {
            
            attributeSet.thumbnailData = NSData(contentsOfURL: imageURL)
        }*/
        
        return CSSearchableItem(uniqueIdentifier: searchIdentifier, domainIdentifier: self.dynamicType.searchDomain, attributeSet: attributeSet)
    }
}

@available(iOS 9.0, *)
extension Video: CoreSpotlightSearchable {
    
    static var itemContentType: String { return kUTTypeVideo as String }
    
    static let searchDomain = "org.openstack.Video"
    
    func toSearchableItem() -> CSSearchableItem {
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: self.dynamicType.itemContentType)
        
        attributeSet.displayName = name
        
        if let descriptionText = self.descriptionText,
            let data = descriptionText.dataUsingEncoding(NSUTF8StringEncoding),
            let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil) {
            
            attributeSet.contentDescription = attributedString.string
        }
        
        attributeSet.local = false
        
        return CSSearchableItem(uniqueIdentifier: searchIdentifier, domainIdentifier: self.dynamicType.searchDomain, attributeSet: attributeSet)
    }
}

@available(iOS 9.0, *)
extension Venue: CoreSpotlightSearchable {
    
    static var itemContentType: String { return kUTTypeText as String }
    
    static let searchDomain = "org.openstack.Venue"
    
    func toSearchableItem() -> CSSearchableItem {
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: self.dynamicType.itemContentType)
        
        attributeSet.displayName = name
        
        if let descriptionText = self.descriptionText,
            let data = descriptionText.dataUsingEncoding(NSUTF8StringEncoding),
            let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil) {
            
            attributeSet.contentDescription = attributedString.string
        }
        
        attributeSet.country = country
        attributeSet.city = city
        attributeSet.longitude = location?.longitude
        attributeSet.latitude = location?.latitude
        attributeSet.namedLocation = name
        
        return CSSearchableItem(uniqueIdentifier: searchIdentifier, domainIdentifier: self.dynamicType.searchDomain, attributeSet: attributeSet)
    }
}

@available(iOS 9.0, *)
extension VenueRoom: CoreSpotlightSearchable {
    
    static var itemContentType: String { return kUTTypeText as String }
    
    static let searchDomain = "org.openstack.VenueRoom"
    
    func toSearchableItem() -> CSSearchableItem {
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: self.dynamicType.itemContentType)
        
        attributeSet.displayName = name
        
        if let descriptionText = self.descriptionText,
            let data = descriptionText.dataUsingEncoding(NSUTF8StringEncoding),
            let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil) {
            
            attributeSet.contentDescription = attributedString.string
        }
        
        attributeSet.namedLocation = name
        
        return CSSearchableItem(uniqueIdentifier: searchIdentifier, domainIdentifier: self.dynamicType.searchDomain, attributeSet: attributeSet)
    }
}

// MARK: - Controller

/// Updates the CoreSpotlight index from Realm changes.
@available(iOS 9.0, *)
final class SpotlightController: NSObject, NSFetchedResultsControllerDelegate {
    
    static let shared = SpotlightController()
    
    let spotlightIndex = CSSearchableIndex.defaultSearchableIndex()
    
    var log: ((String) -> ())?
    
    private let queue = dispatch_queue_create("CoreSpotlight Update Queue", nil)
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    private override init() {
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(managedObjectContextObjectsDidChange),
            name: NSManagedObjectContextObjectsDidChangeNotification,
            object: Store.shared.managedObjectContext)
        
    }
    
    @objc private func managedObjectContextObjectsDidChange(notification: NSNotification) {
        
        func completionHandler(error: NSError?) {
            
            if let error = error {
                
                self.log?("Error updating Spotlight index: \(error)")
                
            } else {
                
                self.log?("Updated Spotlight index")
            }
        }
        
        // index new and updated items
        
        var indexableManagedObjects = [NSManagedObject]()
        
        if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as! Set<NSManagedObject>? {
            
            indexableManagedObjects.appendContentsOf(updatedObjects)
        }
        
        if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as! Set<NSManagedObject>? {
            
            indexableManagedObjects.appendContentsOf(insertedObjects)
        }
        
        if indexableManagedObjects.isEmpty == false {
            
            let searchableItems = indexableManagedObjects
                .reduce(to: CoreSpotlightSearchableManagedObject.self)
                .map { $0.toSearchable().toSearchableItem() }
            
            spotlightIndex.indexSearchableItems(searchableItems, completionHandler: completionHandler)
        }
        
        // delete items
        
        if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as! Set<NSManagedObject>? {
            
            let searchableItems = deletedObjects
                .reduce(to: CoreSpotlightSearchableManagedObject.self)
                .map { $0.toSearchable().searchIdentifier }
            
            spotlightIndex.deleteSearchableItemsWithIdentifiers(searchableItems, completionHandler: completionHandler)
        }
    }
}

@available(iOS 9.0, *)
protocol CoreSpotlightSearchableManagedObject: class {
    
    func toSearchable() -> CoreSpotlightSearchable
}

@available(iOS 9.0, *)
extension EventManagedObject: CoreSpotlightSearchableManagedObject {
    
    func toSearchable() -> CoreSpotlightSearchable {
        
        return Event(managedObject: self)
    }
}

@available(iOS 9.0, *)
extension SpeakerManagedObject: CoreSpotlightSearchableManagedObject {
    
    func toSearchable() -> CoreSpotlightSearchable {
        
        return Speaker(managedObject: self)
    }
}

@available(iOS 9.0, *)
extension VideoManagedObject: CoreSpotlightSearchableManagedObject {
    
    func toSearchable() -> CoreSpotlightSearchable {
        
        return Video(managedObject: self)
    }
}

@available(iOS 9.0, *)
extension VenueManagedObject: CoreSpotlightSearchableManagedObject {
    
    func toSearchable() -> CoreSpotlightSearchable {
        
        return Venue(managedObject: self)
    }
}

@available(iOS 9.0, *)
extension VenueRoomManagedObject: CoreSpotlightSearchableManagedObject {
    
    func toSearchable() -> CoreSpotlightSearchable {
        
        return VenueRoom(managedObject: self)
    }
}


