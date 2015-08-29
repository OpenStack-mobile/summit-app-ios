//
//  DataStoreAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/20/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon
import RealmSwift

public class DataStoreAssembly: TyphoonAssembly {
    dynamic func deserializerFactory() -> AnyObject {
        return TyphoonDefinition.withClass(DeserializerFactory.self) {
            (definition) in
            
            definition.injectProperty("summitDeserializer", with: self.summitDeserializer())
            definition.injectProperty("companyDeserializer", with: self.companyDeserializer())
            definition.injectProperty("eventTypeDeserializer", with: self.eventTypeDeserializer())
            definition.injectProperty("summitTypeDeserializer", with: self.summitTypeDeserializer())
            definition.injectProperty("locationDeserializer", with: self.locationDeserializer())
            definition.injectProperty("venueDeserializer", with: self.venueDeserializer())
            definition.injectProperty("venueRoomDeserializer", with: self.venueRoomDeserializer())
            definition.injectProperty("summitEventDeserializer", with: self.summitEventDeserializer())
            definition.injectProperty("presentationDeserializer", with: self.presentationDeserializer())
            definition.injectProperty("presentationCategoryDeserializer", with: self.presentationCategoryDeserializer())
            definition.injectProperty("memberDeserializer", with: self.memberDeserializer())
            definition.injectProperty("presentationSpeakerDeserializer", with: self.presentationSpeakerDeserializer())
            definition.injectProperty("tagDeserializer", with: self.tagDeserializer())
            definition.injectProperty("imageDeserializer", with: self.imageDeserializer())
        }
    }
   
    dynamic func imageDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(ImageDeserializer.self)
    }
    
    dynamic func deserializerStorage() -> AnyObject {
        return TyphoonDefinition.withClass(DeserializerStorage.self)
    }
    
    dynamic func summitDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(SummitDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerStorage", with: self.deserializerStorage())
            definition.injectProperty("deserializerFactory", with: self.deserializerFactory())
        }
    }
    
    dynamic func companyDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(CompanyDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerStorage", with: self.deserializerStorage())
        }
    }
    
    dynamic func eventTypeDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(EventTypeDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerStorage", with: self.deserializerStorage())
            
        }
    }
    
    dynamic func summitTypeDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(SummitTypeDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerStorage", with: self.deserializerStorage())
            
        }
    }
    
    dynamic func locationDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(LocationDeserializer.self) {
            (definition) in
            
        }
    }
    
    dynamic func venueDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(VenueDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerStorage", with: self.deserializerStorage())
            definition.injectProperty("deserializerFactory", with: self.deserializerFactory())
        }
    }
    
    dynamic func venueRoomDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(VenueRoomDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerStorage", with: self.deserializerStorage())
            definition.injectProperty("deserializerFactory", with: self.deserializerFactory())
        }
    }
    
    dynamic func summitEventDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(SummitEventDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerStorage", with: self.deserializerStorage())
            definition.injectProperty("deserializerFactory", with: self.deserializerFactory())
        }
    }
    
    dynamic func presentationDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(PresentationDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerFactory", with: self.deserializerFactory())
        }
    }
    
    dynamic func presentationCategoryDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(PresentationCategoryDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerStorage", with: self.deserializerStorage())
        }
    }
    
    dynamic func memberDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(MemberDeserializer.self) {
            (definition) in
        
            definition.injectProperty("deserializerFactory", with: self.deserializerFactory())
        }
    }
    
    dynamic func presentationSpeakerDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(PresentationSpeakerDeserializer.self) {
            (definition) in
            
        }
    }
    
    dynamic func tagDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(TagDeserializer.self) {
            (definition) in
            
        }
    }
}
