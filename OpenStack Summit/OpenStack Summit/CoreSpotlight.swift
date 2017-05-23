//
//  CoreSpotlight.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/29/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import Foundation
import CoreSpotlight
import MobileCoreServices
import CoreSummit
import Haneke
import CoreData

// MARK: - Model Extensions


protocol CoreSpotlightSearchable: AppActivitySummitData {
    
    static var itemContentType: String { get }
    
    static var searchDomain: String { get }
    
    var searchIdentifier: String { get }
    
    func toSearchableItem() -> CSSearchableItem
}


extension CoreSpotlightSearchable where Self: CoreSummit.Unique {
    
    var searchIdentifier: String { return Self.activityDataType.rawValue + "/" + "\(identifier)" }
}


extension Event: CoreSpotlightSearchable {
    
    static var itemContentType: String { return kUTTypeText as String }
    
    static let searchDomain = "org.openstack.SummitEvent"
    
    func toSearchableItem() -> CSSearchableItem {
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: type(of: self).itemContentType)
        
        attributeSet.displayName = name
        attributeSet.startDate = start
        attributeSet.endDate = end
        
        let tags = self.tags.map { $0.name }
        attributeSet.keywords = tags
        
        if let descriptionText = self.descriptionText,
            let data = descriptionText.data(using: String.Encoding.utf8),
            let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil) {
            
            attributeSet.contentDescription = attributedString.string
        }
        
        return CSSearchableItem(uniqueIdentifier: searchIdentifier, domainIdentifier: type(of: self).searchDomain, attributeSet: attributeSet)
    }
}


extension Speaker: CoreSpotlightSearchable {
    
    static var itemContentType: String { return kUTTypeText as String }
    
    static let searchDomain = "org.openstack.PresentationSpeaker"
    
    func toSearchableItem() -> CSSearchableItem {
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: type(of: self).itemContentType)
        
        attributeSet.displayName = name
        attributeSet.contentDescription = title
        
        /*
        // user image
        let imageURLString = pictureURL.stringByReplacingOccurrencesOfString("https", withString: "http", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        if let imageURL = NSURL(string: imageURLString) {
            
            attributeSet.thumbnailData = NSData(contentsOfURL: imageURL)
        }*/
        
        return CSSearchableItem(uniqueIdentifier: searchIdentifier, domainIdentifier: type(of: self).searchDomain, attributeSet: attributeSet)
    }
}


extension Video: CoreSpotlightSearchable {
    
    static var itemContentType: String { return kUTTypeVideo as String }
    
    static let searchDomain = "org.openstack.Video"
    
    func toSearchableItem() -> CSSearchableItem {
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: type(of: self).itemContentType)
        
        attributeSet.displayName = name
        
        if let descriptionText = self.descriptionText,
            let data = descriptionText.data(using: String.Encoding.utf8),
            let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil) {
            
            attributeSet.contentDescription = attributedString.string
        }
        
        attributeSet.local = false
        
        return CSSearchableItem(uniqueIdentifier: searchIdentifier, domainIdentifier: type(of: self).searchDomain, attributeSet: attributeSet)
    }
}


extension Venue: CoreSpotlightSearchable {
    
    static var itemContentType: String { return kUTTypeText as String }
    
    static let searchDomain = "org.openstack.Venue"
    
    func toSearchableItem() -> CSSearchableItem {
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: type(of: self).itemContentType)
        
        attributeSet.displayName = name
        
        if let descriptionText = self.descriptionText,
            let data = descriptionText.data(using: String.Encoding.utf8),
            let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil) {
            
            attributeSet.contentDescription = attributedString.string
        }
        
        attributeSet.country = country
        attributeSet.city = city
        attributeSet.longitude = location?.longitude as NSNumber?
        attributeSet.latitude = location?.latitude as NSNumber?
        attributeSet.namedLocation = name
        
        return CSSearchableItem(uniqueIdentifier: searchIdentifier, domainIdentifier: type(of: self).searchDomain, attributeSet: attributeSet)
    }
}


