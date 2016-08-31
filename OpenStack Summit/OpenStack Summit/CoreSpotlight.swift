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
import RealmSwift
import MobileCoreServices
import CoreSummit
import Haneke

// MARK: - Model Extensions

@available(iOS 9.0, *)
protocol CoreSpotlightSearchable: AppActivitySummitData {
    
    static var itemContentType: String { get }
    
    static var searchDomain: String { get }
    
    func toSearchableItem() -> CSSearchableItem
}

@available(iOS 9.0, *)
extension CoreSpotlightSearchable where Self: CoreSummit.Unique {
    
    var searchIdentifier: String { return Self.activityDataType.rawValue + "/" + "\(identifier)" }
}

@available(iOS 9.0, *)
extension SummitEvent: CoreSpotlightSearchable {
    
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
extension PresentationSpeaker: CoreSpotlightSearchable {
    
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
final class SpotlightController {
    
    static let shared = SpotlightController()
    
    let spotlightIndex = CSSearchableIndex.defaultSearchableIndex()
    
    var log: ((String) -> ())?
    
    private let queue = dispatch_queue_create("CoreSpotlight Update Queue", nil)
    
    private var realmNotificationToken: RealmSwift.NotificationToken!
    
    deinit {
        
        realmNotificationToken?.stop()
    }

    private init() {
        
        self.realmNotificationToken = Store.shared.realm.addNotificationBlock({ (notification, realm) in
            
            self.update {
                if let error = $0 { self.log?("Error: \(error.localizedDescription)") }
                else { self.log?("Updated SpotLight index") }
            }
        })
    }
    
    func update(index: CSSearchableIndex = CSSearchableIndex.defaultSearchableIndex(), completionHandler: ((NSError?) -> ())? = nil) {
        
        index.deleteAllSearchableItemsWithCompletionHandler { (deleteError) in
            
            if let error = deleteError {
                
                completionHandler?(error)
                return
            }
            
            // get all speakers and events
            dispatch_async(dispatch_get_main_queue()) {
                
                let realmEvents = SummitEvent.from(realm: Store.shared.realm.objects(RealmSummitEvent))
                let realmSpeakers = PresentationSpeaker.from(realm: Store.shared.realm.objects(RealmPresentationSpeaker))
                let realmVideos = Video.from(realm: Store.shared.realm.objects(RealmVideo))
                let realmVenues = Venue.from(realm: Store.shared.realm.objects(RealmVenue))
                let realmVenueRooms = VenueRoom.from(realm: Store.shared.realm.objects(RealmVenueRoom))
                
                dispatch_async(self.queue, {
                    
                    let events = realmEvents.map { $0.toSearchableItem() }
                    let speakers = realmSpeakers.map { $0.toSearchableItem() }
                    let videos = realmVideos.map { $0.toSearchableItem() }
                    let venues = realmVenues.map { $0.toSearchableItem() }
                    let venueRooms = realmVenueRooms.map { $0.toSearchableItem() }
                    
                    let items = events + speakers + videos + venues + venueRooms
                    
                    index.indexSearchableItems(items, completionHandler: completionHandler)
                })
            }
        }
    }
}
