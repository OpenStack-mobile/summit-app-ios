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
extension SummitEvent {
    
    static var itemContentType: String { return kUTTypeText as String }
    
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
        
        //attributeSet.thumbnailData = UIImagePNGRepresentation(image)!
        
        return CSSearchableItem(uniqueIdentifier: "\(identifier)", domainIdentifier: nil, attributeSet: attributeSet)
    }
}

@available(iOS 9.0, *)
extension PresentationSpeaker {
    
    static var itemContentType: String { return kUTTypeText as String }
    
    func toSearchableItem() -> CSSearchableItem {
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: self.dynamicType.itemContentType)
        
        var description = ""
        
        if let twitter = self.twitter {
            
            description += twitter + "\n"
        }
        
        if let biography = self.biography {
            
            description += biography + "\n"
        }
        
        attributeSet.displayName = name
        attributeSet.contentDescription = description
        
        // user image
        //Shared.imageCache.
        //attributeSet.thumbnailData = UIImagePNGRepresentation(image)!
        
        return CSSearchableItem(uniqueIdentifier: "\(identifier)", domainIdentifier: nil, attributeSet: attributeSet)
    }
}

// MARK: - Controller

@available(iOS 9.0, *)
func UpdateSpotlight(index: CSSearchableIndex = CSSearchableIndex.defaultSearchableIndex(), completionHandler: ((NSError?) -> ())? = nil) {
    
    index.deleteAllSearchableItemsWithCompletionHandler { (deleteError) in
        
        if let error = deleteError {
            
            completionHandler?(error)
            return
        }
        
        // get all speakers and events
        dispatch_async(dispatch_get_main_queue()) {
            
            let events = SummitEvent.from(realm: Store.shared.realm.objects(RealmSummitEvent)).map { $0.toSearchableItem() }
            let speakers = PresentationSpeaker.from(realm: Store.shared.realm.objects(RealmPresentationSpeaker)).map { $0.toSearchableItem() }
            
            let items = events + speakers
            
            index.indexSearchableItems(items, completionHandler: completionHandler)
        }
    }
}

/// Updates the CoreSpotlight index from Realm changes.
@available(iOS 9.0, *)
final class SpotlightController {
    
    static let shared = SpotlightController()
    
    let spotlightIndex = CSSearchableIndex.defaultSearchableIndex()
    
    var log: ((String) -> ())?

    
}