extension VenueRoom: CoreSpotlightSearchable {
    
    static var itemContentType: String { return kUTTypeText as String }
    
    static let searchDomain = "org.openstack.VenueRoom"
    
    func toSearchableItem() -> CSSearchableItem {
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: type(of: self).itemContentType)
        
        attributeSet.displayName = name
        
        if let descriptionText = self.descriptionText,
            let data = descriptionText.data(using: String.Encoding.utf8),
            let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil) {
            
            attributeSet.contentDescription = attributedString.string
        }
        
        attributeSet.namedLocation = name
        
        return CSSearchableItem(uniqueIdentifier: searchIdentifier, domainIdentifier: type(of: self).searchDomain, attributeSet: attributeSet)
    }
}

// MARK: - Controller

/// Updates the CoreSpotlight index from Realm changes.

final class SpotlightController: NSObject, NSFetchedResultsControllerDelegate {
    
    static let shared = SpotlightController()
    
    let spotlightIndex = CSSearchableIndex.default()
    
    var log: ((String) -> ())?
    
    private let queue = DispatchQueue(label: "CoreSpotlight Update Queue")
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }

    private override init() {
        
        super.init()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(managedObjectContextObjectsDidChange),
            name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
            object: Store.shared.managedObjectContext)
        
    }
    
    @objc private func managedObjectContextObjectsDidChange(notification: NSNotification) {
        
        func completionHandler(error: Swift.Error?) {
            
            if let error = error {
                
                self.log?("Error updating Spotlight index: \(error)")
                
            } else {
                
                self.log?("Updated Spotlight index")
            }
        }
        
        // index new and updated items
        
        var indexableManagedObjects = [NSManagedObject]()
        
        if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as! Set<NSManagedObject>? {
            
            indexableManagedObjects.append(contentsOf: updatedObjects)
        }
        
        if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as! Set<NSManagedObject>? {
            
            indexableManagedObjects.append(contentsOf: insertedObjects)
        }
        
        if indexableManagedObjects.isEmpty == false {
            
            let searchableItems = indexableManagedObjects
                .reduce(to: CoreSpotlightSearchableManagedObject.self)
                .map { $0.toSearchable().toSearchableItem() }
            
            if searchableItems.isEmpty == false {
                
                spotlightIndex.indexSearchableItems(searchableItems, completionHandler: completionHandler)
            }
        }
        
        // delete items
        
        if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as! Set<NSManagedObject>? {
            
            let searchableItems = deletedObjects
                .reduce(to: CoreSpotlightSearchableManagedObject.self)
                .map { $0.toSearchable().searchIdentifier }
            
            if searchableItems.isEmpty == false {
                
                spotlightIndex.deleteSearchableItems(withIdentifiers: searchableItems, completionHandler: completionHandler)
            }
        }
    }
}


protocol CoreSpotlightSearchableManagedObject: class {
    
    func toSearchable() -> CoreSpotlightSearchable
}


extension EventManagedObject: CoreSpotlightSearchableManagedObject {
    
    func toSearchable() -> CoreSpotlightSearchable {
        
        return Event(managedObject: self)
    }
}


extension SpeakerManagedObject: CoreSpotlightSearchableManagedObject {
    
    func toSearchable() -> CoreSpotlightSearchable {
        
        return Speaker(managedObject: self)
    }
}


extension VideoManagedObject: CoreSpotlightSearchableManagedObject {
    
    func toSearchable() -> CoreSpotlightSearchable {
        
        return Video(managedObject: self)
    }
}


extension VenueManagedObject: CoreSpotlightSearchableManagedObject {
    
    func toSearchable() -> CoreSpotlightSearchable {
        
        return Venue(managedObject: self)
    }
}


extension VenueRoomManagedObject: CoreSpotlightSearchableManagedObject {
    
    func toSearchable() -> CoreSpotlightSearchable {
        
        return VenueRoom(managedObject: self)
    }
}


