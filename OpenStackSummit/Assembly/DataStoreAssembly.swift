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
    var httpFactoryAssembly: HttpFactoryAssembly!
    var dataUpdateAssembly: DataUpdateAssembly!

    // MARK: Deserialization
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
            definition.injectProperty("trackDeserializer", with: self.trackDeserializer())
            definition.injectProperty("memberDeserializer", with: self.memberDeserializer())
            definition.injectProperty("presentationSpeakerDeserializer", with: self.presentationSpeakerDeserializer())
            definition.injectProperty("tagDeserializer", with: self.tagDeserializer())
            definition.injectProperty("imageDeserializer", with: self.imageDeserializer())
            definition.injectProperty("ticketTypeDeserializer", with: self.ticketTypeDeserializer())
            definition.injectProperty("summitAttendeeDeserializer", with: self.summitAttendeeDeserializer())
            definition.injectProperty("dataUpdateDeserializer", with: self.dataUpdateDeserializer())
        }
    }

    dynamic func dataUpdateDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(DataUpdateDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerFactory", with: self.deserializerFactory())
        }
    }
    
    dynamic func summitAttendeeDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(SummitAttendeeDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerStorage", with: self.deserializerStorage())
            definition.injectProperty("deserializerFactory", with: self.deserializerFactory())
        }
    }
    
    dynamic func ticketTypeDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(TicketTypeDeserializer.self) {
            (definition) in
            
            definition.injectProperty("deserializerStorage", with: self.deserializerStorage())
            definition.injectProperty("deserializerFactory", with: self.deserializerFactory())
        }
    }
    
    dynamic func imageDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(ImageDeserializer.self)
    }
    
    dynamic func deserializerStorage() -> AnyObject {
        return TyphoonDefinition.withClass(DeserializerStorage.self){
            (definition) in
            
            definition.scope = TyphoonScope.Singleton
        }
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
    
    dynamic func trackDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(TrackDeserializer.self) {
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

            definition.injectProperty("deserializerStorage", with: self.deserializerStorage())
        }
    }
    
    dynamic func tagDeserializer() -> AnyObject {
        return TyphoonDefinition.withClass(TagDeserializer.self) {
            (definition) in
            
        }
    }
    
    // MARK: Data stores
    dynamic func genericDataStore() -> AnyObject {
        return TyphoonDefinition.withClass(GenericDataStore.self) {
            (definition) in
            
        }
    }
    
    dynamic func feedbackDataStore() -> AnyObject {
        
        return TyphoonDefinition.withClass(FeedbackDataStore.self) {
            (definition) in
            definition.injectProperty("feedbackRemoteDataStore", with: self.feedbackRemoteDataStore())
        }
    }
    
    dynamic func summitDataStore() -> AnyObject {
        
        return TyphoonDefinition.withClass(SummitDataStore.self) {
            (definition) in
            definition.injectProperty("summitRemoteDataStore", with: self.summitRemoteDataStore())
        }
    }
    
    dynamic func eventDataStore() -> AnyObject {
        return TyphoonDefinition.withClass(EventDataStore.self)
    }
    
    dynamic func memberDataStore() -> AnyObject {
        
        return TyphoonDefinition.withClass(MemberDataStore.self) {
            (definition) in
            definition.injectProperty("memberRemoteStorage", with: self.memberRemoteDataStore())
        }
    }
    
    dynamic func summitTypeDataStore() -> AnyObject {
        return TyphoonDefinition.withClass(SummitTypeDataStore.self)
    }
    
    dynamic func eventTypeDataStore() -> AnyObject {
        return TyphoonDefinition.withClass(EventTypeDataStore.self)
    }
    
    dynamic func trackDataStore() -> AnyObject {
        return TyphoonDefinition.withClass(TrackDataStore.self)
    }
    
    
    // MARK: Remote data stores
    dynamic func summitRemoteDataStore() -> AnyObject {
        
        return TyphoonDefinition.withClass(SummitRemoteDataStore.self) {
            (definition) in
            definition.injectProperty("deserializerFactory", with: self.deserializerFactory())
            definition.injectProperty("httpFactory", with: self.httpFactoryAssembly.httpFactory())
            definition.injectProperty("dataUpdatePoller", with: self.dataUpdateAssembly.dataUpdatePoller())
        }
    }
 
    dynamic func presentationSpeakerRemoteDataStore() -> AnyObject {
        
        return TyphoonDefinition.withClass(PresentationSpeakerRemoteDataStore.self) {
            (definition) in
            definition.injectProperty("deserializerFactory", with: self.deserializerFactory())
            definition.injectProperty("httpFactory", with: self.httpFactoryAssembly.httpFactory())
        }
    }
    
    dynamic func summitAttendeeRemoteDataStore() -> AnyObject {
        
        return TyphoonDefinition.withClass(SummitAttendeeRemoteDataStore.self) {
            (definition) in
            definition.injectProperty("deserializerFactory", with: self.deserializerFactory())
            definition.injectProperty("httpFactory", with: self.httpFactoryAssembly.httpFactory())
        }
    }
    
    dynamic func memberRemoteDataStore() -> AnyObject {
        
        return TyphoonDefinition.withClass(MemberRemoteDataStore.self) {
            (definition) in
            definition.injectProperty("deserializerFactory", with: self.deserializerFactory())
            definition.injectProperty("httpFactory", with: self.httpFactoryAssembly.httpFactory())
        }
    }
    
    dynamic func feedbackRemoteDataStore() -> AnyObject {
        
        return TyphoonDefinition.withClass(FeedbackRemoteDataStore.self) {
            (definition) in
            
            definition.injectProperty("httpFactory", with: self.httpFactoryAssembly.httpFactory())
        }
    }
    
}
